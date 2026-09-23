// 008-identidad-activa T015: CredentialActivatedViewModel — consumes the
// one-time hand-off (research.md §4) and emits the screen's funnel events
// with enum payloads only (contracts/analytics-events.md).
import 'package:aeropass_app/app/activated_credential_handoff.dart';
import 'package:aeropass_app/domain/entities/activated_credential.dart';
import 'package:aeropass_app/features/enrollment/credential_activated/credential_activated_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_screen_capture_guard.dart';

final _credential = ActivatedCredential(
  holderName: 'Mateo González Restrepo',
  documentLast4: '7890',
  issuingCountry: 'COL',
  issuedAt: DateTime.utc(2026, 9, 16),
  validUntil: DateTime.utc(2031, 9, 16),
);

void main() {
  late ActivatedCredentialHandoff handoff;
  late FakeAnalyticsEmitter analytics;
  late FakeScreenCaptureGuard guard;

  setUp(() {
    handoff = ActivatedCredentialHandoff();
    analytics = FakeAnalyticsEmitter();
    guard = FakeScreenCaptureGuard();
  });

  CredentialActivatedViewModel build() => CredentialActivatedViewModel(
    handoff: handoff,
    analyticsEmitter: analytics,
    screenCaptureGuard: guard,
  );

  List<String> eventNames() => analytics.events.map((e) => e.name).toList();

  test('consumes the hand-off exactly once on creation', () {
    handoff.set(_credential);

    final viewModel = build();

    expect(viewModel.credential, _credential);
    expect(handoff.hasCredential, isFalse);
    expect(build().credential, isNull);
  });

  test(
    'emits credential_activated_shown once when a credential is present',
    () {
      handoff.set(_credential);

      build();

      expect(eventNames(), ['credential_activated_shown']);
    },
  );

  test('emits nothing when the hand-off was empty', () {
    final viewModel = build();

    expect(viewModel.credential, isNull);
    expect(analytics.events, isEmpty);
  });

  for (final (action, route) in [
    ('goToTrips', 'trips'),
    ('openCredentialDetail', 'credentialDetail'),
    ('onBackGesture', 'backGestureToTrips'),
  ]) {
    test('$action emits its onward route exactly once', () {
      handoff.set(_credential);
      final viewModel = build();
      analytics.events.clear();

      void call() => switch (action) {
        'goToTrips' => viewModel.goToTrips(),
        'openCredentialDetail' => viewModel.openCredentialDetail(),
        _ => viewModel.onBackGesture(),
      };
      call();
      call();

      expect(analytics.events, hasLength(1));
      expect(analytics.events.single.name, 'credential_activated_route_taken');
      expect(analytics.events.single.payload, {'route': route});
    });
  }

  test('only the first exit is recorded', () {
    handoff.set(_credential);
    final viewModel = build();
    analytics.events.clear();

    viewModel.goToTrips();
    viewModel.onBackGesture();

    expect(analytics.events.single.payload, {'route': 'trips'});
  });

  test('onShown blocks screen capture and onHidden releases it', () async {
    handoff.set(_credential);
    final viewModel = build();

    await viewModel.onShown();
    await viewModel.onHidden();

    expect(guard.enableCount, 1);
    expect(guard.disableCount, 1);
  });

  test('a failing screen capture guard never throws out of onShown', () async {
    handoff.set(_credential);
    guard = FakeScreenCaptureGuard(enableThrows: true);
    final viewModel = build();

    await expectLater(viewModel.onShown(), completes);
  });
}
