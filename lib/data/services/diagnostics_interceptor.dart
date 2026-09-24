import 'package:dio/dio.dart';

import '../../core/diagnostics.dart';

/// Logs each backend call's method, path, status, `codigo` and duration, so
/// a failure after sign-in (a 401 from the backend, a 403, a 5xx) can be
/// read in production. Never a header, a query or a body (015 FR-017).
///
/// Added after `AuthInterceptor`, it sees each attempt that interceptor
/// makes, including its one retry after a 401.
class DiagnosticsInterceptor extends Interceptor {
  DiagnosticsInterceptor({Diagnostics diagnostics = const Diagnostics()})
    : _diagnostics = diagnostics;

  final Diagnostics _diagnostics;

  static const _startedAt = 'aeropass.diagnostics.startedAt';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra[_startedAt] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;
    // The pass status poll runs every few seconds while a pass is shown.
    final isPoll =
        options.method == 'GET' && options.uri.path.startsWith('/v1/passes/');
    if (!isPoll) {
      _diagnostics.info('backend_http', _attributes(options, response));
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;
    final attributes = {
      ..._attributes(err.requestOptions, response),
      'type': err.type.name,
      if (response == null) 'detail': err.error?.runtimeType,
    };
    final status = response?.statusCode;
    // 404 PASAJERO_NO_REGISTRADO from `/me` is the expected answer for a new
    // passenger (it leads to registration), not a failure.
    if (attributes['code'] == 'PASAJERO_NO_REGISTRADO') {
      _diagnostics.info('backend_http', attributes);
    } else if (status == null || status >= 500 || status == 401) {
      _diagnostics.error('backend_http_error', attributes);
    } else {
      _diagnostics.warn('backend_http_error', attributes);
    }
    handler.next(err);
  }

  Map<String, Object?> _attributes(
    RequestOptions options,
    Response<dynamic>? response,
  ) {
    final started = options.extra[_startedAt];
    return {
      'method': options.method,
      'path': options.uri.path,
      'status': response?.statusCode,
      'code': switch (response?.data) {
        {'codigo': final String codigo} => codigo,
        _ => null,
      },
      'ms': started is int
          ? DateTime.now().millisecondsSinceEpoch - started
          : null,
    };
  }
}
