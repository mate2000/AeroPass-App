import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import '../../../domain/entities/capture_attempt_counter.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/capture_attempt_counter_repository.dart';

/// Screen 09's ViewModel (009-reintento). Derives the screen's state from
/// the two attempt counters on creation (research.md §1), never from how the
/// screen was reached — so a forged link cannot offer a retry past the limit
/// (FR-010), and a passenger who returns later lands in the right state.
///
/// Reads the counters only; the attempt was already counted by the step that
/// routed here (spec Assumptions). No `material.dart` import (Principle VIII).
class RetryGuidanceViewModel extends ChangeNotifier {
  RetryGuidanceViewModel({
    required CaptureAttemptCounterRepository attemptCounterRepository,
    required AnalyticsEmitter analyticsEmitter,
  }) : _attemptCounterRepository = attemptCounterRepository,
       _analyticsEmitter = analyticsEmitter {
    unawaited(_load());
  }

  final CaptureAttemptCounterRepository _attemptCounterRepository;
  final AnalyticsEmitter _analyticsEmitter;

  RetryGuidanceState? _state;
  bool _disposed = false;

  /// `null` while the counters are being read; then fixed for the screen's
  /// lifetime.
  RetryGuidanceState? get state => _state;

  /// Only the selfie-retry state offers "Intentar de nuevo" (FR-010).
  bool get canRetry => _state == RetryGuidanceState.selfieRetry;

  Future<void> _load() async {
    final document = await _attemptCounterRepository.read(
      AttemptCounterScope.documentCapture,
    );
    final selfie = await _attemptCounterRepository.read(
      AttemptCounterScope.selfieLiveness,
    );
    final documentCount = document.valueOrNull?.count;
    final selfieCount = selfie.valueOrNull?.count;

    final RetryGuidanceState state;
    if (documentCount == null || selfieCount == null) {
      // Research.md §1: when the count cannot be confirmed, offer no retry;
      // the agent route stays available (FR-009).
      state = RetryGuidanceState.selfieLimit;
    } else if (documentCount >= captureAttemptLimit) {
      state = RetryGuidanceState.documentLimit;
    } else if (selfieCount >= captureAttemptLimit) {
      state = RetryGuidanceState.selfieLimit;
    } else {
      state = RetryGuidanceState.selfieRetry;
    }
    if (_disposed) return;
    _state = state;
    _analyticsEmitter.retryGuidanceShown(state: state);
    notifyListeners();
  }

  /// "Intentar de nuevo".
  void onRetry() {
    if (!canRetry) return;
    _analyticsEmitter.retryGuidanceRetryTaken();
  }

  /// "Hablar con un agente".
  void onAgentRoute() {
    final state = _state;
    if (state == null) return;
    _analyticsEmitter.retryGuidanceAgentRouteTaken(state: state);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
