import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/liveness_outcome.dart';
import '../../domain/entities/liveness_phase.dart';
import '../../domain/entities/liveness_sample_outcome.dart';
import '../../domain/repositories/liveness_verification_repository.dart';

/// 006's [LivenessVerificationRepository] against the real backend, which
/// has no liveness session (015 research.md §7).
///
/// The backend judges liveness from the one still that 006 sends when the
/// challenge ends (`POST /v1/biometrics/verifications`). The challenge on
/// the device is guidance only: it walks the passenger through framing
/// their face, sends nothing, inspects no frame, and always completes. The
/// device never decides liveness (006 FR-002), and no frame leaves it.
class LocalLivenessRepository implements LivenessVerificationRepository {
  LocalLivenessRepository({this.phaseDuration = const Duration(seconds: 1)});

  /// How long each guidance phase is shown.
  final Duration phaseDuration;

  static const _instructions = [
    LivenessInstruction.centerFace(),
    LivenessInstruction.holdStill(),
    LivenessInstruction.lookAtCamera(),
  ];

  int _samples = 0;

  @override
  Future<Result<String>> startSession() async {
    _samples = 0;
    return const Result.ok('local-guidance');
  }

  @override
  Future<Result<LivenessSampleOutcome>> submitSample({
    required String sessionId,
    required Uint8List frameBytes,
  }) async {
    await Future<void>.delayed(phaseDuration);
    final index = _samples++;
    if (index >= _instructions.length) {
      return const Result.ok(
        LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()),
      );
    }
    return Result.ok(
      LivenessSampleOutcome.inProgress(
        phase: LivenessPhase(
          index: index,
          totalPhases: _instructions.length,
          instruction: _instructions[index],
        ),
      ),
    );
  }
}
