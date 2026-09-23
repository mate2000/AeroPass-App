import 'dart:async' show Timer, unawaited;

import 'package:flutter/foundation.dart';

import '../../../app/enrollment_session_controller.dart';
import '../../../app/technical_error_controller.dart';
import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../../../domain/entities/service_failure.dart';
import '../../../domain/entities/service_status.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/operational_alert_reporter.dart';
import '../../../domain/repositories/service_status_repository.dart';

/// 011 research.md §6: how often the live status is read while screen 11 is
/// open.
const technicalErrorStatusPollInterval = Duration(seconds: 15);

/// How often a held "Reintentar" refreshes its countdown.
const technicalErrorCountdownTick = Duration(seconds: 1);

/// Where screen 11 goes next: a one-shot target the view acts on.
enum TechnicalErrorTarget { verification, selfie, welcome }

/// Screen 11's ViewModel (011-error-tecnico, data-model.md).
///
/// Every claim it exposes has a source. The wording follows the failure
/// class 007 recorded, and is `undetermined` when nothing was recorded. The
/// status comes only from a successful live read. The notification claim
/// needs a `service` failure and a reporter that can back it. The
/// preservation statement needs a confirmed identity record.
///
/// It never touches an attempt counter (FR-002) or any capture (FR-005).
/// No `package:flutter/material.dart` import (Principle VIII).
class TechnicalErrorViewModel extends ChangeNotifier {
  TechnicalErrorViewModel({
    required TechnicalErrorController technicalErrorController,
    required EnrollmentSessionController enrollmentSessionController,
    required ServiceStatusRepository statusRepository,
    required OperationalAlertReporter alertReporter,
    required AnalyticsEmitter analyticsEmitter,
    required Clock clock,
    @visibleForTesting
    Duration statusPollInterval = technicalErrorStatusPollInterval,
    @visibleForTesting Duration countdownTick = technicalErrorCountdownTick,
  }) : _statusRepository = statusRepository,
       _analyticsEmitter = analyticsEmitter,
       _clock = clock,
       _countdownTick = countdownTick,
       _failure = technicalErrorController.current,
       _showPreservation =
           enrollmentSessionController.current?.identityConfirmed ?? false,
       _canClaimNotification = alertReporter.canClaimNotification {
    final now = clock.now();
    _arrival = technicalErrorController.arrivals + 1;
    _scheduledRetryAt = now.add(technicalErrorController.registerArrival());

    final failure = _failure;
    if (failure != null && technicalErrorController.takeReportable()) {
      alertReporter.reportServiceFailure(stage: failure.stage);
    }
    _analyticsEmitter.technicalErrorShown(
      failureClass: failureClass,
      stage: failure?.stage,
      jobTerminal: needsNewSelfie,
    );

    _statusTimer = Timer.periodic(
      statusPollInterval,
      (_) => unawaited(_readStatus()),
    );
    unawaited(_readStatus());
    _startCountdownIfHeld();
  }

  final ServiceStatusRepository _statusRepository;
  final AnalyticsEmitter _analyticsEmitter;
  final Clock _clock;
  final Duration _countdownTick;
  final ServiceFailure? _failure;
  final bool _showPreservation;
  final bool _canClaimNotification;

  late final int _arrival;
  late final DateTime _scheduledRetryAt;
  ServiceStatus? _status;
  bool _statusShownEmitted = false;
  TechnicalErrorTarget? _pendingNavigation;
  bool _disposed = false;
  Timer? _statusTimer;
  Timer? _countdownTimer;

  // --- What the screen says -------------------------------------------------

  ServiceFailureClass get failureClass =>
      _failure?.failureClass ?? ServiceFailureClass.undetermined;

  /// The retry needs a new selfie, and the screen says so first (FR-004).
  bool get needsNewSelfie => _failure?.jobTerminal ?? false;

  /// A confirmed identity record exists, so there is something true to say
  /// was kept (FR-003).
  bool get showPreservation => _showPreservation;

  /// "Nuestro equipo ya fue notificado." (FR-006).
  bool get showNotificationClaim =>
      failureClass == ServiceFailureClass.service && _canClaimNotification;

  /// The latest live status; null means the card is omitted (FR-007).
  ServiceStatus? get status => _status;

  /// The source's own time to try again, when it gave one in the future.
  DateTime? get retryAfter {
    final after = _status?.retryAfter;
    return after != null && after.isAfter(_clock.now()) ? after : null;
  }

  // --- Retry pacing (FR-008) ------------------------------------------------

  DateTime get _retryAvailableAt {
    final after = retryAfter;
    return after != null && after.isAfter(_scheduledRetryAt)
        ? after
        : _scheduledRetryAt;
  }

  /// Time left before "Reintentar" can be used; zero when it can.
  Duration get retryRemaining {
    final remaining = _retryAvailableAt.difference(_clock.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get retryHeld => retryRemaining > Duration.zero;

  /// Whole seconds left, rounded up, for the button and its label.
  int get retryRemainingSeconds =>
      (retryRemaining.inMilliseconds / 1000).ceil();

  // --- Navigation -------------------------------------------------------------

  TechnicalErrorTarget? get pendingNavigation => _pendingNavigation;

  void consumeNavigation() => _pendingNavigation = null;

  /// "Reintentar". Ignored while held. Goes to the selfie when the job can
  /// never finish, and back to 007 otherwise (FR-011).
  void retry() {
    if (retryHeld || _pendingNavigation != null) return;
    final destination = needsNewSelfie
        ? TechnicalErrorRetryDestination.selfie
        : TechnicalErrorRetryDestination.verification;
    _analyticsEmitter.technicalErrorRetry(
      destination: destination,
      arrival: _arrival,
    );
    _navigateTo(switch (destination) {
      TechnicalErrorRetryDestination.selfie => TechnicalErrorTarget.selfie,
      TechnicalErrorRetryDestination.verification =>
        TechnicalErrorTarget.verification,
    });
  }

  /// "Salir". The session and the recorded failure stay intact (FR-012).
  void exit() {
    if (_pendingNavigation != null) return;
    _analyticsEmitter.technicalErrorExit();
    _navigateTo(TechnicalErrorTarget.welcome);
  }

  // --- Internals --------------------------------------------------------------

  Future<void> _readStatus() async {
    final result = await _statusRepository.getStatus();
    if (_disposed) return;
    switch (result) {
      case Ok(:final value):
        _status = value;
        if (!_statusShownEmitted) {
          _statusShownEmitted = true;
          _analyticsEmitter.technicalErrorStatusShown(
            documentScan: value.steps[JourneyStep.documentScan]!,
            selfie: value.steps[JourneyStep.selfie]!,
            issuance: value.steps[JourneyStep.issuance]!,
          );
        }
      case Error():
        // A failed read shows no status rather than a stale one (FR-007).
        _status = null;
    }
    _startCountdownIfHeld();
    _notify();
  }

  void _startCountdownIfHeld() {
    if (_disposed || !retryHeld || _countdownTimer != null) return;
    _countdownTimer = Timer.periodic(_countdownTick, (timer) {
      if (!retryHeld) {
        timer.cancel();
        _countdownTimer = null;
      }
      _notify();
    });
  }

  void _navigateTo(TechnicalErrorTarget target) {
    _pendingNavigation = target;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _statusTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
