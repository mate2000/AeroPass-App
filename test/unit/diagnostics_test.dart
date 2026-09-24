import 'package:aeropass_app/app/app.dart' show isAlreadySignedIn;
import 'package:aeropass_app/core/diagnostics.dart';
import 'package:aeropass_app/data/auth/clerk_setup.dart';
import 'package:aeropass_app/data/services/diagnostics_interceptor.dart';
import 'package:clerk_auth/clerk_auth.dart' show ClerkError;
// ExternalError is not exported by clerk_auth.
// ignore: implementation_imports
import 'package:clerk_auth/src/models/api/external_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/scripted_backend_adapter.dart';

class _Recording extends Diagnostics {
  final events = <(String, String, Map<String, Object?>)>[];

  @override
  void info(String event, [Map<String, Object?> attributes = const {}]) =>
      events.add(('info', event, attributes));
  @override
  void warn(String event, [Map<String, Object?> attributes = const {}]) =>
      events.add(('warn', event, attributes));
  @override
  void error(String event, [Map<String, Object?> attributes = const {}]) =>
      events.add(('error', event, attributes));
}

void main() {
  group('redactDiagnostic', () {
    test('masks emails, JWTs, bearer values and long digit runs', () {
      final out = redactDiagnostic(
        "Couldn't find ana.prueba@example.com; Bearer abc.def "
        'eyJhbGciOi.eyJzdWIiOi.sig code 123456',
      );
      expect(out, isNot(contains('ana.prueba')));
      expect(out, isNot(contains('eyJ')));
      expect(out, isNot(contains('abc.def')));
      expect(out, isNot(contains('123456')));
      expect(out, contains('<email>'));
    });

    test('keeps codes, statuses and paths', () {
      expect(
        redactDiagnostic('form_password_incorrect /v1/client/sign_ins 422'),
        'form_password_incorrect /v1/client/sign_ins 422',
      );
    });
  });

  test('clerkErrorSummary reads codes, params and messages', () {
    final summary = clerkErrorSummary(
      '{"errors":[{"code":"form_password_incorrect","message":"x",'
      '"long_message":"Password is incorrect.","meta":{"param_name":"password"}}]}',
    );
    expect(summary['code'], 'form_password_incorrect');
    expect(summary['params'], 'password');
    expect(summary['message'], 'Password is incorrect.');
    expect(clerkErrorSummary('<html>'), isEmpty);
  });

  test('clerkFrontendApiHost decodes the publishable key', () {
    expect(
      clerkFrontendApiHost(
        'pk_test_ZGlzY3JldGUtc2F0eXItNzI5OC5jbGVyay5hY2NvdW50cy5kZXYk',
      ),
      'discrete-satyr-7298.clerk.accounts.dev',
    );
    expect(clerkFrontendApiHost('nonsense'), isNull);
  });

  test('backend errors are logged with path, status and codigo', () async {
    final recording = _Recording();
    final backend = ScriptedBackendAdapter()
      ..enqueue(ScriptedResponse.error('no_autenticado'));
    final dio = dioOver(backend)
      ..interceptors.add(DiagnosticsInterceptor(diagnostics: recording));

    await expectLater(
      dio.get<dynamic>('/v1/identity/me'),
      throwsA(isA<DioException>()),
    );

    final (level, event, attributes) = recording.events.single;
    expect(level, 'error');
    expect(event, 'backend_http_error');
    expect(attributes['path'], '/v1/identity/me');
    expect(attributes['status'], 401);
    expect(attributes['code'], 'NO_AUTENTICADO');
    expect(attributes.keys, isNot(contains('headers')));
  });

  test('a not-registered 404 from /me is info, not an error', () async {
    final recording = _Recording();
    final backend = ScriptedBackendAdapter()
      ..enqueue(ScriptedResponse.error('pasajero_no_registrado'));
    final dio = dioOver(backend)
      ..interceptors.add(DiagnosticsInterceptor(diagnostics: recording));

    await expectLater(
      dio.get<dynamic>('/v1/identity/me'),
      throwsA(isA<DioException>()),
    );

    final (level, event, attributes) = recording.events.single;
    expect(level, 'info');
    expect(event, 'backend_http');
    expect(attributes['status'], 404);
  });

  test('only a lone session_exists counts as already signed in', () {
    ClerkError withCodes(List<String> codes) => ClerkError.from(
      ExternalErrorCollection(
        errors: [for (final c in codes) ExternalError(message: c, code: c)],
      ),
    );
    expect(isAlreadySignedIn(withCodes(['session_exists'])), isTrue);
    expect(isAlreadySignedIn(withCodes(['form_code_incorrect'])), isFalse);
    expect(
      isAlreadySignedIn(withCodes(['session_exists', 'form_code_incorrect'])),
      isFalse,
    );
  });
}
