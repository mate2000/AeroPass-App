import 'dart:async' show unawaited;

import 'package:camera/camera.dart' show CameraController;
import 'package:flutter/foundation.dart';

import '../../../app/enrollment_session_controller.dart';
import '../../../app/pending_document_controller.dart';
import '../../../core/command.dart';
import '../../../core/result.dart';
import '../../../data/services/camera_capture_service.dart';
import '../../../data/services/system_settings_launcher.dart';
import '../../../domain/entities/capture_attempt_counter.dart';
import '../../../domain/entities/capture_outcome.dart';
import '../../../domain/entities/consent_record.dart';
import '../../../domain/entities/enrollment_session.dart';
import '../../../domain/entities/extraction_result.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/capture_attempt_counter_repository.dart';
import '../../../domain/repositories/consent_repository.dart';
import '../../../domain/repositories/document_quality_assessor.dart';
import '../../../domain/repositories/document_verification_repository.dart';
import 'capture_view_state.dart';

/// The document-capture step's ViewModel (spec.md screen 03): gates on a
/// current consent record (FR-001), owns the camera's lifecycle through
/// [CameraCaptureService], orchestrates one capture activation through
/// on-device assessment and (if usable) verification submission, and
/// tracks the durable attempt counter (FR-009).
///
/// No `package:flutter/material.dart` import, no widget — testable
/// headless (Constitution Principle VIII). Every dependency is
/// constructor-injected (Principle IX), including [CameraCaptureService]
/// specifically so this class is testable without a real camera.
class CaptureViewModel extends ChangeNotifier {
  CaptureViewModel({
    required ConsentRepository consentRepository,
    required CameraCaptureService cameraCaptureService,
    required DocumentQualityAssessor qualityAssessor,
    required DocumentVerificationRepository verificationRepository,
    required CaptureAttemptCounterRepository attemptCounterRepository,
    required EnrollmentSessionController enrollmentSessionController,
    required PendingDocumentController pendingDocumentController,
    required AnalyticsEmitter analyticsEmitter,
    required SystemSettingsLauncher systemSettingsLauncher,
  }) : _consentRepository = consentRepository,
       _cameraCaptureService = cameraCaptureService,
       _qualityAssessor = qualityAssessor,
       _verificationRepository = verificationRepository,
       _attemptCounterRepository = attemptCounterRepository,
       _enrollmentSessionController = enrollmentSessionController,
       _pendingDocumentController = pendingDocumentController,
       _analyticsEmitter = analyticsEmitter,
       _systemSettingsLauncher = systemSettingsLauncher {
    capture = Command0(_capture);
    toggleTorch = Command0(_toggleTorch);
    retryPermission = Command0(_retryPermission);
    openSystemSettings = Command0(_openSystemSettings);
    unawaited(_load());
  }

  final ConsentRepository _consentRepository;
  final CameraCaptureService _cameraCaptureService;
  final DocumentQualityAssessor _qualityAssessor;
  final DocumentVerificationRepository _verificationRepository;
  final CaptureAttemptCounterRepository _attemptCounterRepository;
  final EnrollmentSessionController _enrollmentSessionController;
  final PendingDocumentController _pendingDocumentController;
  final AnalyticsEmitter _analyticsEmitter;
  final SystemSettingsLauncher _systemSettingsLauncher;

  /// FR-004/FR-016: the manual capture action. [Command]'s own re-entrancy
  /// guard is what guarantees "exactly one capture processed per
  /// activation, regardless of repeated or rapid taps" structurally.
  late final Command0<void> capture;

  /// FR-005: torch toggle, reachable one-handed.
  late final Command0<void> toggleTorch;

  /// Re-attempts camera start after a temporary permission denial. A no-op
  /// once [CaptureViewPermissionDenied.permanent] is true — FR-014
  /// forbids re-prompting the OS dialog repeatedly.
  late final Command0<void> retryPermission;

  /// FR-014: opens the system settings screen that would unblock a
  /// permanently denied camera permission.
  late final Command0<void> openSystemSettings;

  CaptureViewState _state = const CaptureViewState.checking();
  CaptureViewState get state => _state;

  CaptureNavigationTarget? _pendingNavigation;

  /// A one-shot navigation instruction for `CaptureView` to act on, then
  /// clear via [consumeNavigation].
  CaptureNavigationTarget? get pendingNavigation => _pendingNavigation;

  /// Clears [pendingNavigation] once `CaptureView` has acted on it, so a
  /// rebuild doesn't re-trigger the same navigation.
  void consumeNavigation() {
    _pendingNavigation = null;
  }

  /// The live camera preview controller, or `null` before the camera has
  /// started, after it has stopped, or when backed by a fake in tests.
  CameraController? get cameraController => _cameraCaptureService.controller;

  bool get torchOn => _cameraCaptureService.torchOn;

  int _permissionDenialCount = 0;
  bool _outcomeRecorded = false;

  void _setState(CaptureViewState next) {
    _state = next;
    notifyListeners();
  }

  Future<void> _load() async {
    final consentResult = await _consentRepository.getLocalRecord();
    final record = consentResult.valueOrNull;

    final textResult = await _consentRepository.getCurrentText();
    // FR-001: "a current consent record" — active status AND referring to
    // the currently-published text version. When the current text can't be
    // confirmed at all (e.g. offline), this fails closed: without being
    // able to confirm currency, the capture step does not open the camera
    // (mirrors the constitution's "zero false accepts" posture applied to
    // the consent gate rather than pass validity).
    final isCurrent = textResult.when(
      ok: (text) =>
          record != null &&
          record.status == ConsentRecordStatus.active &&
          record.textVersionId == text.id,
      error: (_, _) => false,
    );

    if (!isCurrent) {
      _pendingNavigation = CaptureNavigationTarget.consentGate;
      notifyListeners();
      return;
    }

    _enrollmentSessionController.advanceTo(
      const EnrollmentStep.documentCapture(),
    );
    _analyticsEmitter.captureStepEntered();
    await _startCamera();
  }

  Future<void> _startCamera() async {
    try {
      await _cameraCaptureService.start();
      _setState(const CaptureViewState.ready());
    } catch (_) {
      // FR-002/FR-014: the camera permission (requested by the plugin's
      // own `initialize()` call inside `start()`) was denied, or the
      // camera is otherwise unavailable. The `camera` plugin does not
      // itself distinguish "temporarily denied" from "permanently
      // denied" without a separate permission-status package (not added,
      // per plan.md's single-new-dependency scope) — a second denial
      // within this screen's lifetime is treated as permanent, so the OS
      // dialog is never re-prompted more than once per visit.
      _permissionDenialCount++;
      final permanent = _permissionDenialCount > 1;
      _analyticsEmitter.capturePermissionDeniedShown(permanent: permanent);
      _setState(CaptureViewState.permissionDenied(permanent: permanent));
    }
  }

  Future<Result<void>> _retryPermission() async {
    final state = _state;
    if (state is CaptureViewPermissionDenied && state.permanent) {
      // No-op: FR-014 forbids re-prompting the system dialog repeatedly.
      // CaptureView offers the system-settings route instead of retry in
      // this state.
      return const Result.ok(null);
    }
    await _startCamera();
    return const Result.ok(null);
  }

  Future<Result<void>> _openSystemSettings() async {
    await _systemSettingsLauncher.open();
    return const Result.ok(null);
  }

  Future<Result<void>> _toggleTorch() async {
    await _cameraCaptureService.toggleTorch();
    notifyListeners();
    return const Result.ok(null);
  }

  Future<Result<void>> _capture() async {
    final CapturedDocumentFrame frame;
    try {
      frame = await _cameraCaptureService.capture();
    } catch (e, st) {
      // Hardware-level capture failure (e.g. the controller was torn down
      // concurrently) — surfaced through the Command's own error state;
      // not one of FR-007's classified rejection reasons.
      return Result.error(e, st);
    }

    final counterResult = await _attemptCounterRepository.read(
      AttemptCounterScope.documentCapture,
    );
    final attemptNumber = (counterResult.valueOrNull?.count ?? 0) + 1;
    _analyticsEmitter.captureAttempted(attemptNumber: attemptNumber);

    final assessment = _qualityAssessor.assess(frame.analysisBytes);
    switch (assessment) {
      case QualityAssessmentUsable():
        return _submit(frame);
      case QualityAssessmentRejected(:final reason):
        _analyticsEmitter.captureDeviceRejected(reason: reason);
        return _registerRejection(reason);
    }
  }

  Future<Result<void>> _submit(CapturedDocumentFrame frame) async {
    final result = await _verificationRepository.submit(frame.submissionBytes);
    return result.when(
      ok: (outcome) => switch (outcome) {
        CaptureOutcomeAccepted(:final extraction) =>
          _registerAccepted(frame.submissionBytes, extraction),
        CaptureOutcomeRejected(:final reason) => _registerVerificationRejection(reason),
      },
      error: (_, _) {
        // FR-015: transport failure only (contracts/document-verification
        // -port.md) — never counted as a failed attempt against FR-009's
        // cap, and the image is never queued to disk to survive the wait.
        _setState(const CaptureViewState.ready(offline: true));
        return const Result.ok(null);
      },
    );
  }

  Future<Result<void>> _registerVerificationRejection(
    CaptureRejectionReason reason,
  ) {
    _analyticsEmitter.captureVerificationRejected(reason: reason);
    return _registerRejection(reason);
  }

  Future<Result<void>> _registerAccepted(
    Uint8List documentImageBytes,
    ExtractionResult extraction,
  ) async {
    final _ = await _attemptCounterRepository.reset(
      AttemptCounterScope.documentCapture,
    );
    // 004-confirmar-datos research.md §1: hand the retained bytes and the
    // processor's extraction forward, in memory only, before navigating —
    // this is the one hand-off point `PendingDocumentController` exists for.
    _pendingDocumentController.set(documentImageBytes, extraction);
    _outcomeRecorded = true;
    _analyticsEmitter.captureAccepted();
    _pendingNavigation = CaptureNavigationTarget.dataConfirmation;
    _setState(const CaptureViewState.ready());
    return const Result.ok(null);
  }

  /// FR-008: the same actionable-vocabulary reason, regardless of whether
  /// it came from the on-device assessor or the verification processor —
  /// both rejection paths converge here.
  Future<Result<void>> _registerRejection(CaptureRejectionReason reason) async {
    final incrementResult = await _attemptCounterRepository.increment(
      AttemptCounterScope.documentCapture,
    );
    final count = incrementResult.valueOrNull?.count ?? 0;
    if (count >= captureAttemptLimit) {
      _outcomeRecorded = true;
      _analyticsEmitter.captureAttemptLimitReached();
      final _ = await _attemptCounterRepository.reset(
        AttemptCounterScope.documentCapture,
      );
      _pendingNavigation = CaptureNavigationTarget.retryGuidance;
      notifyListeners();
      return const Result.ok(null);
    }
    _setState(CaptureViewState.ready(lastRejectionReason: reason));
    return const Result.ok(null);
  }

  /// FR-012: called by `CaptureView` on explicit back navigation, to
  /// record abandonment (never on forward navigation, which sets
  /// [_outcomeRecorded] instead).
  void onBackNavigation() {
    if (!_outcomeRecorded) {
      _analyticsEmitter.captureStepAbandoned();
    }
  }

  /// research.md §5: stop the camera on backgrounding/lock/interruption —
  /// never resumed with a stale/frozen frame.
  Future<void> onAppBackgrounded() async {
    await _cameraCaptureService.stop();
  }

  /// research.md §5: re-initialize the preview fresh on resume, if the
  /// screen was showing (or trying to show) the live preview before being
  /// backgrounded.
  Future<void> onAppResumed() async {
    final state = _state;
    if (state is CaptureViewReady || state is CaptureViewPermissionDenied) {
      await _startCamera();
    }
  }

  @override
  void dispose() {
    unawaited(_cameraCaptureService.stop());
    capture.dispose();
    toggleTorch.dispose();
    retryPermission.dispose();
    openSystemSettings.dispose();
    super.dispose();
  }
}
