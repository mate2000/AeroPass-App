import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/activated_credential.dart';
import '../../domain/entities/credential_lifecycle_status.dart';
import '../../domain/entities/issuance_outcome.dart';
import '../../domain/entities/passenger_record.dart';
import '../../domain/repositories/credential_issuance_repository.dart';
import 'passenger_backed_credential_repository.dart';
import 'passenger_mapper.dart';

/// 008's [CredentialIssuanceRepository] against the real backend (015
/// research.md §9). There is no issuance call: the backend creates the
/// identity inside the verification itself. "Issuance" here means reading
/// `/me` and reporting what it says.
///
/// | `/me` | Outcome |
/// |---|---|
/// | verified with an identity | activated. The credential is cached first |
/// | verified without an identity, or pending | incomplete. Never shown active |
/// | manual review | not active (suspended) |
/// | not registered | incomplete |
/// | unreachable | the error |
class PassengerIssuanceRepository implements CredentialIssuanceRepository {
  PassengerIssuanceRepository(this._passengers, {required Clock clock})
    : _clock = clock;

  final PassengerBackedCredentialRepository _passengers;
  final Clock _clock;

  @override
  Future<Result<IssuanceOutcome>> requestIssuance() async {
    final result = await _passengers.meAndSync();
    switch (result) {
      case Error(:final error, :final stackTrace):
        return Result.error(error, stackTrace);
      case Ok(value: final passenger):
        if (passenger == null) {
          return const Result.ok(IssuanceOutcome.incomplete());
        }
        return Result.ok(switch (passenger.state) {
          PassengerState.verified when passenger.identityId != null =>
            IssuanceOutcome.activated(credential: _credentialFor(passenger)),
          PassengerState.verified || PassengerState.pendingVerification =>
            const IssuanceOutcome.incomplete(),
          PassengerState.manualReview => const IssuanceOutcome.notActive(
            status: CredentialLifecycleStatus.suspended,
          ),
        });
    }
  }

  ActivatedCredential _credentialFor(PassengerRecord passenger) {
    final expiry = passenger.documentExpiry;
    return ActivatedCredential(
      holderName: passenger.holderName,
      documentLast4: lastFourOf(passenger.maskedNumber),
      // CC and CE are Colombian documents. A passport's country is not
      // sent by the backend, so none is claimed.
      issuingCountry: passenger.documentType == DocumentType.pasaporte
          ? ''
          : 'COL',
      issuedAt: _clock.now(),
      validUntil: DateTime(expiry.year, expiry.month, expiry.day + 1),
    );
  }
}
