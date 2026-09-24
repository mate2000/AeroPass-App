import 'dart:async' show Timer, unawaited;

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/activated_credential_handoff.dart';
import '../../../app/enrollment_session_controller.dart';
import '../../../app/pending_document_controller.dart';
import '../../../app/technical_error_controller.dart';
import '../../../core/clock.dart';
import '../../../core/diagnostics.dart';
import '../../../core/result.dart';
import '../../../domain/entities/capture_attempt_counter.dart';
import '../../../domain/entities/issuance_outcome.dart';
import '../../../domain/entities/service_failure.dart';
import '../../../domain/entities/transport_failure.dart';
import '../../../domain/entities/verification_job_status.dart';
import '../../../domain/entities/verification_outcome.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/capture_attempt_counter_repository.dart';
import '../../../domain/repositories/credential_issuance_repository.dart';
import '../../../domain/repositories/verification_job_repository.dart';

part 'verification_progress_viewmodel.freezed.dart';

/// How often the job is polled (research.md §3).
const verificationPollInterval = Duration(seconds: 1);

/// FR-009 (Clarifications): the "taking longer than usual" notice.
const verificationSlowNoticeAfter = Duration(seconds: 10);

/// FR-009 (Clarifications): the hard timeout, inside the constitution's
/// 60-second contingency budget.
const verificationHardTimeoutAfter = Duration(seconds: 30);

/// FR-013 (Clarifications): how long a failure stays on screen before the
/// flow routes onward.
const verificationFailureDisplayPause = Duration(milliseconds: 1500);

/// What the verification screen renders (data-model.md).
@freezed
sealed class VerificationProgressViewState
    with _$VerificationProgressViewState {
  /// The wait: every stage's status, and whether the slow notice shows.
  const factory VerificationProgressViewState.waiting({
    required Map<VerificationStage, StageStatus> stages,
    required bool slowNoticeVisible,
  }) = VerificationWaiting;

  /// A failure being shown on [failedStage] for the failure pause, before
  /// routing (FR-013). The same state for every failure class (FR-012).
  const factory VerificationProgressViewState.failed({
    required Map<VerificationStage, StageStatus> stages,
    required VerificationStage failedStage,
  }) = VerificationFailed;
}

/// Where the screen goes next: a one-shot target the view acts on, then
/// clears via [VerificationProgressViewModel.consumeNavigation].
enum VerificationNavigationTarget {
  credentialActivated,
  credentialNotActive,
  documentCapture,
  retryGuidance,
  technicalError,

  /// 015 FR-009: manual review, 010.
  agentEscalation,
}

/// Screen 07's ViewModel (007-validando). Replaces 008's placeholder
/// view model while keeping its hand-off (research.md §12).
///
/// It **observes** the backend job and never submits anything (FR-010,
/// research.md §1). Stages advance only when reported, and never backwards
/// (FR-003). The issuance stage is marked passed in exactly one place, the
/// `IssuanceActivated` branch, which is also the only place 008's hand-off
/// is set (FR-005, research.md §2). Every terminal result goes through
/// [_route], the table in contracts/outcome-routing.md. Timers bound the
/// wait and never advance it (FR-004, research.md §5).
///
/// No `package:flutter/material.dart` import (Principle VIII).
class VerificationProgressViewModel extends ChangeNotifier {
  VerificationProgressViewModel({
    required VerificationJobRepository jobRepository,
    required CredentialIssuanceRepository issuanceRepository,
    required ActivatedCredentialHandoff handoff,
    required EnrollmentSessionController enrollmentSessionController,
    required PendingDocumentController pendingDocumentController,
    required CaptureAttemptCounterRepository attemptCounterRepository,
    required AnalyticsEmitter analyticsEmitter,
    required TechnicalErrorController technicalErrorController,
    required Clock clock,
    @visibleForTesting Duration pollInterval = verificationPollInterval,
    @visibleForTesting Duration slowNoticeAfter = verificationSlowNoticeAfter,
    @visibleForTesting Duration hardTimeoutAfter = verificationHardTimeoutAfter,
    @visibleForTesting
    Duration failureDisplayPause = verificationFailureDisplayPause,
  }) : _jobRepository = jobRepository,
       _issuanceRepository = issuanceRepository,
       _handoff = handoff,
       _enrollmentSessionController = enrollmentSessionController,
       _pendingDocumentController = pendingDocumentController,
       _attemptCounterRepository = attemptCounterRepository,
       _analyticsEmitter = analyticsEmitter,
       _technicalErrorController = technicalErrorController,
       _clock = clock,
       _pollInterval = pollInterval,
       _slowNoticeAfter = slowNoticeAfter,
       _hardTimeoutAfter = hardTimeoutAfter,
       _failureDisplayPause = failureDisplayPause,
       _openedAt = clock.now() {
    _analyticsEmitter.verificationStepEntered();
    _slowNoticeTimer = Timer(_slowNoticeAfter, _showSlowNotice);
    _hardTimeoutTimer = Timer(_hardTimeoutAfter, _onHardTimeout);
    unawaited(_poll());
  }

  final VerificationJobRepository _jobRepository;
  final CredentialIssuanceRepository _issuanceRepository;
  final ActivatedCredentialHandoff _handoff;
  final EnrollmentSessionController _enrollmentSessionController;
  final PendingDocumentController _pendingDocumentController;
  final CaptureAttemptCounterRepository _attemptCounterRepository;
  final AnalyticsEmitter _analyticsEmitter;
  final TechnicalErrorController _technicalErrorController;
  final Clock _clock;
  final Duration _pollInterval;
  final Duration _slowNoticeAfter;
  final Duration _hardTimeoutAfter;
  final Duration _failureDisplayPause;
  final DateTime _openedAt;

  final Map<VerificationStage, StageStatus> _stages = {
    for (final stage in VerificationStage.values) stage: StageStatus.pending,
  };
  bool _slowNoticeVisible = false;
  VerificationStage? _failedStage;

  /// The job has reached a terminal result: polling has stopped.
  bool _jobSettled = false;

  /// The route onward has been decided: every timer is moot.
  bool _decided = false;
  bool _polling = false;
  bool _disposed = false;

  /// 011 research.md §2: whether any poll has run, and whether every one of
  /// them failed to reach the server. Only then is a timeout the
  /// connection's fault.
  bool _anyPollCompleted = false;
  bool _everyPollUnreachable = true;

  Timer? _pollTimer;
  Timer? _slowNoticeTimer;
  Timer? _hardTimeoutTimer;
  Timer? _pauseTimer;

  VerificationProgressViewState get state {
    final stages = Map<VerificationStage, StageStatus>.unmodifiable(_stages);
    final failed = _failedStage;
    return failed == null
        ? VerificationProgressViewState.waiting(
            stages: stages,
            slowNoticeVisible: _slowNoticeVisible,
          )
        : VerificationProgressViewState.failed(
            stages: stages,
            failedStage: failed,
          );
  }

  VerificationNavigationTarget? _pendingNavigation;
  VerificationNavigationTarget? get pendingNavigation => _pendingNavigation;

  void consumeNavigation() {
    _pendingNavigation = null;
  }

  /// "Seguir esperando": hides the notice; the wait and its timeout continue.
  void dismissSlowNotice() {
    if (!_slowNoticeVisible) return;
    _slowNoticeVisible = false;
    _notify();
  }

  /// "Ayuda" was tapped from the notice (FR-018).
  void onHelpOpened() {
    _analyticsEmitter.verificationHelpOpened();
  }

  /// Research.md §5: on return from the background, trust the wall clock,
  /// not a timer that may have been paused, and poll at once.
  Future<void> onAppResumed() async {
    if (_decided || _disposed) return;
    final elapsed = _clock.now().difference(_openedAt);
    if (elapsed >= _hardTimeoutAfter) {
      _onHardTimeout();
      return;
    }
    if (elapsed >= _slowNoticeAfter) _showSlowNotice();
    await _poll();
  }

  // --- Polling ------------------------------------------------------------

  Future<void> _poll() async {
    if (_jobSettled || _decided || _disposed || _polling) return;
    _polling = true;
    _pollTimer?.cancel();
    final result = await _jobRepository.getStatus();
    _polling = false;
    if (_jobSettled || _decided || _disposed) return;

    _anyPollCompleted = true;
    if (result case Error(:final error) when error is ConnectivityFailure) {
      // Still consistent with "the connection is the problem".
    } else {
      _everyPollUnreachable = false;
    }

    switch (result) {
      case Ok(
        value: VerificationJobInProgress(
          :final documentCheck,
          :final faceComparison,
        ),
      ):
        _report(VerificationStage.documentCheck, documentCheck);
        _report(VerificationStage.faceComparison, faceComparison);
      case Ok(
        value: VerificationJobCompleted(
          :final outcome,
          :final documentCheck,
          :final faceComparison,
        ),
      ):
        _jobSettled = true;
        _report(VerificationStage.documentCheck, documentCheck);
        _report(VerificationStage.faceComparison, faceComparison);
        unawaited(_onJobCompleted(outcome));
        return;
      case Error():
        // Research.md §3: one failed read is not an outcome.
        break;
    }
    _pollTimer = Timer(_pollInterval, () => unawaited(_poll()));
  }

  static int _rank(StageStatus status) => switch (status) {
    StageStatus.pending => 0,
    StageStatus.running => 1,
    StageStatus.passed => 2,
    StageStatus.failed => 2,
  };

  /// Forward-only (data-model.md invariant): a report that would move a
  /// stage backwards, or change a settled one, is ignored.
  void _report(VerificationStage stage, StageStatus reported) {
    final current = _stages[stage]!;
    if (_rank(reported) <= _rank(current)) return;
    _stages[stage] = reported;
    _analyticsEmitter.verificationStageReached(stage: stage, status: reported);
    _notify();
  }

  // --- Outcomes -------------------------------------------------------------

  Future<void> _onJobCompleted(VerificationOutcome outcome) async {
    if (outcome is VerificationMatched) {
      _report(VerificationStage.documentCheck, StageStatus.passed);
      _report(VerificationStage.faceComparison, StageStatus.passed);
      // 009-reintento FR-017: a verification match is the one point that
      // resets both counters — the passenger got through, and an issuance
      // problem after this is not their attempt.
      final _ = await _attemptCounterRepository.reset(
        AttemptCounterScope.documentCapture,
      );
      final _ = await _attemptCounterRepository.reset(
        AttemptCounterScope.selfieLiveness,
      );
      await _requestIssuance();
      return;
    }
    await _route(outcome);
  }

  /// The third stage is 008's issuance call itself (research.md §2).
  Future<void> _requestIssuance() async {
    _report(VerificationStage.issuance, StageStatus.running);
    _analyticsEmitter.credentialIssuanceRequested();
    final result = await _issuanceRepository.requestIssuance();
    if (_decided || _disposed) return;

    switch (result) {
      case Ok(value: IssuanceActivated(:final credential)):
        _analyticsEmitter.credentialIssuanceOutcome(
          kind: IssuanceOutcomeKind.activated,
        );
        // R1 — the only place the issuance stage is passed and the hand-off
        // is set (FR-005, SC-010).
        _decide();
        _report(VerificationStage.issuance, StageStatus.passed);
        _handoff.set(credential);
        // 011 FR-015: an activation after an earlier technical error this
        // run is that error's resolution; the pacing starts over.
        final sinceFailure = _technicalErrorController.resolve(_clock.now());
        if (sinceFailure != null) {
          _analyticsEmitter.technicalErrorResolved(
            elapsedSeconds: sinceFailure.inSeconds,
          );
        }
        _enrollmentSessionController.clear();
        _emitOutcome(VerificationOutcomeKind.activated);
        _navigateTo(VerificationNavigationTarget.credentialActivated);
      case Ok(value: IssuanceNotActive()):
        _analyticsEmitter.credentialIssuanceOutcome(
          kind: IssuanceOutcomeKind.notActive,
        );
        _fail(
          VerificationStage.issuance,
          VerificationOutcomeKind.notActive,
          VerificationNavigationTarget.credentialNotActive,
        );
      case Ok(value: IssuanceIncomplete()):
        _analyticsEmitter.credentialIssuanceOutcome(
          kind: IssuanceOutcomeKind.incomplete,
        );
        _fail(
          VerificationStage.issuance,
          VerificationOutcomeKind.notActive,
          VerificationNavigationTarget.credentialNotActive,
        );
      case Error(:final error):
        _analyticsEmitter.credentialIssuanceOutcome(
          kind: IssuanceOutcomeKind.transportError,
        );
        // 011 research.md §1: verification passed, so the job is not
        // terminal; the class follows the transport evidence.
        _recordTechnicalError(VerificationStage.issuance, switch (error) {
          ServiceSideFailure() => ServiceFailureClass.service,
          ConnectivityFailure() => ServiceFailureClass.connectivity,
          _ => ServiceFailureClass.undetermined,
        }, jobTerminal: false);
        _fail(
          VerificationStage.issuance,
          VerificationOutcomeKind.serviceFailure,
          VerificationNavigationTarget.technicalError,
        );
    }
  }

  /// Rows R5–R10 of contracts/outcome-routing.md.
  Future<void> _route(VerificationOutcome outcome) async {
    switch (outcome) {
      case VerificationMatched():
        return; // Handled by _requestIssuance.
      case VerificationDocumentRejected():
        _decide();
        final count = await _increment(AttemptCounterScope.documentCapture);
        if (count >= captureAttemptLimit) {
          // 009-reintento FR-017: the limit keeps its count.
          _fail(
            VerificationStage.documentCheck,
            VerificationOutcomeKind.documentRejected,
            VerificationNavigationTarget.retryGuidance,
          );
        } else {
          // Research.md §11: back through capture, confirmation and selfie.
          _enrollmentSessionController.returnToDocumentCapture();
          _pendingDocumentController.clear();
          _fail(
            VerificationStage.documentCheck,
            VerificationOutcomeKind.documentRejected,
            VerificationNavigationTarget.documentCapture,
          );
        }
      case VerificationFaceMismatch() ||
          VerificationLivenessRejected() ||
          VerificationAttackDetected():
        // R7–R9: identical for the passenger and in analytics (FR-012).
        _decide();
        // 009-reintento FR-017: the limit keeps its count; retry guidance
        // reads it and offers no retry once it is reached.
        final _ = await _increment(AttemptCounterScope.selfieLiveness);
        _fail(
          VerificationStage.faceComparison,
          VerificationOutcomeKind.biometricRejected,
          VerificationNavigationTarget.retryGuidance,
        );
      case VerificationManualReview():
        // 015 FR-009: the backend's review state, or no attempts left. The
        // agent path, never a retry, and nothing is counted: the server owns
        // the budget (FR-008).
        _fail(
          VerificationStage.faceComparison,
          VerificationOutcomeKind.biometricRejected,
          VerificationNavigationTarget.agentEscalation,
        );
      case VerificationServiceFailure():
        // R10: the service's fault; no attempt is counted (SC-006). The job
        // can never finish, so 011's retry needs a new selfie.
        final stage = _runningStage();
        _recordTechnicalError(
          stage,
          ServiceFailureClass.service,
          jobTerminal: true,
        );
        _fail(
          stage,
          VerificationOutcomeKind.serviceFailure,
          VerificationNavigationTarget.technicalError,
        );
    }
  }

  Future<int> _increment(AttemptCounterScope scope) async {
    final result = await _attemptCounterRepository.increment(scope);
    return result.valueOrNull?.count ?? 0;
  }

  /// FR-013: mark the stage failed, show the generic failure for the pause,
  /// then route. Every failure class ends here.
  void _fail(
    VerificationStage stage,
    VerificationOutcomeKind kind,
    VerificationNavigationTarget target,
  ) {
    const Diagnostics().warn('verification_failed', {
      'stage': stage.name,
      'kind': kind.name,
      'target': target.name,
      'elapsed_ms': _clock.now().difference(_openedAt).inMilliseconds,
    });
    _decide();
    if (_disposed) return;
    if (_stages[stage] != StageStatus.failed) {
      _stages[stage] = StageStatus.failed;
      _analyticsEmitter.verificationStageReached(
        stage: stage,
        status: StageStatus.failed,
      );
    }
    _failedStage = stage;
    _slowNoticeVisible = false;
    _emitOutcome(kind);
    _notify();
    _pauseTimer = Timer(_failureDisplayPause, () => _navigateTo(target));
  }

  /// The stage a service failure or timeout interrupted: the one running, or
  /// the first not yet passed.
  VerificationStage _runningStage() {
    for (final stage in VerificationStage.values) {
      if (_stages[stage] == StageStatus.running) return stage;
    }
    return VerificationStage.values.firstWhere(
      (stage) => _stages[stage] != StageStatus.passed,
      orElse: () => VerificationStage.issuance,
    );
  }

  // --- Timers ---------------------------------------------------------------

  void _showSlowNotice() {
    if (_decided || _disposed || _slowNoticeVisible) return;
    _slowNoticeTimer?.cancel();
    _slowNoticeVisible = true;
    _analyticsEmitter.verificationSlowNoticeShown();
    _notify();
  }

  /// R11: the wait ends on the technical-error path; nothing is counted.
  void _onHardTimeout() {
    if (_decided || _disposed) return;
    _analyticsEmitter.verificationTimedOut();
    final stage = _runningStage();
    // 011 FR-010: a timeout asserts a cause only when every read failed to
    // reach the server.
    _recordTechnicalError(
      stage,
      _anyPollCompleted && _everyPollUnreachable
          ? ServiceFailureClass.connectivity
          : ServiceFailureClass.undetermined,
      jobTerminal: false,
    );
    _fail(
      stage,
      VerificationOutcomeKind.timedOut,
      VerificationNavigationTarget.technicalError,
    );
  }

  // --- Plumbing -------------------------------------------------------------

  /// 011 contracts/technical-error-routing.md: hands the failure to screen
  /// 11. Touches no attempt counter (FR-002).
  void _recordTechnicalError(
    VerificationStage stage,
    ServiceFailureClass failureClass, {
    required bool jobTerminal,
  }) {
    _technicalErrorController.record(
      ServiceFailure(
        failureClass: failureClass,
        stage: stage,
        jobTerminal: jobTerminal,
        occurredAt: _clock.now(),
      ),
    );
  }

  void _decide() {
    _decided = true;
    _jobSettled = true;
    _pollTimer?.cancel();
    _slowNoticeTimer?.cancel();
    _hardTimeoutTimer?.cancel();
  }

  bool _outcomeEmitted = false;

  void _emitOutcome(VerificationOutcomeKind kind) {
    if (_outcomeEmitted) return;
    _outcomeEmitted = true;
    _analyticsEmitter.verificationOutcome(
      kind: kind,
      elapsedSeconds: _clock.now().difference(_openedAt).inSeconds,
    );
  }

  void _navigateTo(VerificationNavigationTarget target) {
    if (_disposed) return;
    _pendingNavigation = target;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    _slowNoticeTimer?.cancel();
    _hardTimeoutTimer?.cancel();
    _pauseTimer?.cancel();
    super.dispose();
  }
}
