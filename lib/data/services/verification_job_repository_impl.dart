import '../../core/result.dart';
import '../../domain/entities/verification_job_status.dart';
import '../../domain/entities/verification_outcome.dart';
import '../../domain/entities/verification_stage.dart';
import '../../domain/repositories/consent_repository.dart';
import '../../domain/repositories/verification_job_repository.dart';
import '../models/verification_job_response.dart';
import 'transport_error_mapper.dart';
import 'verification_job_service.dart';

/// The real `VerificationJobRepository` (007-validando,
/// contracts/verification-job-port.md). Owns all mapping from the wire
/// response to [VerificationJobStatus] (Principle II): every unknown value
/// maps to its safe default, so nothing unrecognized can read as a pass or
/// as a passenger rejection (research.md §4).
class VerificationJobRepositoryImpl implements VerificationJobRepository {
  VerificationJobRepositoryImpl(
    this._service, {
    required ConsentRepository consentRepository,
  }) : _consentRepository = consentRepository;

  final VerificationJobService _service;
  final ConsentRepository _consentRepository;

  @override
  Future<Result<VerificationJobStatus>> getStatus() async {
    final consent = (await _consentRepository.getLocalRecord()).valueOrNull;
    final attemptId = consent?.enrollmentAttemptId.value;
    if (attemptId == null) {
      return Result.error(
        StateError('no local consent record identifies the verification job'),
      );
    }
    try {
      final response = await _service.fetchCurrentJob(
        enrollmentAttemptId: attemptId,
      );
      return Result.ok(_map(response));
    } catch (e, st) {
      return Result.error(mapTransportError(e), st);
    }
  }

  VerificationJobStatus _map(VerificationJobResponse response) {
    final documentCheck = _stage(response.documentCheck);
    final faceComparison = _stage(response.faceComparison);
    // 011: an absent or unparsable window means not resumable, never a
    // failed read.
    final resumableUntil = DateTime.tryParse(response.resumableUntil ?? '');
    return switch (response.state) {
      'in_progress' => VerificationJobStatus.inProgress(
        documentCheck: documentCheck,
        faceComparison: faceComparison,
        resumableUntil: resumableUntil,
      ),
      'completed' => VerificationJobStatus.completed(
        outcome: _outcome(response.outcome),
        documentCheck: documentCheck,
        faceComparison: faceComparison,
        resumableUntil: resumableUntil,
      ),
      // An unrecognized state is the service's problem, never a pass.
      _ => VerificationJobStatus.completed(
        outcome: const VerificationOutcome.serviceFailure(),
        documentCheck: documentCheck,
        faceComparison: faceComparison,
        resumableUntil: resumableUntil,
      ),
    };
  }

  /// Unknown stage values are `pending`, never `passed` (FR-003).
  StageStatus _stage(String? wire) => switch (wire) {
    'running' => StageStatus.running,
    'passed' => StageStatus.passed,
    'failed' => StageStatus.failed,
    _ => StageStatus.pending,
  };

  VerificationOutcome _outcome(String? wire) => switch (wire) {
    'matched' => const VerificationOutcome.matched(),
    'document_rejected' => const VerificationOutcome.documentRejected(),
    'face_mismatch' => const VerificationOutcome.faceMismatch(),
    'liveness_rejected' => const VerificationOutcome.livenessRejected(),
    'attack_detected' => const VerificationOutcome.attackDetected(),
    _ => const VerificationOutcome.serviceFailure(),
  };
}
