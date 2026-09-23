// 011-error-tecnico T036: contracts/transport-failure-addendum.md.
import 'package:aeropass_app/data/services/transport_error_mapper.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

DioException _dio(DioExceptionType type) =>
    DioException(requestOptions: RequestOptions(), type: type);

void main() {
  for (final type in [
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
  ]) {
    test('${type.name} is the connection', () {
      final error = _dio(type);
      final mapped = mapTransportError(error);
      expect(mapped, isA<ConnectivityFailure>());
      expect((mapped as TransportFailure).cause, same(error));
    });
  }

  for (final type in [
    DioExceptionType.badResponse,
    DioExceptionType.receiveTimeout,
    DioExceptionType.transformTimeout,
    DioExceptionType.badCertificate,
  ]) {
    test('${type.name} is the service', () {
      expect(mapTransportError(_dio(type)), isA<ServiceSideFailure>());
    });
  }

  for (final type in [DioExceptionType.cancel, DioExceptionType.unknown]) {
    test('${type.name} is left unwrapped', () {
      final error = _dio(type);
      expect(mapTransportError(error), same(error));
    });
  }

  test('a non-dio error is left unwrapped', () {
    final error = StateError('no consent');
    expect(mapTransportError(error), same(error));
  });
}
