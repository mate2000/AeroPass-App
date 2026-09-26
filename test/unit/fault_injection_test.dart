// Fault injection (015 observability, telemetry-events.md §6): injected
// failures travel the real Dio chain and are seen by the diagnostics, and
// the diagnostics namespace passes the privacy filter.
import 'package:aeropass_app/core/diagnostics.dart';
import 'package:aeropass_app/core/fault_injection.dart';
import 'package:aeropass_app/data/services/backend_error_mapper.dart';
import 'package:aeropass_app/data/services/diagnostics_interceptor.dart';
import 'package:aeropass_app/data/services/fault_injection_interceptor.dart';
import 'package:aeropass_app/data/services/sentry_privacy_filter.dart';
import 'package:aeropass_app/domain/entities/backend_error.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
  late FaultInjection faults;
  late ScriptedBackendAdapter backend;
  late _Recording recording;
  late Dio dio;

  setUp(() {
    faults = FaultInjection();
    backend = ScriptedBackendAdapter();
    recording = _Recording();
    dio = dioOver(backend)
      ..interceptors.addAll([
        FaultInjectionInterceptor(
          faults: faults,
          protectionBypassToken: 'bypass-secret',
          faultKey: 'fault-secret',
          diagnostics: recording,
        ),
        DiagnosticsInterceptor(diagnostics: recording),
      ]);
  });

  test('with nothing active, requests go through untouched', () async {
    backend.enqueue(ScriptedResponse.fixture('pasajero_pendiente'));
    await dio.get<dynamic>('/v1/identity/me');
    final sent = backend.requests.single;
    expect(sent.headers.containsKey('X-AeroPass-Fault'), isFalse);
    expect(sent.headers.containsKey('X-AeroPass-Fault-Key'), isFalse);
    expect(sent.headers['x-vercel-protection-bypass'], 'bypass-secret');
    expect(recording.events.map((e) => e.$2), ['backend_http']);
  });

  test('an injected 503 looks like the real storage failure', () async {
    faults.network = NetworkFault.http503Storage;
    Object? caught;
    try {
      await dio.post<dynamic>('/v1/biometrics/verifications');
    } on DioException catch (e) {
      caught = e;
      final mapped = mapBackendError(e);
      expect(mapped, isA<BackendError>());
      expect(
        (mapped as BackendError).code,
        BackendErrorCode.almacenamientoNoDisponible,
      );
    }
    expect(caught, isNotNull);
    expect(backend.requests, isEmpty, reason: 'it never reached the backend');
    final names = recording.events.map((e) => e.$2).toList();
    expect(names, ['fault_injected', 'backend_http_error']);
    final httpError = recording.events.last.$3;
    expect(httpError['status'], 503);
    expect(httpError['code'], 'ALMACENAMIENTO_NO_DISPONIBLE');
  });

  test('a lost connection is a connection error', () async {
    faults.network = NetworkFault.connectionLost;
    await expectLater(
      dio.get<dynamic>('/v1/identity/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.connectionError,
        ),
      ),
    );
  });

  test('an injected timeout waits the request\'s own limit', () async {
    faults.network = NetworkFault.timeout;
    final watch = Stopwatch()..start();
    await expectLater(
      dio.get<dynamic>(
        '/v1/identity/me',
        options: Options(receiveTimeout: const Duration(milliseconds: 60)),
      ),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          DioExceptionType.receiveTimeout,
        ),
      ),
    );
    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(50));
  });

  test('latency delays the request, which then succeeds', () async {
    faults
      ..network = NetworkFault.latency
      ..latency = const Duration(milliseconds: 40);
    backend.enqueue(ScriptedResponse.fixture('pasajero_pendiente'));
    final watch = Stopwatch()..start();
    await dio.get<dynamic>('/v1/identity/me');
    expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(35));
    expect(backend.requests, hasLength(1));
  });

  test('the scope limits which calls fail', () async {
    faults
      ..network = NetworkFault.http500
      ..scope = FaultScope.passes;
    backend.enqueue(ScriptedResponse.fixture('pasajero_pendiente'));
    await dio.get<dynamic>('/v1/identity/me');
    await expectLater(
      dio.post<dynamic>('/v1/passes'),
      throwsA(isA<DioException>()),
    );
  });

  test('a backend fault is requested in its header', () async {
    faults.backendFault = 'blob_down';
    backend.enqueue(ScriptedResponse.fixture('pasajero_pendiente'));
    await dio.get<dynamic>('/v1/identity/me');
    final sent = backend.requests.single.headers;
    expect(sent['X-AeroPass-Fault'], 'blob_down');
    expect(sent['X-AeroPass-Fault-Key'], 'fault-secret');
  });

  group('FaultInjection', () {
    test('active and label follow the selection; clear resets it', () {
      expect(faults.active, isFalse);
      expect(faults.label, '');
      faults
        ..network = NetworkFault.http429
        ..scope = FaultScope.passes
        ..backendFault = 'mxface_down';
      expect(faults.active, isTrue);
      expect(faults.label, 'http429,backend:mxface_down,scope:passes');
      faults.clear();
      expect(faults.active, isFalse);
      expect(faults.scope, FaultScope.all);
    });
  });

  group('privacy filter and diagnostics', () {
    const filter = SentryPrivacyFilter(alertEventTag: 'failure_class');

    test('a diagnostics log keeps its aeropass.diag.* attributes', () {
      final log = SentryLog(
        timestamp: DateTime.utc(2026, 9, 24),
        level: SentryLogLevel.warn,
        body: 'fault_injected',
        attributes: {
          'aeropass.event': SentryAttribute.string('fault_injected'),
          'aeropass.diag.fault': SentryAttribute.string('http503Storage'),
          'aeropass.diag.path': SentryAttribute.string('/v1/identity/me'),
          'fault': SentryAttribute.string('not namespaced'),
        },
      );
      final kept = filter.beforeSendLog(log);
      expect(kept, isNotNull);
      expect(
        kept!.attributes.keys,
        containsAll(['aeropass.diag.fault', 'aeropass.diag.path']),
      );
      expect(kept.attributes.containsKey('fault'), isFalse);
    });

    test('diagnostics breadcrumbs pass through', () {
      final crumb = filter.beforeBreadcrumb(
        Breadcrumb(category: 'diagnostics', message: 'backend_http'),
        Hint(),
      );
      expect(crumb, isNotNull);
    });
  });
}
