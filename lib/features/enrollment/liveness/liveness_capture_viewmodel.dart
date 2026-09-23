import 'dart:async' show Timer, unawaited;

import 'package:camera/camera.dart' show CameraController;
import 'package:flutter/foundation.dart';

import '../../../app/enrollment_session_controller.dart';
import '../../../core/command.dart';
import '../../../core/result.dart';
import '../../../data/services/liveness_camera_service.dart';
import '../../../domain/entities/capture_attempt_counter.dart';
import '../../../domain/entities/liveness_sample_outcome.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/capture_attempt_counter_repository.dart';
import '../../../domain/repositories/liveness_verification_repository.dart';
import 'liveness_capture_view_state.dart';

/// The liveness-capture step's ViewModel (spec.md screen 06): owns
/// `LivenessCameraService`'s lifecycle, runs the `startSession`/
/// `submitSample` loop (research.md §1) on a fixed sampling interval, and
/// relays the port's classification verbatim — FR-002's "the device never
/// decides liveness" boundary holds structurally here: this class never
/// inspects a frame's content, only the `Result` each call returns.
///
/// No `package:flutter/material.dart` import, no widget — testable
/// headless (Constitution Principle VIII). Every dependency is
/// constructor-injected (Principle IX), including [LivenessCameraService]
/// and [LivenessVerificationRepository] specifically so this class is
/// testable without a real camera or network.
class LivenessCaptureViewModel extends ChangeNotifier {
  LivenessCaptureViewModel({
    required LivenessVerificationRepository livenessVerificationRepository,
    required LivenessCameraService livenessCameraService,
    required CaptureAttemptCounterRepository attemptCounterRepository,
    required EnrollmentSessionController enrollmentSessionController,
    required AnalyticsEmitter analyticsEmitter,
    @visibleForTesting
    Duration sampleInterval = const Duration(milliseconds: 200),
    @visibleForTesting Duration stallDuration = const Duration(seconds: 45),
  }) : _livenessVerificationRepository = livenessVerificationRepository,
       _livenessCameraService = livenessCameraService,
       _attemptCounterRepository = attemptCounterRepository,
       _enrollmentSessionController = enrollmentSessionController,
       _analyticsEmitter = analyticsEmitter,
       _sampleInterval = sampleInterval,
       _stallDuration = stallDuration {
    retry = Command0(_retry);
    // FR-001: the router's redirect (research.md §4) is the primary guard;
    // this defensive re-check mirrors 003's/004's identical
    // "defense in depth, and the behavior its own unit tests exercise in
    // isolation" pattern.
    final identityConfirmed =
        _enrollmentSessionController.current?.identityConfirmed ?? false;
    if (!identityConfirmed) {
      _pendingNavigation = LivenessNavigationTarget.documentCapture;
      return;
    }
    unawaited(_enter());
  }

  /// 009-reintento (retry-policy addendum): an exhausted limit stays in
  /// force — entering at the limit goes to retry guidance, and neither the
  /// camera nor a liveness session is started.
  Future<void> _enter() async {
    final counter = await _attemptCounterRepository.read(
      AttemptCounterScope.selfieLiveness,
    );
    if (_aborted) return;
    if ((counter.valueOrNull?.count ?? 0) >= captureAttemptLimit) {
      _pendingNavigation = LivenessNavigationTarget.retryGuidance;
      notifyListeners();
      return;
    }
    _analyticsEmitter.livenessStepEntered();
    await _runAttempt();
  }

  final LivenessVerificationRepository _livenessVerificationRepository;
  final LivenessCameraService _livenessCameraService;
  final CaptureAttemptCounterRepository _attemptCounterRepository;
  final EnrollmentSessionController _enrollmentSessionController;
  final AnalyticsEmitter _analyticsEmitter;

  /// FR-009/US2: restarts a fresh attempt from the first phase after a
  /// non-limit-reached failure — spec.md Assumptions: "a new attempt
  /// begins from the first phase rather than resuming a partial one."
  late final Command0<void> retry;

  /// A small, bounded interval between `sampleFrame()`/`submitSample()`
  /// calls — bounds how often the port is called without needing a real
  /// camera-frame-rate signal (contracts/liveness-camera-service-port.md:
  /// "on a fixed interval... not on every raw camera callback").
  /// Constructor-overridable so tests aren't bound to the production
  /// interval.
  final Duration _sampleInterval;

  /// research.md §9: 45s per spec.md's Assumption, comfortably above
  /// SC-004's 30s p90 target. Constructor-overridable so tests can exercise
  /// FR-013's stall path without a real 45-second wait.
  final Duration _stallDuration;

  /// A transport failure mid-attempt is a non-terminal hiccup up to this
  /// bound (contracts/liveness-verification-port.md) before it's treated
  /// as `LivenessOutcome.unclassifiedFailure()`.
  static const _transportFailureRetryLimit = 3;

  LivenessCaptureViewState _state = const LivenessCaptureViewState.loading();
  LivenessCaptureViewState get state => _state;

  LivenessNavigationTarget? _pendingNavigation;

  /// A one-shot navigation instruction for `LivenessCaptureView` to act
  /// on, then clear via [consumeNavigation].
  LivenessNavigationTarget? get pendingNavigation => _pendingNavigation;

  void consumeNavigation() {
    _pendingNavigation = null;
  }

  /// The live front-camera preview controller, or `null` before the
  /// camera has started, once it starts stopping, or when backed by a fake
  /// in tests.
  CameraController? get cameraController =>
      _cameraVisible ? _livenessCameraService.controller : null;

  /// Whether the view may render the camera preview. It is cleared, and
  /// listeners notified, *before* the camera is stopped, so the view drops
  /// `CameraPreview` before the controller is disposed. Otherwise the
  /// preview rebuilds against a disposed controller and throws
  /// `CameraException(Disposed CameraController)`.
  bool _cameraVisible = false;

  /// Identifies the latest attempt, so an attempt superseded while its
  /// camera was still starting (e.g. backgrounded by the permission
  /// dialog, then resumed) doesn't carry on alongside the new one.
  int _attemptId = 0;

  String? _sessionId;

  /// FR-008: whether an attempt's session id is currently held — `false`
  /// after any exit (completion, abort, stall). Exposed only for tests to
  /// assert "no frame or session is retained after any exit," since the
  /// held value itself is never otherwise observable from outside this
  /// class.
  @visibleForTesting
  bool get hasHeldSession => _sessionId != null;

  Timer? _stallTimer;
  bool _aborted = false;
  bool _outcomeRecorded = false;
  int _transportFailureCount = 0;

  void _setState(LivenessCaptureViewState next) {
    _state = next;
    notifyListeners();
  }

  Future<Result<void>> _retry() async {
    await _runAttempt();
    return const Result.ok(null);
  }

  Future<void> _runAttempt() async {
    final attemptId = ++_attemptId;
    _aborted = false;
    _transportFailureCount = 0;
    _setState(const LivenessCaptureViewState.loading());
    _startStallTimer();

    try {
      await _livenessCameraService.start();
    } catch (_) {
      // Device-capability gating (no front camera, permission denied) is
      // explicitly deferred by spec.md's happy-path Delivery Mode — a
      // hardware failure here still can't crash the screen, so it's
      // treated as an unclassified failure rather than left unhandled.
      if (attemptId != _attemptId) return;
      await _completeWith(const LivenessOutcome.unclassifiedFailure());
      return;
    }
    // A newer attempt now owns the camera; leave it alone.
    if (attemptId != _attemptId) return;
    if (_aborted) {
      // Aborted while the camera was starting: the abort's stop() ran
      // before there was anything to stop, so release it now.
      await _livenessCameraService.stop();
      return;
    }
    _cameraVisible = true;
    notifyListeners();

    final sessionResult = await _livenessVerificationRepository.startSession();
    if (_aborted) return;
    final sessionId = sessionResult.valueOrNull;
    if (sessionId == null) {
      await _completeWith(const LivenessOutcome.unclassifiedFailure());
      return;
    }
    _sessionId = sessionId;
    await _sampleLoop(sessionId);
  }

  Future<void> _sampleLoop(String sessionId) async {
    while (!_aborted) {
      final frame = _livenessCameraService.sampleFrame();
      if (frame == null) {
        await Future<void>.delayed(_sampleInterval);
        continue;
      }

      final result = await _livenessVerificationRepository.submitSample(
        sessionId: sessionId,
        frameBytes: frame,
      );
      if (_aborted) return;

      final sampleOutcome = result.valueOrNull;
      if (sampleOutcome == null) {
        _transportFailureCount++;
        if (_transportFailureCount >= _transportFailureRetryLimit) {
          await _completeWith(const LivenessOutcome.unclassifiedFailure());
          return;
        }
        await Future<void>.delayed(_sampleInterval);
        continue;
      }
      _transportFailureCount = 0;

      switch (sampleOutcome) {
        case LivenessSampleOutcomeInProgress(:final phase):
          _handlePhase(phase);
          await Future<void>.delayed(_sampleInterval);
        case LivenessSampleOutcomeCompleted(:final outcome):
          await _completeWith(outcome);
          return;
      }
    }
  }

  void _handlePhase(LivenessPhase phase) {
    // FR-007: the phase indicator MUST NOT move backwards — a processor
    // response reporting a lower index than the last one reported is
    // never rendered, since the whole point of "index only ever
    // increases" is a structural guarantee, not just typical behavior.
    final current = _state;
    if (current is LivenessCaptureViewRunning &&
        phase.index < current.phase.index) {
      return;
    }
    _setState(
      LivenessCaptureViewState.running(
        phase: phase,
        progress: phase.totalPhases == 0 ? 0 : phase.index / phase.totalPhases,
      ),
    );
    _analyticsEmitter.livenessPhaseReached(
      phaseIndex: phase.index,
      totalPhases: phase.totalPhases,
    );
  }

  Future<void> _completeWith(LivenessOutcome outcome) async {
    _cancelStallTimer();
    _aborted = true;
    _hideCamera();
    await _livenessCameraService.stop();
    _sessionId = null;
    _outcomeRecorded = true;

    _analyticsEmitter.livenessOutcome(
      outcome: _kindFor(outcome),
      reason: outcome is LivenessOutcomeQualityFailure ? outcome.reason : null,
    );

    if (outcome is LivenessOutcomeSuccess) {
      // 009-reintento FR-017: passing the liveness check no longer resets the
      // counter; only a verification match (007) or an agent does.
      _pendingNavigation = LivenessNavigationTarget.verificationProgress;
      _setState(
        LivenessCaptureViewState.outcome(outcome: outcome, limitReached: false),
      );
      return;
    }

    final incrementResult = await _attemptCounterRepository.increment(
      AttemptCounterScope.selfieLiveness,
    );
    final count = incrementResult.valueOrNull?.count ?? 0;
    _analyticsEmitter.livenessAttemptCount(attemptNumber: count);

    final limitReached = count >= captureAttemptLimit;
    if (limitReached) {
      _analyticsEmitter.livenessAttemptLimitReached();
      // 009-reintento FR-017: reaching the limit keeps the count.
      _pendingNavigation = LivenessNavigationTarget.retryGuidance;
    }
    _setState(
      LivenessCaptureViewState.outcome(
        outcome: outcome,
        limitReached: limitReached,
      ),
    );
  }

  LivenessOutcomeKind _kindFor(LivenessOutcome outcome) => switch (outcome) {
    LivenessOutcomeSuccess() => LivenessOutcomeKind.success,
    LivenessOutcomeQualityFailure() => LivenessOutcomeKind.qualityFailure,
    LivenessOutcomeUnclassifiedFailure() =>
      LivenessOutcomeKind.unclassifiedFailure,
    LivenessOutcomeAttackDetected() => LivenessOutcomeKind.attackDetected,
  };

  void _startStallTimer() {
    _cancelStallTimer();
    _stallTimer = Timer(_stallDuration, _onStalled);
  }

  void _cancelStallTimer() {
    _stallTimer?.cancel();
    _stallTimer = null;
  }

  void _onStalled() {
    _aborted = true;
    _hideCamera();
    unawaited(_livenessCameraService.stop());
    _sessionId = null;
    _analyticsEmitter.livenessStalled();
    _setState(const LivenessCaptureViewState.stalled());
  }

  void _hideCamera({bool notify = true}) {
    if (!_cameraVisible) return;
    _cameraVisible = false;
    if (notify) notifyListeners();
  }

  void _abort({bool notify = true}) {
    _aborted = true;
    _cancelStallTimer();
    _hideCamera(notify: notify);
    unawaited(_livenessCameraService.stop());
    _sessionId = null;
  }

  /// FR-015: called by `LivenessCaptureView` on explicit back navigation.
  /// Aborts the in-flight attempt and discards its held state; the
  /// `EnrollmentSession` itself is left untouched (`identityConfirmed` is
  /// never cleared), so returning to this screen later doesn't re-trigger
  /// the router's reachability guard.
  void onBackNavigation() {
    _abort();
    if (!_outcomeRecorded) {
      _analyticsEmitter.livenessStepAbandoned();
    }
  }

  /// research.md §9/FR-014: stop the camera and discard all held data on
  /// backgrounding/lock/call-seizure — the OS delivers the same lifecycle
  /// callback regardless of which of those caused it.
  Future<void> onAppBackgrounded() async {
    _abort();
  }

  /// A fresh attempt begins on resume, from the first phase (spec.md
  /// Assumptions) — mirrors 003's `CaptureView.onAppResumed` shape, never
  /// resuming a partial attempt.
  Future<void> onAppResumed() async {
    final state = _state;
    if (state is LivenessCaptureViewLoading ||
        state is LivenessCaptureViewRunning) {
      unawaited(_runAttempt());
    }
  }

  @override
  void dispose() {
    // The view is being torn down with this ViewModel, so there's no one
    // left to notify.
    _abort(notify: false);
    retry.dispose();
    super.dispose();
  }
}
