import 'dart:typed_data';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/liveness_sample_outcome.dart';
import 'package:aeropass_app/domain/repositories/liveness_verification_repository.dart';

/// A scripted, no-network `LivenessVerificationRepository` double, per
/// contracts/liveness-verification-port.md and Constitution Principle II's
/// "full test suite against a fake with no network linked" pattern.
class FakeLivenessVerificationRepository
    implements LivenessVerificationRepository {
  Result<String>? _startSessionResponse;
  final List<Result<LivenessSampleOutcome>> _submitSampleQueue = [];

  int startSessionCallCount = 0;
  int submitSampleCallCount = 0;
  String? lastSessionId;
  Uint8List? lastFrameBytes;

  void scriptStartSession(Result<String> response) {
    _startSessionResponse = response;
  }

  /// A single response, returned on every [submitSample] call.
  void scriptSubmitSample(Result<LivenessSampleOutcome> response) {
    _submitSampleQueue
      ..clear()
      ..add(response);
  }

  /// One response per call, consumed in order; the last one repeats once
  /// the sequence is exhausted, so a test scripting `[inProgress,
  /// inProgress, completed(success)]` doesn't need to know exactly how many
  /// times the ViewModel's loop samples.
  void scriptSubmitSampleSequence(
    List<Result<LivenessSampleOutcome>> responses,
  ) {
    _submitSampleQueue
      ..clear()
      ..addAll(responses);
  }

  @override
  Future<Result<String>> startSession() async {
    startSessionCallCount++;
    return _startSessionResponse ??
        Result.error(StateError('no startSession() response scripted'));
  }

  @override
  Future<Result<LivenessSampleOutcome>> submitSample({
    required String sessionId,
    required Uint8List frameBytes,
  }) async {
    submitSampleCallCount++;
    lastSessionId = sessionId;
    lastFrameBytes = frameBytes;
    if (_submitSampleQueue.isEmpty) {
      return Result.error(StateError('no submitSample() response scripted'));
    }
    if (_submitSampleQueue.length == 1) {
      return _submitSampleQueue.first;
    }
    return _submitSampleQueue.removeAt(0);
  }
}
