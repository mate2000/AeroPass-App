// 015 T077 (DEC-03, FR-010, V-06): with no trips source, Mis viajes asks
// for the flight code. The backend's format is checked on the device, a
// malformed code sends nothing, and a valid one reaches the pass through the
// in-memory hand-off.
import 'package:aeropass_app/app/flight_code_handoff.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/credential_summary.dart';
import 'package:aeropass_app/features/trips/trips_home_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_credential_summary_repository.dart';

CredentialSummary _summary({bool confirmed = true}) => CredentialSummary(
  holderName: 'Ana Prueba',
  documentLast4: '4050',
  state: CredentialDisplayState.active,
  confirmed: confirmed,
);

void main() {
  late FakeCredentialSummaryRepository summaries;
  late FlightCodeHandoff handoff;

  setUp(() {
    summaries = FakeCredentialSummaryRepository();
    handoff = FlightCodeHandoff();
  });

  Future<TripsHomeViewModel> build({CredentialSummary? summary}) async {
    summaries.scriptResults([Result.ok(summary ?? _summary())]);
    final vm = TripsHomeViewModel(
      summaryRepository: summaries,
      tripRepository: null,
      analyticsEmitter: FakeAnalyticsEmitter(),
      clock: FakeClock(),
      flightCodeHandoff: handoff,
      refreshInterval: const Duration(hours: 1),
      actionTick: const Duration(hours: 1),
      observeLifecycle: false,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return vm;
  }

  test('no trips source means flight-code entry, not an error', () async {
    final vm = await build();
    expect(vm.flightCodeEntry, isTrue);
    expect(vm.tripsUnavailable, isTrue);
    expect(vm.canShowPass, isTrue);
    vm.dispose();
  });

  test('a valid code is normalized and handed to the pass', () async {
    final vm = await build();
    vm
      ..onFlightCodeChanged('av 9201')
      ..showPass();
    expect(vm.flightCodeInvalid, isFalse);
    expect(handoff.code?.value, 'AV9201');
    expect(vm.pendingNavigation, TripsHomeTarget.viewPass);
    vm.dispose();
  });

  test('a malformed code is marked, and nothing is handed on', () async {
    final vm = await build();
    vm
      ..onFlightCodeChanged('AV 92011X')
      ..showPass();
    expect(vm.flightCodeInvalid, isTrue);
    expect(handoff.code, isNull);
    expect(vm.pendingNavigation, isNull);

    vm.onFlightCodeChanged('AV9201');
    expect(vm.flightCodeInvalid, isFalse, reason: 'typing clears the mark');
    vm.dispose();
  });

  test('an unconfirmed credential cannot show a pass', () async {
    final vm = await build(summary: _summary(confirmed: false));
    vm
      ..onFlightCodeChanged('AV9201')
      ..showPass();
    expect(vm.canShowPass, isFalse);
    expect(handoff.code, isNull);
    vm.dispose();
  });
}
