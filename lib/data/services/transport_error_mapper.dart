import 'package:dio/dio.dart';

import '../../domain/entities/transport_failure.dart';

/// Wraps a transport error in the domain's [TransportFailure]
/// (011-error-tecnico, contracts/transport-failure-addendum.md), so the
/// presentation layer can tell the passenger's connection from the service
/// without knowing `dio`. Anything that fits neither case is returned as it
/// is, and the caller treats it as an undetermined cause.
Object mapTransportError(Object error) {
  if (error is! DioException) return error;
  return switch (error.type) {
    DioExceptionType.connectionError ||
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout => TransportFailure.connectivity(error),
    // A pinning failure is the service's problem: reconnecting cannot fix it,
    // so it must never read as "check your connection".
    DioExceptionType.badResponse ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.badCertificate => TransportFailure.service(error),
    DioExceptionType.cancel || DioExceptionType.unknown => error,
  };
}
