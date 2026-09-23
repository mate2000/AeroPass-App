import '../../core/result.dart';
import '../../domain/entities/credential_status.dart';
import '../../domain/repositories/credential_repository.dart';
import '../services/credential_service.dart';

/// Happy-path stand-in for 001's launch rule (012-mis-viajes research.md §3),
/// behind `USE_FAKE_VERIFICATION_BACKEND`. The development URL has no
/// backend, so the real repository would always report "unreachable". This
/// plays the backend instead: a stored token is `valid`, and none is
/// `noCredential`.
class DevCredentialRepository implements CredentialRepository {
  DevCredentialRepository({required CredentialService credentialService})
    : _service = credentialService;

  final CredentialService _service;

  @override
  Future<Result<CredentialStatus>> getStatus() async {
    try {
      final cached = await _service.readCachedCredential();
      return Result.ok(
        cached == null
            ? const CredentialStatus.noCredential()
            : CredentialStatus.valid(validUntil: cached.validUntil),
      );
    } catch (e, st) {
      return Result.error(e, st);
    }
  }
}
