import 'package:freezed_annotation/freezed_annotation.dart';

part 'field_reverification_outcome.freezed.dart';

/// The result of `FieldReverificationRepository.reverify(...)` — research.md
/// §4, FR-005. A transport `Result.error` is treated identically to
/// [disagreed] by `DocumentConfirmationViewModel` (research.md §6): both
/// mean "the automated re-check could not confirm the edit," and neither
/// falls back to an agent (Clarifications).
@freezed
sealed class FieldReverificationOutcome with _$FieldReverificationOutcome {
  /// The automated re-read of the disputed field, from the retained
  /// document image, agrees with the passenger's edited value.
  const factory FieldReverificationOutcome.confirmed() =
      FieldReverificationOutcomeConfirmed;

  /// It does not.
  const factory FieldReverificationOutcome.disagreed() =
      FieldReverificationOutcomeDisagreed;
}
