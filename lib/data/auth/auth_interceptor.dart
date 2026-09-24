import 'package:dio/dio.dart';

import '../../core/result.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/session_token_provider.dart';

/// Adds `Authorization: Bearer <token>` to every `/v1/*` request (015
/// contracts/backend-api.md "Transport").
///
/// - The token is requested from [SessionTokenProvider] for each request and
///   held nowhere else (FR-001).
/// - A 401 re-establishes the session and retries the request once. A second
///   401 is passed on, and maps to `BackendErrorCode.noAutenticado`.
/// - No token means no request: it fails with [SessionUnavailable].
/// - This class never logs. The header lives only on the request object
///   (FR-017).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required SessionTokenProvider tokens, required Dio dio})
    : _tokens = tokens,
      _dio = dio;

  final SessionTokenProvider _tokens;
  final Dio _dio;

  static const _retriedKey = 'aeropass.authRetried';
  static const _header = 'Authorization';

  static bool _needsAuth(RequestOptions options) =>
      options.path.startsWith('/v1/');

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_needsAuth(options)) return handler.next(options);
    switch (await _tokens.token()) {
      case Ok(:final value):
        options.headers[_header] = 'Bearer $value';
        handler.next(options);
      case Error():
        handler.reject(
          DioException(
            requestOptions: options,
            error: const SessionUnavailable(),
          ),
        );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final unauthorized = err.response?.statusCode == 401;
    if (!unauthorized ||
        !_needsAuth(options) ||
        options.extra[_retriedKey] == true) {
      return handler.next(err);
    }
    if ((await _tokens.reestablish()).isError) return handler.next(err);
    options.extra[_retriedKey] = true;
    options.headers.remove(_header);
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
