import 'package:flutter/foundation.dart';

import '../../../app/enrollment_session_controller.dart';
import '../../../core/command.dart';
import '../../../core/result.dart';
import '../../../domain/entities/enrollment_session.dart';
import '../../../domain/repositories/analytics_emitter.dart';

/// The selfie-instructions step's ViewModel (spec.md screen 05): advances
/// the enrollment session on entry, exposes the single "Tomar selfie"
/// action, and emits this screen's four funnel events. No repository call,
/// no camera, no data read from the confirmed identity record (FR-004/
/// FR-005 — this screen advises only; research.md §1 explains why it needs
/// no reachability guard).
///
/// No `package:flutter/material.dart` import, no widget — testable
/// headless (Constitution Principle VIII). Every dependency is
/// constructor-injected (Principle IX).
class SelfieInstructionsViewModel extends ChangeNotifier {
  SelfieInstructionsViewModel({
    required EnrollmentSessionController enrollmentSessionController,
    required AnalyticsEmitter analyticsEmitter,
  }) : _enrollmentSessionController = enrollmentSessionController,
       _analyticsEmitter = analyticsEmitter {
    advance = Command0(_advance);
    _enrollmentSessionController.advanceTo(
      const EnrollmentStep.selfieCapture(),
    );
    _analyticsEmitter.selfieInstructionsStepEntered();
  }

  final EnrollmentSessionController _enrollmentSessionController;
  final AnalyticsEmitter _analyticsEmitter;

  /// FR-004/FR-005: the single "Tomar selfie" action. No precondition —
  /// this screen never gates progress.
  late final Command0<void> advance;

  bool _advanced = false;

  Future<Result<void>> _advance() async {
    _advanced = true;
    _analyticsEmitter.selfieInstructionsAdvanced();
    return const Result.ok(null);
  }

  /// FR-007: called by the view immediately before it pushes the existing
  /// help route.
  void onHelpOpened() {
    _analyticsEmitter.selfieInstructionsHelpOpened();
  }

  /// FR-008: called by the view on explicit back navigation, to record
  /// abandonment (never after an advance, which already recorded its own
  /// outcome).
  void onBackNavigation() {
    if (!_advanced) {
      _analyticsEmitter.selfieInstructionsStepAbandoned();
    }
  }

  @override
  void dispose() {
    advance.dispose();
    super.dispose();
  }
}
