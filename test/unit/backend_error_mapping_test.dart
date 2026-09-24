// 015 T051 (SC-004, contracts/backend-api.md): every error code an endpoint
// documents has an explicit app-side outcome. Only an undocumented code may
// reach the generic path, as a BackendError.
import 'dart:typed_data';

import 'package:aeropass_app/app/clock_trust_monitor.dart';
import 'package:aeropass_app/data/services/backend_biometric_verification_repository.dart';
import 'package:aeropass_app/data/services/backend_identity_record_repository.dart';
import 'package:aeropass_app/data/services/backend_pass_repository.dart';
import 'package:aeropass_app/data/services/biometric_service.dart';
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/data/services/pass_service.dart';
import 'package:aeropass_app/data/services/passenger_backed_credential_repository.dart';
import 'package:aeropass_app/data/services/passenger_service.dart';
import 'package:aeropass_app/domain/entities/backend_error.dart';
import 'package:aeropass_app/domain/entities/extraction_result.dart';
import 'package:aeropass_app/domain/entities/identity_record.dart';
import 'package:aeropass_app/domain/entities/passenger_record.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_clock.dart';
import '../fakes/fake_secure_storage_platform.dart';
import '../fakes/scripted_backend_adapter.dart';

final _jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

/// The error fixtures each endpoint documents (contracts/backend-api.md).
const _documented = <String, List<String>>{
  'POST /v1/identity': [
    'no_autenticado',
    'cuenta_ya_registrada',
    'documento_ya_registrado',
    'imagen_demasiado_grande',
    'formato_no_admitido',
    'datos_invalidos',
    'documento_vencido',
    'almacenamiento_no_disponible',
  ],
  'GET /v1/identity/me': ['no_autenticado', 'pasajero_no_registrado'],
  'POST /v1/biometrics/verifications': [
    'no_autenticado',
    'pasajero_no_registrado',
    'estado_no_permite_verificacion',
    'imagen_demasiado_grande',
    'formato_no_admitido',
    'datos_invalidos',
  ],
  'POST /v1/passes': [
    'no_autenticado',
    'identidad_no_activa',
    'documento_vencido_pase',
    'datos_invalidos',
    'limite_emision_excedido',
    'almacenamiento_no_disponible',
  ],
  'GET /v1/passes/{id}': ['no_autenticado', 'credencial_no_encontrada'],
};

void main() {
  late ScriptedBackendAdapter backend;

  setUp(() {
    FlutterSecureStoragePlatform.instance = FakeSecureStoragePlatform();
    backend = ScriptedBackendAdapter();
  });

  CredentialService credentials() =>
      CredentialService(secureStorage: const FlutterSecureStorage());

  /// Calls [endpoint] once against [fixture] and returns what the app got:
  /// the value, or the error object.
  Future<Object?> outcome(String endpoint, String fixture) async {
    backend.enqueue(ScriptedResponse.error(fixture));
    final dio = dioOver(backend);
    switch (endpoint) {
      case 'POST /v1/identity':
        final result =
            await BackendIdentityRecordRepository(
              PassengerService(dio: dio),
              credentialService: credentials(),
            ).confirm(
              const IdentityRecord(
                documentType: DocumentType.cc,
                fields: [
                  ConfirmedField(
                    key: FieldKey.fullName,
                    value: 'Ana Prueba',
                    source: FieldSource.passengerCorrected,
                  ),
                ],
              ),
              documentPhoto: _jpeg,
            );
        return result.when(ok: (v) => v, error: (e, _) => e);
      case 'GET /v1/identity/me':
        final result = await PassengerBackedCredentialRepository(
          PassengerService(dio: dio),
          credentialService: credentials(),
          clock: FakeClock(),
        ).me();
        return result.when(
          ok: (v) => v ?? 'not registered',
          error: (e, _) => e,
        );
      case 'POST /v1/biometrics/verifications':
        final result = await BackendBiometricVerificationRepository(
          BiometricService(dio: dio),
        ).verify(_jpeg);
        return result.when(ok: (v) => v, error: (e, _) => e);
      case 'POST /v1/passes':
        final result = await BackendPassRepository(
          PassService(dio: dio),
          clockTrustMonitor: ClockTrustMonitor(clock: FakeClock()),
        ).issue('AV9201');
        return result.when(ok: (v) => v, error: (e, _) => e);
      case 'GET /v1/passes/{id}':
        // A pass must be held first, so there is a current id to read: the
        // issuance answer goes ahead of the scripted error.
        final scripted = ScriptedBackendAdapter()
          ..enqueue(ScriptedResponse.fixture('pase', status: 201))
          ..enqueue(ScriptedResponse.error(fixture));
        final held = BackendPassRepository(
          PassService(dio: dioOver(scripted)),
          clockTrustMonitor: ClockTrustMonitor(clock: FakeClock()),
        );
        await held.issue('AV9201');
        final result = await held.status('ignored');
        return result.when(ok: (v) => v, error: (e, _) => e);
    }
    throw ArgumentError(endpoint);
  }

  for (final MapEntry(key: endpoint, value: fixtures) in _documented.entries) {
    group(endpoint, () {
      for (final fixture in fixtures) {
        test('$fixture has an explicit outcome', () async {
          final result = await outcome(endpoint, fixture);
          expect(
            result,
            isNot(isA<BackendError>()),
            reason: '$endpoint $fixture reached the generic path',
          );
          expect(result, isNotNull);
        });
      }
    });
  }

  test('every known code is documented by at least one endpoint', () {
    final documented = {
      for (final fixtures in _documented.values)
        for (final f in fixtures) f.replaceAll('_pase', ''),
    };
    final codes = {
      for (final code in BackendErrorCode.values)
        if (code != BackendErrorCode.unknown) code.wire.toLowerCase(),
    };
    expect(codes.difference(documented), isEmpty);
  });
}
