// 015 T012 (research.md §12, contracts/backend-api.md "Error body"): every
// backend error fixture maps to a typed BackendError carrying its code,
// status, Retry-After and field list, and `mensaje` is never kept.
import 'dart:convert';
import 'dart:io';

import 'package:aeropass_app/data/services/backend_error_mapper.dart';
import 'package:aeropass_app/domain/entities/backend_error.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A DioException for a backend error fixture, as dio produces it.
DioException errorFixture(String name) {
  final fixture = jsonDecode(
    File('test/fixtures/backend/error_$name.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final retryAfter = fixture['retry_after'] as int?;
  final options = RequestOptions(path: '/v1/x');
  return DioException.badResponse(
    statusCode: fixture['status'] as int,
    requestOptions: options,
    response: Response<dynamic>(
      requestOptions: options,
      statusCode: fixture['status'] as int,
      data: fixture['body'],
      headers: Headers.fromMap({
        if (retryAfter != null) 'retry-after': ['$retryAfter'],
      }),
    ),
  );
}

void main() {
  const expected = <String, (BackendErrorCode, int)>{
    'no_autenticado': (BackendErrorCode.noAutenticado, 401),
    'datos_invalidos': (BackendErrorCode.datosInvalidos, 422),
    'documento_vencido': (BackendErrorCode.documentoVencido, 422),
    'documento_vencido_pase': (BackendErrorCode.documentoVencido, 403),
    'documento_ya_registrado': (BackendErrorCode.documentoYaRegistrado, 409),
    'cuenta_ya_registrada': (BackendErrorCode.cuentaYaRegistrada, 409),
    'pasajero_no_registrado': (BackendErrorCode.pasajeroNoRegistrado, 404),
    'estado_no_permite_verificacion': (
      BackendErrorCode.estadoNoPermiteVerificacion,
      409,
    ),
    'imagen_demasiado_grande': (BackendErrorCode.imagenDemasiadoGrande, 413),
    'formato_no_admitido': (BackendErrorCode.formatoNoAdmitido, 415),
    'almacenamiento_no_disponible': (
      BackendErrorCode.almacenamientoNoDisponible,
      503,
    ),
    'identidad_no_activa': (BackendErrorCode.identidadNoActiva, 403),
    'limite_emision_excedido': (BackendErrorCode.limiteEmisionExcedido, 429),
    'credencial_no_encontrada': (BackendErrorCode.credencialNoEncontrada, 404),
  };

  for (final MapEntry(key: name, value: (code, status)) in expected.entries) {
    test('$name maps to $code', () {
      final mapped = mapBackendError(errorFixture(name));
      expect(mapped, isA<BackendError>());
      final error = mapped as BackendError;
      expect(error.code, code);
      expect(error.status, status);
    });
  }

  test('every known code has a fixture', () {
    final covered = expected.values.map((e) => e.$1).toSet();
    expect(BackendErrorCode.values.toSet().difference(covered), {
      BackendErrorCode.unknown,
    });
  });

  test('Retry-After is read as a duration', () {
    final busy = mapBackendError(
      errorFixture('almacenamiento_no_disponible'),
    ) as BackendError;
    expect(busy.retryAfter, const Duration(seconds: 30));
    final limited = mapBackendError(
      errorFixture('limite_emision_excedido'),
    ) as BackendError;
    expect(limited.retryAfter, const Duration(seconds: 12));
    final none =
        mapBackendError(errorFixture('cuenta_ya_registrada')) as BackendError;
    expect(none.retryAfter, isNull);
  });

  test('detalles.campos becomes the field list', () {
    final invalid =
        mapBackendError(errorFixture('datos_invalidos')) as BackendError;
    expect(invalid.fields, ['fecha_vencimiento', 'numero_documento']);
  });

  test('mensaje is never kept, not even in toString', () {
    for (final name in expected.keys) {
      final mapped = mapBackendError(errorFixture(name));
      expect(mapped.toString(), isNot(contains('MENSAJE_INTERNO')));
    }
  });

  test('an unknown code or unparseable body is BackendErrorCode.unknown', () {
    final options = RequestOptions(path: '/v1/x');
    for (final data in <Object?>[
      {'codigo': 'NUEVO_CODIGO', 'mensaje': 'x'},
      '<html>502</html>',
      null,
    ]) {
      final mapped = mapBackendError(
        DioException.badResponse(
          statusCode: 502,
          requestOptions: options,
          response: Response<dynamic>(
            requestOptions: options,
            statusCode: 502,
            data: data,
          ),
        ),
      );
      expect((mapped as BackendError).code, BackendErrorCode.unknown);
      expect(mapped.status, 502);
    }
  });

  test('a failure with no response stays a transport failure', () {
    final mapped = mapBackendError(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/v1/x'),
        reason: 'offline',
      ),
    );
    expect(mapped, isA<ConnectivityFailure>());
  });
}
