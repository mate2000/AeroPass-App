import 'dart:async' show Completer;

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/issuance_outcome.dart';
import 'package:aeropass_app/domain/repositories/credential_issuance_repository.dart';

/// A scriptable `CredentialIssuanceRepository` double
/// (contracts/credential-issuance-port.md). Returns the scripted results in
/// order, repeating the last one once the queue is exhausted.
class FakeCredentialIssuanceRepository implements CredentialIssuanceRepository {
  final List<Result<IssuanceOutcome>> _queue = [];
  Result<IssuanceOutcome> _last = const Result.ok(IssuanceOutcome.incomplete());
  Completer<Result<IssuanceOutcome>>? _gate;
  int callCount = 0;

  void scriptResult(Result<IssuanceOutcome> result) {
    _queue
      ..clear()
      ..add(result);
  }

  void scriptResults(List<Result<IssuanceOutcome>> results) {
    _queue
      ..clear()
      ..addAll(results);
  }

  /// 007: holds the next request open until the returned completer is
  /// completed, to observe the issuance stage while it is running.
  Completer<Result<IssuanceOutcome>> gate() => _gate = Completer();

  @override
  Future<Result<IssuanceOutcome>> requestIssuance() async {
    callCount++;
    final gate = _gate;
    if (gate != null) {
      _gate = null;
      return gate.future;
    }
    if (_queue.isNotEmpty) _last = _queue.removeAt(0);
    return _last;
  }
}
