import 'package:aeropass_app/app/enrollment_session_controller.dart';
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/credential_status.dart';
import 'package:aeropass_app/domain/entities/device_capability.dart';
import 'package:aeropass_app/domain/entities/welcome_content_variant.dart';
import 'package:aeropass_app/features/enrollment/welcome/welcome_view_state.dart';
import 'package:aeropass_app/features/enrollment/welcome/welcome_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics_emitter.dart';
import '../fakes/fake_credential_repository.dart';
import '../fakes/fake_device_capability_checker.dart';

class _FixedClock implements Clock {
  _FixedClock(this._now);
  final DateTime _now;
  @override
  DateTime now() => _now;
}

void main() {
  late FakeCredentialRepository credentialRepository;
  late FakeDeviceCapabilityChecker deviceCapabilityChecker;
  late FakeAnalyticsEmitter analyticsEmitter;
  late EnrollmentSessionController sessionController;

  setUp(() {
    credentialRepository = FakeCredentialRepository();
    deviceCapabilityChecker = FakeDeviceCapabilityChecker();
    analyticsEmitter = FakeAnalyticsEmitter();
    sessionController = EnrollmentSessionController(
      clock: _FixedClock(DateTime.utc(2026, 1, 1)),
    );
  });

  WelcomeViewModel buildViewModel() {
    return WelcomeViewModel(
      credentialRepository: credentialRepository,
      deviceCapabilityChecker: deviceCapabilityChecker,
      enrollmentSessionController: sessionController,
      analyticsEmitter: analyticsEmitter,
    );
  }

  group('User Story 1: first-time passenger (T021)', () {
    test('NoCredential renders first_run content', () async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      final viewModel = buildViewModel();

      await pumpEventQueue();

      expect(
        viewModel.state,
        const WelcomeViewState.content(variant: WelcomeScreenVariant.firstRun),
      );
    });

    test('requests no permission and transmits no data prior to the primary '
        'action (only the launch-time credential check runs)', () async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      expect(credentialRepository.callCount, 1);
      expect(sessionController.current, isNull);
      expect(analyticsEmitter.events.map((e) => e.name), [
        'welcome_screen_shown',
      ]);
      expect(viewModel.state, isA<WelcomeViewContent>());
    });

    test('activating the primary action creates exactly one EnrollmentSession '
        'under a repeated/concurrent activation (FR-004)', () async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      // Concurrent double-tap: fire both without awaiting the first.
      final first = viewModel.primaryAction.run();
      final second = viewModel.primaryAction.run();
      await Future.wait([first, second]);

      expect(sessionController.current, isNotNull);
      final sessionId = sessionController.current!.id;
      expect(
        analyticsEmitter.events
            .where((e) => e.name == 'welcome_primary_action_tapped')
            .length,
        1,
      );

      // A later, separate tap does not create a second session or emit
      // a second event.
      await viewModel.primaryAction.run();
      expect(sessionController.current!.id, sessionId);
      expect(
        analyticsEmitter.events
            .where((e) => e.name == 'welcome_primary_action_tapped')
            .length,
        1,
      );
    });

    test(
      'FR-012: no usable camera shows the device-unsupported state',
      () async {
        deviceCapabilityChecker.response = const DeviceCapability(
          hasUsableCamera: false,
          osVersionSupported: true,
        );
        final viewModel = buildViewModel();
        await pumpEventQueue();

        expect(
          viewModel.state,
          const WelcomeViewState.deviceUnsupported(
            reason: DeviceUnsupportedReason.noCamera,
          ),
        );
        expect(
          analyticsEmitter.events.map((e) => e.name),
          contains('welcome_device_unsupported_shown'),
        );
      },
    );

    test('FR-012: unsupported OS shows the device-unsupported state', () async {
      deviceCapabilityChecker.response = const DeviceCapability(
        hasUsableCamera: true,
        osVersionSupported: false,
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      expect(
        viewModel.state,
        const WelcomeViewState.deviceUnsupported(
          reason: DeviceUnsupportedReason.unsupportedOs,
        ),
      );
    });
  });

  group('User Story 2: returning passenger (T031)', () {
    test('Valid status never renders welcome content (FR-005)', () async {
      credentialRepository.scriptResponse(
        Result.ok(CredentialStatus.valid(validUntil: DateTime.utc(2027))),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      expect(viewModel.state, const WelcomeViewState.checking());
      expect(
        analyticsEmitter.events.where((e) => e.name == 'welcome_screen_shown'),
        isEmpty,
      );
    });

    test('ExpiredOrRevoked renders reenrollment_required, distinct from first_run (FR-006)', () async {
      credentialRepository.scriptResponse(
        const Result.ok(
          CredentialStatus.expiredOrRevoked(reason: ExpiryReason.revoked),
        ),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      final state = viewModel.state;
      expect(state, isA<WelcomeViewContent>());
      expect(
        (state as WelcomeViewContent).variant,
        WelcomeScreenVariant.reenrollmentRequired,
      );
      expect(state.expiryReason, ExpiryReason.revoked);
      expect(state.unrefreshed, isFalse);
    });

    test('Unreachable with a last-known-valid status defers to the router '
        '(does not treat the passenger as unenrolled, FR-007)', () async {
      credentialRepository.scriptResponse(
        Result.ok(
          CredentialStatus.unreachable(
            lastKnownStatus: CredentialStatus.valid(
              validUntil: DateTime.utc(2027),
            ),
          ),
        ),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      expect(viewModel.state, const WelcomeViewState.checking());
    });

    test('Unreachable with a last-known expired/revoked status shows '
        'reenrollment content marked unrefreshed (FR-007)', () async {
      credentialRepository.scriptResponse(
        const Result.ok(
          CredentialStatus.unreachable(
            lastKnownStatus: CredentialStatus.expiredOrRevoked(
              reason: ExpiryReason.expired,
            ),
          ),
        ),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      final state = viewModel.state as WelcomeViewContent;
      expect(state.variant, WelcomeScreenVariant.reenrollmentRequired);
      expect(state.unrefreshed, isTrue);
    });

    test(
      'Unreachable with no last-known status presents first-run content '
      'marked unrefreshed rather than a blank/error screen (FR-007)',
      () async {
        credentialRepository.scriptResponse(
          const Result.ok(CredentialStatus.unreachable(lastKnownStatus: null)),
        );
        final viewModel = buildViewModel();
        await pumpEventQueue();

        final state = viewModel.state as WelcomeViewContent;
        expect(state.variant, WelcomeScreenVariant.firstRun);
        expect(state.unrefreshed, isTrue);
      },
    );

    test('secondary action emits welcome_secondary_action_tapped', () async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      await viewModel.secondaryAction.run();

      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('welcome_secondary_action_tapped'),
      );
      expect(sessionController.current, isNull);
    });
  });

  group('User Story 3: privacy-cautious passenger (T041)', () {
    test('opening the privacy terms emits welcome_privacy_terms_opened and '
        'creates no EnrollmentSession', () async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      final viewModel = buildViewModel();
      await pumpEventQueue();

      await viewModel.openPrivacyTerms.run();

      expect(
        analyticsEmitter.events.map((e) => e.name),
        contains('welcome_privacy_terms_opened'),
      );
      expect(sessionController.current, isNull);
    });
  });

  group('Polish: mid-enrollment resume (T046)', () {
    test('a session already in progress (process-alive) renders '
        'resume_offered instead of first_run', () async {
      credentialRepository.scriptResponse(
        const Result.ok(CredentialStatus.noCredential()),
      );
      sessionController.startOrResume();

      final viewModel = buildViewModel();
      await pumpEventQueue();

      expect(
        viewModel.state,
        const WelcomeViewState.content(
          variant: WelcomeScreenVariant.resumeOffered,
        ),
      );
      expect(
        analyticsEmitter.events,
        contains(
          isA<RecordedAnalyticsEvent>()
              .having((e) => e.name, 'name', 'welcome_screen_shown')
              .having((e) => e.payload['variant'], 'variant', 'resumeOffered'),
        ),
      );
    });
  });
}
