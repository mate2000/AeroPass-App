import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/credential_summary.dart';
import '../../domain/repositories/credential_summary_repository.dart';
import '../models/credential_status_response.dart';
import 'credential_service.dart';

/// The real `CredentialSummaryRepository` (012-mis-viajes,
/// contracts/credential-summary-port.md), over the same status endpoint as
/// 001.
///
/// `confirmed: true` only ever comes from a backend answer. When the
/// backend cannot be reached, the state is inferred from the stored
/// validity and marked unconfirmed, so "ACTIVA" cannot appear (FR-003).
class CredentialSummaryRepositoryImpl implements CredentialSummaryRepository {
  CredentialSummaryRepositoryImpl(this._service, {required Clock clock})
    : _clock = clock;

  final CredentialService _service;
  final Clock _clock;

  static final _last4Pattern = RegExp(r'^\d{4}$');

  @override
  Future<Result<CredentialSummary>> getSummary() async {
    final cached = await _safely(_service.readCachedCredential);
    final stored = await _safely(_service.readDisplayFields);
    final storedName = stored?.holderName;
    final storedLast4 = _last4(stored?.documentLast4);

    final CredentialStatusResponse remote;
    try {
      remote = await _service.fetchStatus(token: cached?.token);
    } catch (e, st) {
      if (cached == null) return Result.error(e, st);
      return Result.ok(
        CredentialSummary(
          holderName: storedName,
          documentLast4: storedLast4,
          state: cached.validUntil.isAfter(_clock.now())
              ? CredentialDisplayState.active
              : CredentialDisplayState.expired,
          confirmed: false,
        ),
      );
    }

    if (cached == null) return Result.error(const NoCredentialFailure());

    final state = switch (remote.status) {
      'valid' => CredentialDisplayState.active,
      'revoked' => CredentialDisplayState.revoked,
      'suspended' => CredentialDisplayState.suspended,
      'no_credential' => null,
      // An unrecognized status is never read as active.
      _ => CredentialDisplayState.expired,
    };
    if (state == null) return Result.error(const NoCredentialFailure());

    final remoteName = remote.holderName?.trim();
    final name = (remoteName == null || remoteName.isEmpty)
        ? storedName
        : remoteName;
    final last4 = _last4(remote.documentLast4) ?? storedLast4;
    if (name != storedName || last4 != storedLast4) {
      await _safely(
        () =>
            _service.writeDisplayFields(holderName: name, documentLast4: last4),
      );
    }
    return Result.ok(
      CredentialSummary(
        holderName: name,
        documentLast4: last4,
        state: state,
        confirmed: true,
      ),
    );
  }

  /// Exactly four digits, or null; nothing longer is ever kept (FR-002).
  static String? _last4(String? value) =>
      value != null && _last4Pattern.hasMatch(value) ? value : null;

  static Future<T?> _safely<T>(Future<T> Function() read) async {
    try {
      return await read();
    } catch (_) {
      return null;
    }
  }
}
