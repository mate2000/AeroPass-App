import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/escalation.dart';
import 'package:aeropass_app/domain/repositories/escalation_repository.dart';

/// A scriptable `EscalationRepository` double (contracts/escalation-port.md).
/// `getStatus` returns the scripted results in order, repeating the last.
/// With nothing scripted, both calls fail, so a harness that does not care
/// about escalations sees "no escalation" behaviour.
class FakeEscalationRepository implements EscalationRepository {
  Result<EscalationCase>? openResult;
  final List<Result<EscalationStatus>> _statuses = [];
  Result<EscalationStatus>? _lastStatus;
  int openCallCount = 0;
  int statusCallCount = 0;
  EscalationArrival? lastArrival;

  void scriptStatuses(List<Result<EscalationStatus>> results) {
    _statuses
      ..clear()
      ..addAll(results);
  }

  @override
  Future<Result<EscalationCase>> openOrResume({
    required EscalationArrival arrival,
  }) async {
    openCallCount++;
    lastArrival = arrival;
    return openResult ??
        Result.error(StateError('FakeEscalationRepository: no open result'));
  }

  @override
  Future<Result<EscalationStatus>> getStatus() async {
    statusCallCount++;
    if (_statuses.isNotEmpty) _lastStatus = _statuses.removeAt(0);
    return _lastStatus ??
        Result.error(StateError('FakeEscalationRepository: nothing scripted'));
  }
}
