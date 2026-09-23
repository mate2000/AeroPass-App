import '../../core/result.dart';
import '../../domain/entities/activated_credential.dart';
import '../../domain/entities/credential_lifecycle_status.dart';
import '../../domain/entities/issuance_outcome.dart';
import '../../domain/repositories/consent_repository.dart';
import '../../domain/repositories/credential_issuance_repository.dart';
import '../models/credential_issuance_response.dart';
import 'credential_issuance_service.dart';
import 'credential_service.dart';
import 'transport_error_mapper.dart';

/// The real `CredentialIssuanceRepository` (008-identidad-activa,
/// contracts/credential-issuance-port.md). Owns 100% of the mapping from the
/// wire response to [IssuanceOutcome] (Constitution Principle II): no DTO,
/// `dio` type or backend code crosses out of this class.
class CredentialIssuanceRepositoryImpl implements CredentialIssuanceRepository {
  CredentialIssuanceRepositoryImpl(
    this._service, {
    required CredentialService credentialService,
    required ConsentRepository consentRepository,
  }) : _credentialService = credentialService,
       _consentRepository = consentRepository;

  final CredentialIssuanceService _service;
  final CredentialService _credentialService;
  final ConsentRepository _consentRepository;

  static final _last4Pattern = RegExp(r'^\d{4}$');
  static final _alpha3Pattern = RegExp(r'^[A-Z]{3}$');

  @override
  Future<Result<IssuanceOutcome>> requestIssuance() async {
    final consentResult = await _consentRepository.getLocalRecord();
    final attemptId = consentResult.valueOrNull?.enrollmentAttemptId.value;
    if (attemptId == null) {
      return Result.error(
        StateError('no local consent record to correlate issuance with'),
      );
    }

    final CredentialIssuanceResponse response;
    try {
      response = await _service.requestIssuance(enrollmentAttemptId: attemptId);
    } catch (e, st) {
      // Offline, timeout, non-2xx, pinning failure (research.md §2, rule 1),
      // wrapped so 011 can tell the connection from the service.
      return Result.error(mapTransportError(e), st);
    }

    final outcome = _map(response);
    if (outcome case IssuanceActivated()) {
      try {
        // Research.md §3: durable before success is reported, so a relaunch
        // always finds a credential the passenger was shown as active.
        await _credentialService.writeCachedCredential(
          token: response.token!,
          validUntil: outcome.credential.validUntil,
          holderName: outcome.credential.holderName,
          documentLast4: outcome.credential.documentLast4,
        );
      } catch (e, st) {
        await _clearPartialWrite();
        return Result.error(e, st);
      }
    }
    return Result.ok(outcome);
  }

  /// Research.md §2's rules 2–5, in order.
  IssuanceOutcome _map(CredentialIssuanceResponse response) {
    final status = _statusFor(response.status);
    if (status == null) return const IssuanceOutcome.incomplete();
    if (status != CredentialLifecycleStatus.active) {
      return IssuanceOutcome.notActive(status: status);
    }

    final holderName = response.holderName?.trim() ?? '';
    final last4 = response.documentLast4 ?? '';
    final country = response.issuingCountry ?? '';
    final token = response.token ?? '';
    final issuedAt = DateTime.tryParse(response.issuedAt ?? '');
    final validUntil = DateTime.tryParse(response.validUntil ?? '');
    final complete =
        holderName.isNotEmpty &&
        _last4Pattern.hasMatch(last4) &&
        _alpha3Pattern.hasMatch(country) &&
        token.isNotEmpty &&
        issuedAt != null &&
        validUntil != null &&
        validUntil.isAfter(issuedAt);
    if (!complete) return const IssuanceOutcome.incomplete();

    return IssuanceOutcome.activated(
      credential: ActivatedCredential(
        holderName: holderName,
        documentLast4: last4,
        issuingCountry: country,
        issuedAt: issuedAt.toUtc(),
        validUntil: validUntil.toUtc(),
      ),
    );
  }

  /// An unrecognized or missing status is never guessed at (research.md
  /// §2, rule 2).
  CredentialLifecycleStatus? _statusFor(String? wire) => switch (wire) {
    'active' => CredentialLifecycleStatus.active,
    'expired' => CredentialLifecycleStatus.expired,
    'revoked' => CredentialLifecycleStatus.revoked,
    'suspended' => CredentialLifecycleStatus.suspended,
    'withdrawn' => CredentialLifecycleStatus.withdrawn,
    _ => null,
  };

  /// A failed two-key write must not leave a token behind without its
  /// validity (or vice versa).
  Future<void> _clearPartialWrite() async {
    try {
      await _credentialService.clearCachedCredential();
    } catch (_) {
      // Best effort: `readCachedCredential()` already ignores a lone key.
    }
  }
}
