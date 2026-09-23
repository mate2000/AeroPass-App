import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/verification_job_status.dart';
import 'package:aeropass_app/domain/repositories/verification_job_repository.dart';

/// A scriptable `VerificationJobRepository` double
/// (contracts/verification-job-port.md). Returns the scripted results in
/// order, repeating the last one once the queue is exhausted.
class FakeVerificationJobRepository implements VerificationJobRepository {
  final List<Result<VerificationJobStatus>> _queue = [];
  Result<VerificationJobStatus>? _last;
  int callCount = 0;

  void scriptResults(List<Result<VerificationJobStatus>> results) {
    _queue
      ..clear()
      ..addAll(results);
  }

  @override
  Future<Result<VerificationJobStatus>> getStatus() async {
    callCount++;
    if (_queue.isNotEmpty) _last = _queue.removeAt(0);
    return _last ??
        Result.error(
          StateError('FakeVerificationJobRepository: nothing scripted'),
        );
  }
}
