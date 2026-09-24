// 015 T065 (FR-012, FR-013, FR-015, FR-015b, SC-006): 014's ViewModel on the
// real backend's model, where rotation is renewal. A failed renewal keeps
// the code until expira_at and then shows none. Boarded ends everything,
// and an expired document is its own reason.
import 'package:aeropass_app/app/clock_trust_monitor.dart';
import 'package:aeropass_app/data/services/backend_pass_repository.dart';
import 'package:aeropass_app/data/services/issued_token_pass_code_source.dart';
import 'package:aeropass_app/data/services/pass_service.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/features/pass/pass_viewmodel.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_pass_display.dart';
import '../fakes/scripted_backend_adapter.dart';

final _t0 = DateTime.utc(2026, 9, 23, 17, 4);

ScriptedResponse _pase(String id, DateTime at, {String token = 'tok-1'}) =>
    ScriptedResponse(201, {
      ...readFixture('pase')! as Map<String, dynamic>,
      'credencial_id': id,
      'token': token,
      'emitida_at': at.toIso8601String(),
      'expira_at': at.add(const Duration(seconds: 45)).toIso8601String(),
    });

ScriptedResponse _detalle(String id, String estado) => ScriptedResponse(200, {
  ...readFixture('detalle_pase_activa')! as Map<String, dynamic>,
  'credencial_id': id,
  'estado': estado,
});

DioException _offline() => DioException.connectionError(
  requestOptions: RequestOptions(path: '/v1/passes'),
  reason: 'offline',
);

void main() {
  late ScriptedBackendAdapter backend;
  late FakeClock clock;
  late Duration monotonic;
  late ClockTrustMonitor trust;
  late BackendPassRepository repository;
  late FakePassDisplayGuard display;

  setUp(() {
    backend = ScriptedBackendAdapter();
    clock = FakeClock(_t0);
    monotonic = Duration.zero;
    trust = ClockTrustMonitor(clock: clock, monotonicNow: () => monotonic);
    repository = BackendPassRepository(
      PassService(dio: dioOver(backend)),
      clockTrustMonitor: trust,
    );
    display = FakePassDisplayGuard();
  });

  void advance(Duration d) {
    clock.advance(d);
    monotonic += d;
  }

  PassViewModel build({Duration tick = const Duration(hours: 1)}) =>
      PassViewModel(
        tripId: 'AV9201',
        passRepository: repository,
        codeSource: IssuedTokenPassCodeSource(repository),
        displayGuard: display,
        postureChecker: FakeDevicePostureChecker(const DevicePosture.trusted()),
        clockTrust: trust,
        analyticsEmitter: FakeAnalyticsEmitter(),
        clock: clock,
        // Polls are driven by hand. Ticks are too, unless a test asks for a
        // real ticker.
        tick: tick,
        statusPollInterval: const Duration(hours: 1),
        observeLifecycle: false,
      );

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 50));

  String? payload(PassViewModel vm) => switch (vm.state) {
    PassShowing(:final code) => code.payload,
    _ => null,
  };

  test('issues by flight code and shows the token', () async {
    backend.enqueue(_pase('c-1', _t0));
    final vm = build();
    await settle();
    expect(payload(vm), 'tok-1');
    expect(backend.requests.single.data, {'codigo_vuelo': 'AV9201'});
    vm.dispose();
  });

  test('at the renewal time the code is replaced without a tap', () async {
    backend.enqueue(_pase('c-1', _t0));
    final vm = build(tick: const Duration(milliseconds: 5));
    await settle();
    backend.enqueue(
      _pase('c-2', _t0.add(const Duration(seconds: 40)), token: 'tok-2'),
    );
    // The ticker notices the renewal time on its own.
    advance(const Duration(seconds: 40));
    await settle();
    expect(payload(vm), 'tok-2');
    expect(vm.rotations, 1);
    // The ViewModel now holds the renewed pass, so its expiry is c-2's.
    advance(const Duration(seconds: 10));
    vm.onAppResumed();
    await settle();
    expect(payload(vm), 'tok-2');
    vm.dispose();
  });

  test('a failed renewal keeps the code until expira_at, then none', () async {
    backend.enqueue(_pase('c-1', _t0));
    final vm = build();
    await settle();

    backend.enqueueFailure(_offline());
    advance(const Duration(seconds: 40));
    vm.onAppResumed();
    await settle();
    expect(payload(vm), 'tok-1');
    expect(vm.renewalPending, isTrue);

    backend.enqueueFailure(_offline());
    advance(const Duration(seconds: 5));
    vm.onAppResumed();
    await settle();
    expect(vm.state, isA<PassUnavailable>());
    expect(payload(vm), isNull);
    expect(display.on, isFalse);
    vm.dispose();
  });

  test('CONSUMIDA is boarded, and renewal stops', () async {
    backend.enqueue(_pase('c-1', _t0));
    final vm = build();
    await settle();
    backend.enqueue(_detalle('c-1', 'CONSUMIDA'));
    await vm.pollStatus();
    expect(vm.state, isA<PassBoardedView>());
    final sent = backend.requests.length;
    advance(const Duration(seconds: 40));
    vm.onAppResumed();
    await settle();
    expect(backend.requests.length, sent);
    vm.dispose();
  });

  test('403 DOCUMENTO_VENCIDO is its own reason, not a failure', () async {
    backend.enqueue(ScriptedResponse.error('documento_vencido_pase'));
    final vm = build();
    await settle();
    expect(
      (vm.state as PassUnavailable).reason,
      PassUnavailableReason.documentExpired,
    );
    vm.dispose();
  });

  test('403 IDENTIDAD_NO_ACTIVA is its own reason', () async {
    backend.enqueue(ScriptedResponse.error('identidad_no_activa'));
    final vm = build();
    await settle();
    expect(
      (vm.state as PassUnavailable).reason,
      PassUnavailableReason.identityNotActive,
    );
    vm.dispose();
  });
}
