import '../../core/result.dart';
import '../../domain/entities/credential.dart';
import '../../domain/entities/credential_status.dart';
import '../../domain/repositories/credential_repository.dart';
import '../models/credential_status_response.dart';
import 'credential_service.dart';

/// The real `CredentialRepository` implementation, backed by
/// `CredentialService`. Per contracts/credential-status-port.md: no
/// provider SDK, DTO, or `dio` exception type may cross out of this class
/// — callers only ever see `CredentialStatus`/`Result`.
///
/// MUST satisfy the exact same contract test suite as
/// `FakeCredentialRepository`, unmodified (Constitution Principle X,
/// Liskov) — see test/contract/credential_repository_contract_test.dart.
class CredentialRepositoryImpl implements CredentialRepository {
  CredentialRepositoryImpl(this._service);

  final CredentialService _service;

  @override
  Future<Result<CredentialStatus>> getStatus() async {
    final cached = await _readCachedCredentialSafely();

    try {
      final remote = await _service.fetchStatus(token: cached?.token);
      if (cached == null) {
        // Backend was reachable, but there's nothing local to confirm
        // against — a first-run / never-enrolled passenger (contract
        // case 1).
        return const Result.ok(CredentialStatus.noCredential());
      }
      return Result.ok(_mapRemote(remote));
    } catch (_) {
      // Any transport failure (network, timeout, non-2xx, TLS/pinning
      // failure) is an expected, classified outcome here — never a bare
      // exception crossing into WelcomeViewModel (Principle IX).
      if (cached == null) {
        return const Result.ok(
          CredentialStatus.unreachable(lastKnownStatus: null),
        );
      }
      return Result.ok(
        CredentialStatus.unreachable(lastKnownStatus: _inferLastKnown(cached)),
      );
    }
  }

  Future<Credential?> _readCachedCredentialSafely() async {
    try {
      return await _service.readCachedCredential();
    } catch (_) {
      // A secure-storage read failure is treated the same as "nothing
      // cached" for the purpose of deciding what to ask the backend; if
      // the backend call that follows also fails, this surfaces as
      // Unreachable(lastKnownStatus: null) — the same shape as never
      // having cached anything (contract case 6).
      return null;
    }
  }

  CredentialStatus _mapRemote(CredentialStatusResponse remote) {
    switch (remote.status) {
      case 'valid':
        return CredentialStatus.valid(
          validUntil: remote.validUntil ?? DateTime.now(),
        );
      case 'revoked':
        return const CredentialStatus.expiredOrRevoked(
          reason: ExpiryReason.revoked,
        );
      case 'expired':
      default:
        return const CredentialStatus.expiredOrRevoked(
          reason: ExpiryReason.expired,
        );
    }
  }

  /// The status inferable from local cached data alone, without backend
  /// confirmation, when the backend could not be reached (FR-007).
  CredentialStatus _inferLastKnown(Credential cached) {
    if (cached.validUntil.isAfter(DateTime.now())) {
      return CredentialStatus.valid(validUntil: cached.validUntil);
    }
    return const CredentialStatus.expiredOrRevoked(
      reason: ExpiryReason.expired,
    );
  }
}
