import 'dart:io' show SocketException;

import 'package:dio/dio.dart';

import '../../core/diagnostics.dart';
import '../../core/fault_injection.dart';

/// Injects [FaultInjection]'s faults into real backend requests, in chaos
/// builds only (contracts/telemetry-events.md §6).
///
/// Added **first**, so an injected failure travels through the same
/// interceptors as a real one: `AuthInterceptor` (an injected 401 gets its
/// one silent retry, then ends the session) and `DiagnosticsInterceptor`
/// (the failure is logged as any other). The app's screens, retries and
/// telemetry therefore react exactly as they would to the real failure.
///
/// It also sends the Vercel Deployment Protection bypass header, so a chaos
/// build can reach a protected Preview deployment.
class FaultInjectionInterceptor extends Interceptor {
  FaultInjectionInterceptor({
    FaultInjection? faults,
    this.protectionBypassToken = '',
    this.faultKey = '',
    Diagnostics diagnostics = const Diagnostics(),
  }) : _faults = faults ?? FaultInjection.instance,
       _diagnostics = diagnostics;

  final FaultInjection _faults;
  final Diagnostics _diagnostics;

  /// Vercel's "Protection Bypass for Automation" secret for the Preview a
  /// chaos build targets. Empty: no header.
  final String protectionBypassToken;

  /// The backend Preview's fault-injection secret (backend spec 003, FR-004).
  /// Empty: no key header.
  final String faultKey;

  /// Asks the backend to fail one dependency on this request only.
  static const backendFaultHeader = 'X-AeroPass-Fault';

  /// Proves the request may inject faults when the Preview has a secret.
  static const faultKeyHeader = 'X-AeroPass-Fault-Key';
  static const protectionBypassHeader = 'x-vercel-protection-bypass';

  /// How long an injected timeout waits when the request sets no timeout.
  static const fallbackTimeout = Duration(seconds: 20);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (protectionBypassToken.isNotEmpty) {
      options.headers[protectionBypassHeader] = protectionBypassToken;
    }
    if (!_faults.active || !_faults.scope.matches(options.uri.path)) {
      return handler.next(options);
    }
    final backendFault = _faults.backendFault;
    if (backendFault != null) {
      options.headers[backendFaultHeader] = backendFault;
      if (faultKey.isNotEmpty) options.headers[faultKeyHeader] = faultKey;
      _log(options, 'backend:$backendFault');
    }
    final network = _faults.network;
    if (network == NetworkFault.none) return handler.next(options);
    _log(options, network.name);

    switch (network) {
      case NetworkFault.none:
        return handler.next(options);
      case NetworkFault.latency:
        await Future<void>.delayed(_faults.latency);
        return handler.next(options);
      case NetworkFault.timeout:
        // The request's real limit, so the screens that race it (for
        // example 007's 30 s) see the same timing as a real timeout.
        await Future<void>.delayed(
          options.receiveTimeout ?? options.sendTimeout ?? fallbackTimeout,
        );
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.receiveTimeout,
            message: 'fault injected: timeout',
          ),
          true,
        );
      case NetworkFault.connectionLost:
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: const SocketException('fault injected: connection lost'),
          ),
          true,
        );
      case NetworkFault.http500:
        return _respond(handler, options, 500);
      case NetworkFault.http503Storage:
        return _respond(
          handler,
          options,
          503,
          codigo: 'ALMACENAMIENTO_NO_DISPONIBLE',
          retryAfter: 5,
        );
      case NetworkFault.http504:
        return _respond(handler, options, 504);
      case NetworkFault.http401:
        return _respond(handler, options, 401, codigo: 'NO_AUTENTICADO');
      case NetworkFault.http429:
        return _respond(
          handler,
          options,
          429,
          codigo: 'LIMITE_EMISION_EXCEDIDO',
          retryAfter: 60,
        );
    }
  }

  /// A backend error response, shaped as the backend's own: its `codigo`
  /// and an optional `Retry-After` (the app never reads anything else).
  void _respond(
    RequestInterceptorHandler handler,
    RequestOptions options,
    int status, {
    String? codigo,
    int? retryAfter,
  }) {
    final response = Response<dynamic>(
      requestOptions: options,
      statusCode: status,
      data: codigo == null ? null : {'codigo': codigo},
      headers: Headers.fromMap({
        if (retryAfter != null) 'retry-after': ['$retryAfter'],
      }),
    );
    handler.reject(
      DioException.badResponse(
        statusCode: status,
        requestOptions: options,
        response: response,
      ),
      true,
    );
  }

  void _log(RequestOptions options, String fault) => _diagnostics.warn(
    'fault_injected',
    {'fault': fault, 'method': options.method, 'path': options.uri.path},
  );
}
