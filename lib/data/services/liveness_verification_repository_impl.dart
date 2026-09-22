import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/liveness_outcome.dart';
import '../../domain/entities/liveness_phase.dart';
import '../../domain/entities/liveness_sample_outcome.dart';
import '../../domain/repositories/liveness_verification_repository.dart';
import '../models/liveness_sample_response.dart';
import 'liveness_verification_service.dart';

/// The real `LivenessVerificationRepository` implementation, backed by
/// `LivenessVerificationService`. Per
/// contracts/liveness-verification-port.md: no `dio` exception, DTO, or raw
/// JSON shape may cross out of this class — callers only ever see
/// `LivenessSampleOutcome`/`Result`. Owns the processor's
/// phase/instruction/outcome-code -> domain-vocabulary mapping (research.md
/// §7) so no other layer needs a second copy of it. An unrecognized outcome
/// code falls back to `LivenessOutcome.unclassifiedFailure()`, never an
/// unhandled exception (contract case 7).
///
/// MUST satisfy the exact same contract test suite as
/// `FakeLivenessVerificationRepository`, unmodified (Constitution Principle
/// X, Liskov) — see
/// test/contract/liveness_verification_repository_contract_test.dart.
class LivenessVerificationRepositoryImpl
    implements LivenessVerificationRepository {
  LivenessVerificationRepositoryImpl(this._service);

  final LivenessVerificationService _service;

  @override
  Future<Result<String>> startSession() async {
    try {
      final sessionId = await _service.startSession();
      return Result.ok(sessionId);
    } catch (e, st) {
      return Result.error(e, st);
    }
  }

  @override
  Future<Result<LivenessSampleOutcome>> submitSample({
    required String sessionId,
    required Uint8List frameBytes,
  }) async {
    try {
      final response = await _service.submitSample(
        sessionId: sessionId,
        frameBytes: frameBytes,
      );
      return Result.ok(_mapResponse(response));
    } catch (e, st) {
      return Result.error(e, st);
    }
  }

  LivenessSampleOutcome _mapResponse(LivenessSampleResponse response) {
    if (response.status == 'completed') {
      return LivenessSampleOutcome.completed(outcome: _mapOutcome(response));
    }
    return LivenessSampleOutcome.inProgress(
      phase: LivenessPhase(
        index: response.phaseIndex ?? 0,
        totalPhases: response.totalPhases ?? 1,
        instruction: _mapInstruction(response.instruction),
      ),
    );
  }

  LivenessOutcome _mapOutcome(LivenessSampleResponse response) {
    switch (response.outcome) {
      case 'success':
        return const LivenessOutcome.success();
      case 'quality_failure':
        final reason = _mapQualityReason(response.reason);
        if (reason == null) return const LivenessOutcome.unclassifiedFailure();
        return LivenessOutcome.qualityFailure(reason: reason);
      case 'attack_detected':
        return const LivenessOutcome.attackDetected();
      default:
        // Covers the processor's own `unclassified_failure` code and any
        // code this mapping doesn't recognize (contract case 7) — both
        // resolve to the same domain value.
        return const LivenessOutcome.unclassifiedFailure();
    }
  }

  LivenessQualityReason? _mapQualityReason(String? raw) => switch (raw) {
    'too_dark' => LivenessQualityReason.tooDark,
    'face_out_of_frame' => LivenessQualityReason.faceOutOfFrame,
    'movement_detected' => LivenessQualityReason.movementDetected,
    'multiple_faces_detected' => LivenessQualityReason.multipleFacesDetected,
    'face_obstructed' => LivenessQualityReason.faceObstructed,
    _ => null,
  };

  LivenessInstruction _mapInstruction(String? raw) => switch (raw) {
    'move_closer' => const LivenessInstruction.moveCloser(),
    'move_back' => const LivenessInstruction.moveBack(),
    'center_face' => const LivenessInstruction.centerFace(),
    'hold_still' => const LivenessInstruction.holdStill(),
    'look_at_camera' => const LivenessInstruction.lookAtCamera(),
    'improve_lighting' => const LivenessInstruction.improveLighting(),
    _ => const LivenessInstruction.holdStill(),
  };
}
