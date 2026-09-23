import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/repositories/pass_repository.dart';

/// Scripted `PassRepository` (014-qr-pase). Issue results are taken in
/// order, then the last repeats; status results likewise. An issued pass is
/// remembered for [activePassFor] until forgotten.
class FakePassRepository implements PassRepository {
  final List<Result<Pass>> _issues = [];
  Result<Pass>? _lastIssue;
  final List<Result<PassState>> _statuses = [];
  Result<PassState>? _lastStatus;
  final Map<String, Pass> _active = {};

  int issueCount = 0;
  int statusCount = 0;
  final List<String> forgotten = [];

  void scriptIssues(List<Result<Pass>> results) => _issues
    ..clear()
    ..addAll(results);

  void scriptStatuses(List<Result<PassState>> results) => _statuses
    ..clear()
    ..addAll(results);

  void seedActive(Pass pass) => _active[pass.tripId] = pass;

  @override
  Future<Result<Pass>> issue(String tripId) async {
    issueCount++;
    if (_issues.isNotEmpty) _lastIssue = _issues.removeAt(0);
    final result =
        _lastIssue ??
        Result.error(StateError('FakePassRepository: no issue scripted'));
    if (result case Ok(:final value)) _active[tripId] = value;
    return result;
  }

  @override
  Future<Result<PassState>> status(String passId) async {
    statusCount++;
    if (_statuses.isNotEmpty) _lastStatus = _statuses.removeAt(0);
    return _lastStatus ??
        Result.error(StateError('FakePassRepository: no status scripted'));
  }

  @override
  Pass? activePassFor(String tripId) => _active[tripId];

  @override
  Future<void> forget(String passId) async {
    forgotten.add(passId);
    _active.removeWhere((_, pass) => pass.passId == passId);
  }
}
