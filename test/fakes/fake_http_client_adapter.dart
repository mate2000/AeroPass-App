import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A scripted `HttpClientAdapter` double used to back the "real"
/// `CredentialRepositoryImpl` in the contract test suite without real
/// network I/O or a live TLS server. Configure with [respondWith] or
/// [failWith] before each call.
class FakeHttpClientAdapter implements HttpClientAdapter {
  Map<String, dynamic>? _jsonBody;
  int _statusCode = 200;
  Object? _error;

  /// 007: lets a contract test assert that no request was sent.
  int requestCount = 0;

  /// The most recent request, for asserting its path and query.
  RequestOptions? lastRequest;

  void respondWith(Map<String, dynamic> json, {int statusCode = 200}) {
    _jsonBody = json;
    _statusCode = statusCode;
    _error = null;
  }

  void failWith(Object error) {
    _error = error;
    _jsonBody = null;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    lastRequest = options;
    final error = _error;
    if (error != null) {
      throw error;
    }
    final body = jsonEncode(_jsonBody ?? <String, dynamic>{});
    return ResponseBody.fromString(
      body,
      _statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
