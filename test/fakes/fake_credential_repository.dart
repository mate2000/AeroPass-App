import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/credential_status.dart';
import 'package:aeropass_app/domain/repositories/credential_repository.dart';

/// A scripted, no-network, no-secure-storage `CredentialRepository` double,
/// per contracts/credential-status-port.md and Constitution Principle II
/// ("full test suite against a fake with no network and no provider SDK
/// linked"). Used by widget/unit tests and by the contract test suite.
class FakeCredentialRepository implements CredentialRepository {
  FakeCredentialRepository({Result<CredentialStatus>? initialResponse})
    : _scripted = initialResponse == null ? [] : [initialResponse];

  final List<Result<CredentialStatus>> _scripted;
  int callCount = 0;

  /// Sets the single value the next (and all subsequent) call(s) to
  /// [getStatus] return.
  void scriptResponse(Result<CredentialStatus> response) {
    _scripted
      ..clear()
      ..add(response);
  }

  /// Sets a sequence of values consumed one per call to [getStatus]; the
  /// last value repeats once the queue is exhausted.
  void scriptResponses(List<Result<CredentialStatus>> responses) {
    _scripted
      ..clear()
      ..addAll(responses);
  }

  @override
  Future<Result<CredentialStatus>> getStatus() async {
    callCount++;
    if (_scripted.isEmpty) {
      return const Result.ok(CredentialStatus.noCredential());
    }
    if (_scripted.length == 1) {
      return _scripted.first;
    }
    return _scripted.removeAt(0);
  }
}
