import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import '../../../app/enrollment_session_controller.dart';
import '../../../core/command.dart';
import '../../../core/result.dart';
import '../../../domain/entities/credential_status.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/credential_repository.dart';
import '../../../domain/repositories/device_capability_checker.dart';
import 'welcome_view_state.dart';

/// The welcome screen's ViewModel: classifies launch-time credential
/// status and device capability into [WelcomeViewState], and exposes the
/// screen's three actions as [Command]s.
///
/// No `package:flutter/material.dart` import, no widget — testable
/// headless (Constitution Principle VIII). All four dependencies are
/// constructor-injected (Principle IX); this class never reaches into a
/// service locator.
class WelcomeViewModel extends ChangeNotifier {
  WelcomeViewModel({
    required CredentialRepository credentialRepository,
    required DeviceCapabilityChecker deviceCapabilityChecker,
    required EnrollmentSessionController enrollmentSessionController,
    required AnalyticsEmitter analyticsEmitter,
  }) : _credentialRepository = credentialRepository,
       _deviceCapabilityChecker = deviceCapabilityChecker,
       _enrollmentSessionController = enrollmentSessionController,
       _analyticsEmitter = analyticsEmitter {
    primaryAction = Command0(_activatePrimaryAction);
    secondaryAction = Command0(_activateSecondaryAction);
    openPrivacyTerms = Command0(_openPrivacyTerms);
    unawaited(_load());
  }

  final CredentialRepository _credentialRepository;
  final DeviceCapabilityChecker _deviceCapabilityChecker;
  final EnrollmentSessionController _enrollmentSessionController;
  final AnalyticsEmitter _analyticsEmitter;

  /// Advances to the consent step (FR-004). Creates exactly one
  /// `EnrollmentSession` even under a repeated/concurrent activation —
  /// guaranteed structurally by [Command]'s own re-entrancy guard plus
  /// [EnrollmentSessionController.startOrResume]'s idempotence.
  late final Command0<void> primaryAction;

  /// Opens the credential-recovery path for a passenger who already has
  /// an account but is on a new device (US2, Acceptance Scenario 3).
  late final Command0<void> secondaryAction;

  /// Opens the plain-language privacy/data-handling terms (US3). MUST
  /// NOT create an `EnrollmentSession`.
  late final Command0<void> openPrivacyTerms;

  WelcomeViewState _state = const WelcomeViewState.checking();
  WelcomeViewState get state => _state;

  void _setState(WelcomeViewState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> _load() async {
    final capability = await _deviceCapabilityChecker.check();
    if (!capability.canEnroll) {
      final reason = !capability.hasUsableCamera
          ? DeviceUnsupportedReason.noCamera
          : DeviceUnsupportedReason.unsupportedOs;
      _analyticsEmitter.welcomeDeviceUnsupportedShown(reason);
      _setState(WelcomeViewState.deviceUnsupported(reason: reason));
      return;
    }

    final result = await _credentialRepository.getStatus();
    final status = result.when(
      ok: (value) => value,
      error: (_, _) =>
          const CredentialStatus.unreachable(lastKnownStatus: null),
    );
    final next = _deriveViewState(status);
    if (next is WelcomeViewContent) {
      _analyticsEmitter.welcomeScreenShown(next.variant);
    }
    _setState(next);
  }

  WelcomeViewState _deriveViewState(CredentialStatus status) {
    return switch (status) {
      Valid() =>
        // FR-005: never rendered for a confirmed-valid credential — the
        // router redirects away. This state keeps the view in its
        // "checking" presentation rather than flashing first-run content.
        const WelcomeViewState.checking(),
      NoCredential() => WelcomeViewState.content(variant: _firstRunOrResume()),
      ExpiredOrRevoked(:final reason) => WelcomeViewState.content(
        variant: WelcomeScreenVariant.reenrollmentRequired,
        expiryReason: reason,
      ),
      Unreachable(lastKnownStatus: final last) => _deriveFromLastKnown(last),
    };
  }

  WelcomeViewState _deriveFromLastKnown(CredentialStatus? lastKnownStatus) {
    return switch (lastKnownStatus) {
      Valid() =>
        // FR-007 / Edge Cases: don't drop a previously-valid passenger
        // into first-run onboarding on the strength of a network
        // failure — the router routes them to trips with an
        // unrefreshed indicator instead.
        const WelcomeViewState.checking(),
      ExpiredOrRevoked(:final reason) => WelcomeViewState.content(
        variant: WelcomeScreenVariant.reenrollmentRequired,
        unrefreshed: true,
        expiryReason: reason,
      ),
      NoCredential() || Unreachable() || null => WelcomeViewState.content(
        variant: _firstRunOrResume(),
        unrefreshed: true,
      ),
    };
  }

  WelcomeScreenVariant _firstRunOrResume() {
    return _enrollmentSessionController.current != null
        ? WelcomeScreenVariant.resumeOffered
        : WelcomeScreenVariant.firstRun;
  }

  WelcomeScreenVariant _activeVariant() {
    final state = _state;
    return state is WelcomeViewContent
        ? state.variant
        : WelcomeScreenVariant.firstRun;
  }

  Future<Result<void>> _activatePrimaryAction() async {
    final alreadyInProgress = _enrollmentSessionController.current != null;
    _enrollmentSessionController.startOrResume();
    if (!alreadyInProgress) {
      // FR-013 / analytics-events.md: once per *created* session — a
      // resumed (already in-progress) session does not re-emit.
      _analyticsEmitter.welcomePrimaryActionTapped(_activeVariant());
    }
    return const Result.ok(null);
  }

  Future<Result<void>> _activateSecondaryAction() async {
    _analyticsEmitter.welcomeSecondaryActionTapped();
    return const Result.ok(null);
  }

  Future<Result<void>> _openPrivacyTerms() async {
    _analyticsEmitter.welcomePrivacyTermsOpened();
    return const Result.ok(null);
  }

  @override
  void dispose() {
    primaryAction.dispose();
    secondaryAction.dispose();
    openPrivacyTerms.dispose();
    super.dispose();
  }
}
