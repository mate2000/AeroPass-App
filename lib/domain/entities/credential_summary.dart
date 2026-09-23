import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential_summary.freezed.dart';

/// The state the home strip names (012-mis-viajes, data-model.md).
enum CredentialDisplayState { active, expired, revoked, suspended }

/// The compact credential on Mis viajes: holder, masked number and state
/// (012-mis-viajes, contracts/credential-summary-port.md).
///
/// [confirmed] is true only when this read reached the backend. The badge
/// "ACTIVA" is rendered from [showsActive] and nothing else (FR-003).
@freezed
sealed class CredentialSummary with _$CredentialSummary {
  const CredentialSummary._();

  const factory CredentialSummary({
    String? holderName,

    /// Exactly four digits, or null. The full number is never held (FR-002).
    String? documentLast4,
    required CredentialDisplayState state,
    required bool confirmed,
  }) = _CredentialSummary;

  /// The only path to "ACTIVA": active, and affirmed by the backend on this
  /// read.
  bool get showsActive => state == CredentialDisplayState.active && confirmed;
}
