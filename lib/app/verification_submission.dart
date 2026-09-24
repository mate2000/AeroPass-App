import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/result.dart';
import '../domain/entities/verification_result.dart';
import '../domain/repositories/biometric_verification_repository.dart';

/// Where the one in-flight selfie verification is (015 research.md §7,
/// data-model.md).
sealed class SubmissionState {
  const SubmissionState();
}

final class SubmissionIdle extends SubmissionState {
  const SubmissionIdle();
}

final class SubmissionInFlight extends SubmissionState {
  const SubmissionInFlight();
}

final class SubmissionDone extends SubmissionState {
  const SubmissionDone(this.result);

  final VerificationResult result;
}

final class SubmissionFailed extends SubmissionState {
  const SubmissionFailed(this.error);

  /// A `TransportFailure`, `SessionUnavailable` or `BackendError`, never
  /// shown as text.
  final Object error;
}

/// Bridges 006's one still and 007's polling screen (015 research.md §7).
///
/// The backend verifies synchronously. 006 hands its selfie to [submit] and
/// moves on to 007, whose job repository reads [state] instead of a remote
/// job. The bytes are passed to the repository and not kept: once the call
/// returns, whatever the result, nothing here holds them (Principle I).
///
/// App-process scoped and in memory only, like the other session
/// controllers.
class VerificationSubmission extends ChangeNotifier {
  VerificationSubmission({required BiometricVerificationRepository repository})
    : _repository = repository;

  final BiometricVerificationRepository _repository;

  SubmissionState _state = const SubmissionIdle();
  SubmissionState get state => _state;

  /// The most recent documented result of this run. 009's retry budget is
  /// read from it (FR-008).
  VerificationResult? _lastResult;
  VerificationResult? get lastResult => _lastResult;

  /// Starts the verification. It is refused while one is in flight, so a
  /// double tap cannot upload twice.
  bool submit(Uint8List selfieJpeg) {
    if (_state is SubmissionInFlight) return false;
    _set(const SubmissionInFlight());
    unawaited(_run(selfieJpeg));
    return true;
  }

  Future<void> _run(Uint8List selfieJpeg) async {
    final result = await _repository.verify(selfieJpeg);
    switch (result) {
      case Ok(:final value):
        _lastResult = value;
        _set(SubmissionDone(value));
      case Error(:final error):
        _set(SubmissionFailed(error));
    }
  }

  /// Back to idle once 007 has routed, or on a new enrollment. The last
  /// result is kept for 009 until [clear].
  void reset() {
    if (_state is SubmissionInFlight) return;
    _set(const SubmissionIdle());
  }

  /// Forgets everything, on withdrawal or a new enrollment.
  void clear() {
    _lastResult = null;
    reset();
  }

  void _set(SubmissionState next) {
    _state = next;
    notifyListeners();
  }
}
