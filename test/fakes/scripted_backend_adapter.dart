import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// One scripted backend answer.
class ScriptedResponse {
  const ScriptedResponse(this.status, this.body, {this.retryAfter});

  /// A success fixture from `test/fixtures/backend/<name>.json`.
  factory ScriptedResponse.fixture(String name, {int status = 200}) =>
      ScriptedResponse(status, readFixture(name));

  /// An error fixture, `error_<name>.json`, with its own status and
  /// Retry-After.
  factory ScriptedResponse.error(String name) {
    final wrapper = readFixture('error_$name') as Map<String, dynamic>;
    return ScriptedResponse(
      wrapper['status'] as int,
      wrapper['body'],
      retryAfter: wrapper['retry_after'] as int?,
    );
  }

  final int status;
  final Object? body;
  final int? retryAfter;
}

Object? readFixture(String name) =>
    jsonDecode(File('test/fixtures/backend/$name.json').readAsStringSync());

/// A backend double for 015's repositories. It answers requests in order
/// from a script, records every request (path, headers, body), and can fail
/// a request in transit instead.
class ScriptedBackendAdapter implements HttpClientAdapter {
  final _script = <Object>[];

  /// Every request received, in order.
  final requests = <RequestOptions>[];

  void enqueue(ScriptedResponse response) => _script.add(response);

  /// The next request fails in transit with [error], a `DioException`.
  void enqueueFailure(Object error) => _script.add(error);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (_script.isEmpty) {
      throw StateError('ScriptedBackendAdapter: no answer for ${options.path}');
    }
    final next = _script.removeAt(0);
    if (next is! ScriptedResponse) throw next;
    return ResponseBody.fromString(
      jsonEncode(next.body),
      next.status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        if (next.retryAfter != null) 'retry-after': ['${next.retryAfter}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A plain [Dio] over [adapter]. No interceptors: the repositories are
/// tested on their own, and the auth interceptor has its own test.
Dio dioOver(ScriptedBackendAdapter adapter) =>
    Dio(BaseOptions(baseUrl: 'https://backend.test'))
      ..httpClientAdapter = adapter;
