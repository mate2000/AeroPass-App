// 015 T026 (FR-019, SC-001, contracts/backend-api.md): the app speaks the
// real contract. Every fixture parses. Renaming any key, or changing any enum
// value, fails with that field's name. The request builders produce exactly
// the parts and bodies the backend reads.
import 'dart:convert';
import 'dart:typed_data';

import 'package:aeropass_app/data/models/backend/detalle_pase_dto.dart';
import 'package:aeropass_app/data/models/backend/pasajero_dto.dart';
import 'package:aeropass_app/data/models/backend/pase_dto.dart';
import 'package:aeropass_app/data/models/backend/resultado_verificacion_dto.dart';
import 'package:aeropass_app/data/services/biometric_service.dart';
import 'package:aeropass_app/data/services/pass_service.dart';
import 'package:aeropass_app/data/services/passenger_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/scripted_backend_adapter.dart';

typedef _Parser = Object Function(Map<String, dynamic>);

final _schemas = <String, (_Parser, List<String>)>{
  'PasajeroResponse': (PasajeroDto.fromJson, ['pasajero_verificado']),
  'ResultadoVerificacionResponse': (
    ResultadoVerificacionDto.fromJson,
    [
      'resultado_exitoso',
      'resultado_fallido_liveness',
      'resultado_fallido_comparacion',
      'resultado_no_concluyente',
    ],
  ),
  'PaseResponse': (PaseDto.fromJson, ['pase']),
  'DetallePaseResponse': (
    DetallePaseDto.fromJson,
    ['detalle_pase_activa', 'detalle_pase_consumida', 'detalle_pase_revocada'],
  ),
};

/// The enum-valued keys of each schema, which must reject a changed value.
const _enumKeys = <String, List<String>>{
  'PasajeroResponse': ['tipo_documento', 'estado'],
  'ResultadoVerificacionResponse': ['resultado', 'estado_pasajero'],
  'PaseResponse': ['estado'],
  'DetallePaseResponse': ['estado'],
};

Map<String, dynamic> _fixture(String name) =>
    readFixture(name)! as Map<String, dynamic>;

void main() {
  group('every fixture parses', () {
    for (final MapEntry(key: schema, value: (parse, fixtures))
        in _schemas.entries) {
      for (final name in fixtures) {
        test(
          '$schema: $name',
          () => expect(() => parse(_fixture(name)), returnsNormally),
        );
      }
    }
  });

  group('a renamed key fails, naming the field', () {
    for (final MapEntry(key: schema, value: (parse, fixtures))
        in _schemas.entries) {
      final json = _fixture(fixtures.first);
      for (final key in json.keys) {
        test('$schema.$key', () {
          final renamed = {...json}..remove(key);
          renamed['${key}_renamed'] = json[key];
          expect(
            () => parse(renamed),
            throwsA(predicate((Object e) => e.toString().contains(key))),
          );
        });
      }
    }
  });

  group('a changed enum value fails, naming the field', () {
    for (final MapEntry(key: schema, value: keys) in _enumKeys.entries) {
      final (parse, fixtures) = _schemas[schema]!;
      final json = _fixture(fixtures.first);
      for (final key in keys) {
        test('$schema.$key', () {
          final changed = {...json, key: 'VALOR_NUEVO'};
          expect(
            () => parse(changed),
            throwsA(predicate((Object e) => e.toString().contains(key))),
          );
        });
      }
    }
  });

  test('an added backend field is tolerated', () {
    final json = {..._fixture('pase'), 'campo_nuevo': 1};
    expect(() => PaseDto.fromJson(json), returnsNormally);
  });

  group('request builders', () {
    final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

    test('POST /v1/identity: exactly five parts, the photo image/jpeg', () {
      final form = PassengerService.registrationForm(
        nombreCompleto: 'Ana Prueba',
        tipoDocumento: 'CC',
        numeroDocumento: '1020304050',
        fechaVencimiento: '2030-01-31',
        fotoDocumento: jpeg,
      );
      expect(form.fields.map((f) => f.key).toSet(), {
        'nombre_completo',
        'tipo_documento',
        'numero_documento',
        'fecha_vencimiento',
      });
      final file = form.files.single;
      expect(file.key, 'foto_documento');
      expect(file.value.contentType.toString(), 'image/jpeg');
    });

    test('POST /v1/biometrics/verifications: one selfie part, image/jpeg', () {
      final form = BiometricService.selfieForm(jpeg);
      expect(form.fields, isEmpty);
      expect(form.files.single.key, 'selfie');
      expect(form.files.single.value.contentType.toString(), 'image/jpeg');
    });

    test('POST /v1/passes: a JSON body with codigo_vuelo only', () async {
      final backend = ScriptedBackendAdapter()
        ..enqueue(ScriptedResponse.fixture('pase', status: 201));
      await PassService(dio: dioOver(backend)).issue('AV9201');
      final request = backend.requests.single;
      expect(request.path, '/v1/passes');
      expect(request.method, 'POST');
      expect(jsonDecode(jsonEncode(request.data)), {'codigo_vuelo': 'AV9201'});
    });

    test('GET /v1/passes/{credencial_id}', () async {
      final backend = ScriptedBackendAdapter()
        ..enqueue(ScriptedResponse.fixture('detalle_pase_activa'));
      await PassService(dio: dioOver(backend)).detail('c-1');
      expect(backend.requests.single.path, '/v1/passes/c-1');
      expect(backend.requests.single.method, 'GET');
    });

    test('GET /v1/identity/me', () async {
      final backend = ScriptedBackendAdapter()
        ..enqueue(ScriptedResponse.fixture('pasajero_pendiente'));
      await PassengerService(dio: dioOver(backend)).me();
      expect(backend.requests.single.path, '/v1/identity/me');
      expect(backend.requests.single.method, 'GET');
    });

    test('a 200 registration is reported as not created (V-03)', () async {
      final backend = ScriptedBackendAdapter()
        ..enqueue(ScriptedResponse.fixture('pasajero_pendiente'));
      final result = await PassengerService(dio: dioOver(backend)).register(
        nombreCompleto: 'Ana Prueba',
        tipoDocumento: 'CC',
        numeroDocumento: '1020304050',
        fechaVencimiento: '2030-01-31',
        fotoDocumento: jpeg,
      );
      expect(result.created, isFalse);
      expect(backend.requests.single.data, isA<FormData>());
    });
  });
}
