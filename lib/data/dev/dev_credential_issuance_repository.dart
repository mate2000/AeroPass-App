import '../../core/result.dart';
import '../../domain/entities/activated_credential.dart';
import '../../domain/entities/issuance_outcome.dart';
import '../../domain/repositories/credential_issuance_repository.dart';
import '../services/credential_service.dart';

/// A local, no-network `CredentialIssuanceRepository` used only when the app
/// is launched with `USE_FAKE_VERIFICATION_BACKEND=true` (research.md §14,
/// 008-identidad-activa) — never reachable from production wiring, and
/// covered by `HappyPathFlags.assertReleaseSafe`.
///
/// It plays the backend: it is the fake that asserts "active", never the
/// screen (the spec's "direction of the assertion" rule). It returns the
/// same synthetic identity as `DevDocumentVerificationRepository` and never
/// reads local identity data. It writes the same two secure-storage keys as
/// the real implementation, so a relaunch after the demo behaves like
/// production (spec 001's launch rule sends it to trips).
class DevCredentialIssuanceRepository implements CredentialIssuanceRepository {
  DevCredentialIssuanceRepository({
    required CredentialService credentialService,
    DateTime Function()? now,
  }) : _credentialService = credentialService,
       _now = now ?? DateTime.now;

  final CredentialService _credentialService;
  final DateTime Function() _now;

  static const _validityYears = 5;
  static const _syntheticToken = 'dev-synthetic-credential-token';

  static const _holderName = 'Mateo González Restrepo';
  static const _documentLast4 = '7890';

  @override
  Future<Result<IssuanceOutcome>> requestIssuance() async {
    final issuedAt = _now().toUtc();
    final validUntil = DateTime.utc(
      issuedAt.year + _validityYears,
      issuedAt.month,
      issuedAt.day,
      issuedAt.hour,
      issuedAt.minute,
    );
    try {
      await _credentialService.writeCachedCredential(
        token: _syntheticToken,
        validUntil: validUntil,
        holderName: _holderName,
        documentLast4: _documentLast4,
      );
    } catch (e, st) {
      return Result.error(e, st);
    }
    return Result.ok(
      IssuanceOutcome.activated(
        credential: ActivatedCredential(
          holderName: _holderName,
          documentLast4: _documentLast4,
          issuingCountry: 'COL',
          issuedAt: issuedAt,
          validUntil: validUntil,
        ),
      ),
    );
  }
}
