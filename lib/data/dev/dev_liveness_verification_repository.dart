import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/liveness_outcome.dart';
import '../../domain/entities/liveness_phase.dart';
import '../../domain/entities/liveness_sample_outcome.dart';
import '../../domain/repositories/liveness_verification_repository.dart';

/// A local, no-network `LivenessVerificationRepository` used only when the
/// app is launched with `--dart-define=USE_FAKE_VERIFICATION_BACKEND=true`
/// (research.md §10), mirroring `DevDocumentVerificationRepository`'s
/// precedent — never a fallback path reachable from production wiring.
///
/// `startSession()` always succeeds immediately; `submitSample()` advances
/// through a fixed 4-phase scripted sequence (one phase per call,
/// regardless of `frameBytes` content — it is never inspected) and returns
/// `.completed(LivenessOutcome.success())` on the 4th call. Never returns a
/// failure outcome — happy-path mode's job is to prove the flow is
/// walkable, not to exercise the failure taxonomy.
class DevLivenessVerificationRepository
    implements LivenessVerificationRepository {
  int _sampleCallCount = 0;

  @override
  Future<Result<String>> startSession() async {
    _sampleCallCount = 0;
    return const Result.ok('dev-liveness-session');
  }

  @override
  Future<Result<LivenessSampleOutcome>> submitSample({
    required String sessionId,
    required Uint8List frameBytes,
  }) async {
    _sampleCallCount++;
    if (_sampleCallCount >= 4) {
      return const Result.ok(
        LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()),
      );
    }
    return Result.ok(
      LivenessSampleOutcome.inProgress(
        phase: LivenessPhase(
          index: _sampleCallCount - 1,
          totalPhases: 4,
          instruction: _instructionFor(_sampleCallCount),
        ),
      ),
    );
  }

  LivenessInstruction _instructionFor(int callNumber) => switch (callNumber) {
    1 => const LivenessInstruction.centerFace(),
    2 => const LivenessInstruction.holdStill(),
    _ => const LivenessInstruction.lookAtCamera(),
  };
}
