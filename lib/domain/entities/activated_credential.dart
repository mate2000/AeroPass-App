import 'package:freezed_annotation/freezed_annotation.dart';

part 'activated_credential.freezed.dart';

/// The display subset of a credential the backend has just issued as
/// active (data-model.md, 008-identidad-activa).
///
/// Constructed only by a `CredentialIssuanceRepository` implementation, and
/// only once every validation rule in research.md §2 holds — so holding an
/// instance *is* the proof that the backend affirmed an active, complete
/// credential (FR-001, FR-010).
///
/// Deliberately has no `status` field (it is active by construction) and no
/// `token` field (the token goes to secure storage and never reaches the
/// display layer — FR-013). The full document number is never part of this
/// type (FR-003, SC-005).
@freezed
sealed class ActivatedCredential with _$ActivatedCredential {
  const factory ActivatedCredential({
    /// Non-empty. Announced in full to assistive technology (FR-014).
    required String holderName,

    /// Exactly four ASCII digits.
    required String documentLast4,

    /// ISO 3166-1 alpha-3, upper case (e.g. `COL`).
    required String issuingCountry,

    /// UTC. Displayed as "Creada el …".
    required DateTime issuedAt,

    /// UTC, strictly after [issuedAt]. Displayed as "Válida hasta …"
    /// (FR-004) — never computed by the app.
    required DateTime validUntil,
  }) = _ActivatedCredential;
}
