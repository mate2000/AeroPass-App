import '../../core/result.dart';
import '../../domain/entities/credential_summary.dart';
import '../../domain/repositories/credential_summary_repository.dart';
import '../services/credential_service.dart';

/// Happy-path stand-in for the credential status backend on Mis viajes
/// (012-mis-viajes research.md §3), behind `USE_FAKE_VERIFICATION_BACKEND`.
///
/// It plays the backend: a stored token is affirmed as active, with the
/// stored display fields. The badge still comes from this answer, never
/// from a constant in the screen.
class DevCredentialSummaryRepository implements CredentialSummaryRepository {
  DevCredentialSummaryRepository({required CredentialService credentialService})
    : _service = credentialService;

  final CredentialService _service;

  @override
  Future<Result<CredentialSummary>> getSummary() async {
    try {
      final cached = await _service.readCachedCredential();
      if (cached == null) return Result.error(const NoCredentialFailure());
      final fields = await _service.readDisplayFields();
      return Result.ok(
        CredentialSummary(
          holderName: fields.holderName,
          documentLast4: fields.documentLast4,
          state: CredentialDisplayState.active,
          confirmed: true,
        ),
      );
    } catch (e, st) {
      return Result.error(e, st);
    }
  }
}
