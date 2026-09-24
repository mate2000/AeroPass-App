// 015 T013 (contracts/backend-api.md "Transport", FR-001, FR-017): a fresh
// token per request, one silent retry on 401, no header on public paths,
// and no token anywhere but the request header.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/auth/auth_interceptor.dart';
import 'package:aeropass_app/data/services/backend_error_mapper.dart';
import 'package:aeropass_app/domain/entities/backend_error.dart';
import 'package:aeropass_app/domain/entities/session_state.dart';
import 'package:aeropass_app/domain/repositories/session_token_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _Tokens implements SessionTokenProvider {
  int issued = 0;
  int reestablished = 0;
  bool fail = false;

  @override
  Future<Result<String>> token() async {
    if (fail) return const Result.error(SessionUnavailable());
    issued++;
    return Result.ok('tok-$issued');
  }

  @override
  Future<Result<void>> reestablish() async {
    reestablished++;
    return const Result.ok(null);
  }

  @override
  Future<void> signOut() async {}
}

/// Answers each request with the next scripted status and records headers.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.statuses);

  final List<int> statuses;
  final seen = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seen.add(options);
    final status = statuses.isEmpty ? 200 : statuses.removeAt(0);
    final body = status == 401
        ? {'codigo': 'NO_AUTENTICADO', 'mensaje': 'x'}
        : {'ok': true};
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late _Tokens tokens;

  Dio build(_Adapter adapter) {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'))
      ..httpClientAdapter = adapter;
    dio.interceptors.add(AuthInterceptor(tokens: tokens, dio: dio));
    return dio;
  }

  setUp(() => tokens = _Tokens());

  test('each /v1 request gets a freshly requested token', () async {
    final adapter = _Adapter([200, 200]);
    final dio = build(adapter);
    await dio.get<void>('/v1/identity/me');
    await dio.get<void>('/v1/identity/me');
    expect(adapter.seen.map((o) => o.headers['Authorization']), [
      'Bearer tok-1',
      'Bearer tok-2',
    ]);
  });

  test('a 401 re-establishes the session and retries once', () async {
    final adapter = _Adapter([401, 200]);
    final response = await build(adapter).get<void>('/v1/identity/me');
    expect(response.statusCode, 200);
    expect(tokens.reestablished, 1);
    expect(adapter.seen, hasLength(2));
    expect(adapter.seen.last.headers['Authorization'], 'Bearer tok-2');
  });

  test('a second 401 is a noAutenticado BackendError, not a loop', () async {
    final adapter = _Adapter([401, 401, 200]);
    Object? caught;
    try {
      await build(adapter).get<void>('/v1/identity/me');
    } catch (e) {
      caught = mapBackendError(e);
    }
    expect((caught! as BackendError).code, BackendErrorCode.noAutenticado);
    expect(adapter.seen, hasLength(2));
    expect(tokens.reestablished, 1);
  });

  test('public paths get no Authorization header', () async {
    final adapter = _Adapter([200]);
    await build(adapter).get<void>('/.well-known/jwks.json');
    expect(adapter.seen.single.headers.containsKey('Authorization'), isFalse);
    expect(tokens.issued, 0);
  });

  test('no token → SessionUnavailable, and no request is sent', () async {
    tokens.fail = true;
    final adapter = _Adapter([200]);
    Object? caught;
    try {
      await build(adapter).get<void>('/v1/identity/me');
    } catch (e) {
      caught = mapBackendError(e);
    }
    expect(caught, isA<SessionUnavailable>());
    expect(adapter.seen, isEmpty);
  });

  test('the interceptor prints nothing that contains the token', () async {
    final printed = <String>[];
    await runZonedPrint(
      () => build(_Adapter([401, 200])).get<void>('/v1/identity/me'),
      printed,
    );
    expect(printed.where((line) => line.contains('tok-')), isEmpty);
  });
}

Future<void> runZonedPrint(Future<void> Function() body, List<String> printed) {
  return Zone.current
      .fork(
        specification: ZoneSpecification(
          print: (_, _, _, line) => printed.add(line),
        ),
      )
      .run(body);
}
