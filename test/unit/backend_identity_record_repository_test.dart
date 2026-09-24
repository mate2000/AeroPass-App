// 015 T028 (FR-002 to FR-004, FR-016, contracts/outcome-mapping.md
// "Registration"): the registration repository sends the five-part
// multipart request, treats 201 and 200 as success, maps each refusal to
// its own rejection, and stores only the display subset.
import 'dart:typed_data';

import 'package:aeropass_app/data/services/backend_identity_record_repository.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/data/services/passenger_service.dart';
import 'package:aeropass_app/domain/entities/backend_error.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/identity_record.dart';
import 'package:aeropass_app/domain/entities/passenger_record.dart';
import 'package:aeropass_app/domain/entities/registration_rejection.dart';
import 'package:aeropass_app/domain/entities/session_state.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_secure_storage_platform.dart';
import '../fakes/scripted_backend_adapter.dart';

final _jpeg = Uint8List.fromList([
  0xFF,
  0xD8,
  0xFF,
  0xFE,
  0x00,
  0x02,
  0xFF,
  0xD9,
]);

IdentityRecord _record({DocumentType? type = DocumentType.cc}) =>
    IdentityRecord(
      documentType: type,
      fields: const [
        ConfirmedField(
          key: FieldKey.fullName,
          value: '  Ana   Prueba ',
          source: FieldSource.passengerCorrected,
        ),
        ConfirmedField(
          key: FieldKey.documentNumber,
          value: '1.020.304.050',
          source: FieldSource.passengerCorrected,
        ),
        ConfirmedField(
          key: FieldKey.expiryDate,
          value: '2030-01-31',
          source: FieldSource.passengerCorrected,
        ),
      ],
    );

void main() {
  late FakeSecureStoragePlatform storage;
  late ScriptedBackendAdapter backend;
  late BackendIdentityRecordRepository repository;

  setUp(() {
    storage = FakeSecureStoragePlatform();
    FlutterSecureStoragePlatform.instance = storage;
    backend = ScriptedBackendAdapter();
    final dio = dioOver(backend);
    repository = BackendIdentityRecordRepository(
      PassengerService(dio: dio),
      credentialService: CredentialService(
        secureStorage: const FlutterSecureStorage(),
      ),
    );
  });

  Future<Map<String, String>> stored() =>
      const FlutterSecureStorage().readAll();

  test('sends the five normalized parts, the photo as image/jpeg', () async {
    backend.enqueue(
      ScriptedResponse.fixture('pasajero_pendiente', status: 201),
    );
    final result = await repository.confirm(_record(), documentPhoto: _jpeg);
    expect(result.isOk, isTrue);

    final request = backend.requests.single;
    expect(request.path, '/v1/identity');
    final form = request.data as FormData;
    expect(Map.fromEntries(form.fields), {
      'nombre_completo': 'Ana Prueba',
      'tipo_documento': 'CC',
      'numero_documento': '1020304050',
      'fecha_vencimiento': '2030-01-31',
    });
    final photo = form.files.single;
    expect(photo.key, 'foto_documento');
    expect(photo.value.filename, 'documento.jpg');
    expect(photo.value.contentType.toString(), 'image/jpeg');
  });

  test('200, an identical resubmission, is success too (FR-003)', () async {
    backend.enqueue(ScriptedResponse.fixture('pasajero_pendiente'));
    final result = await repository.confirm(_record(), documentPhoto: _jpeg);
    expect(result.isOk, isTrue);
  });

  test('only the name and the masked last four are stored (FR-004)', () async {
    backend.enqueue(
      ScriptedResponse.fixture('pasajero_pendiente', status: 201),
    );
    await repository.confirm(_record(), documentPhoto: _jpeg);
    final values = await stored();
    expect(values[CredentialService.holderNameKey], 'Ana Prueba');
    expect(values[CredentialService.documentLast4Key], '4050');
    expect(values.values.any((v) => v.contains('1020304050')), isFalse);
    expect(values, hasLength(2));
  });

  test('no photo, or one over 4 MB, is refused before sending', () async {
    expect((await repository.confirm(_record())).isError, isTrue);
    final big = Uint8List(BackendIdentityRecordRepository.maxPhotoBytes + 1);
    final result = await repository.confirm(_record(), documentPhoto: big);
    expect(
      result.when(ok: (_) => null, error: (e, _) => e),
      isA<RecaptureDocument>(),
    );
    expect(backend.requests, isEmpty);
  });

  test('a missing document type is an invalid field, before sending', () async {
    final result = await repository.confirm(
      _record(type: null),
      documentPhoto: _jpeg,
    );
    final rejection =
        result.when(ok: (_) => null, error: (e, _) => e) as InvalidFields;
    expect(rejection.documentType, isTrue);
    expect(backend.requests, isEmpty);
  });

  group('each refusal has its own rejection', () {
    Future<Object?> refusal(String fixture) async {
      backend.enqueue(ScriptedResponse.error(fixture));
      final result = await repository.confirm(_record(), documentPhoto: _jpeg);
      return result.when(ok: (_) => null, error: (e, _) => e);
    }

    test('422 DATOS_INVALIDOS names the fields', () async {
      final rejection = await refusal('datos_invalidos') as InvalidFields;
      expect(rejection.fields, {FieldKey.expiryDate, FieldKey.documentNumber});
    });

    test('422 DOCUMENTO_VENCIDO', () async {
      expect(await refusal('documento_vencido'), isA<DocumentExpired>());
    });

    test('409 CUENTA_YA_REGISTRADA', () async {
      expect(
        await refusal('cuenta_ya_registrada'),
        isA<AccountHasOtherDocument>(),
      );
    });

    test('409 DOCUMENTO_YA_REGISTRADO goes to the agent path', () async {
      expect(
        await refusal('documento_ya_registrado'),
        isA<DocumentOwnedElsewhere>(),
      );
    });

    test('413 and 415 ask for the photo again', () async {
      expect(
        await refusal('imagen_demasiado_grande'),
        isA<RecaptureDocument>(),
      );
      expect(await refusal('formato_no_admitido'), isA<RecaptureDocument>());
    });

    test('503 is a service condition with its Retry-After', () async {
      final busy = await refusal(
        'almacenamiento_no_disponible',
      ) as RegistrationServiceBusy;
      expect(busy.retryAfter, const Duration(seconds: 30));
    });

    test('401 after the silent retry is a session problem', () async {
      expect(await refusal('no_autenticado'), isA<SessionUnavailable>());
    });

    test(
      'an undocumented code stays a BackendError for the generic path',
      () async {
        final error = await refusal('limite_emision_excedido') as BackendError;
        expect(error.code, BackendErrorCode.limiteEmisionExcedido);
      },
    );

    test('nothing is stored on any refusal', () async {
      await refusal('datos_invalidos');
      expect(await stored(), isEmpty);
    });
  });

  test('a transport failure stays a TransportFailure', () async {
    backend.enqueueFailure(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/v1/identity'),
        reason: 'offline',
      ),
    );
    final result = await repository.confirm(_record(), documentPhoto: _jpeg);
    expect(
      result.when(ok: (_) => null, error: (e, _) => e),
      isA<ConnectivityFailure>(),
    );
  });
}
