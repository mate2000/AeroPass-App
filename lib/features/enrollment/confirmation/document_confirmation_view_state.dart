import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/document_validity.dart';
import '../../../domain/entities/extraction_result.dart';

export '../../../domain/entities/document_validity.dart'
    show DocumentBlockReason;
export '../../../domain/entities/extraction_result.dart' show FieldKey;

part 'document_confirmation_view_state.freezed.dart';

/// One field's correction lifecycle (data-model.md's `FieldCorrectionState`
/// distilled to just the status — the rest of that shape lives directly on
/// [FieldRowState]). Drives FR-007's "confirmation unavailable while any
/// field is invalid or unresolved."
@freezed
sealed class FieldCorrectionStatus with _$FieldCorrectionStatus {
  /// The passenger hasn't touched this field (or reverted it back to the
  /// original extracted value).
  const factory FieldCorrectionStatus.unedited() = FieldCorrectionUnedited;

  /// The edited value doesn't match the field's expected form (FR-006).
  const factory FieldCorrectionStatus.invalidFormat() =
      FieldCorrectionInvalidFormat;

  /// The processor's original confidence for this field was below the
  /// high-confidence threshold — the edit is accepted without a re-check
  /// (Clarifications).
  const factory FieldCorrectionStatus.acceptedLowConfidence() =
      FieldCorrectionAcceptedLowConfidence;

  /// A high-confidence field's edit is being automatically re-checked
  /// against the retained image (FR-005).
  const factory FieldCorrectionStatus.reverifying() =
      FieldCorrectionReverifying;

  /// The automated re-check confirmed the edit.
  const factory FieldCorrectionStatus.acceptedReverified() =
      FieldCorrectionAcceptedReverified;

  /// The automated re-check could not confirm the edit (disagreed, or the
  /// re-check itself failed). Confirmation is blocked for this field until
  /// it's edited again or reverted (FR-005, FR-007).
  const factory FieldCorrectionStatus.unresolved() = FieldCorrectionUnresolved;
}

/// One row of the confirmation screen (FR-001–FR-009).
@freezed
sealed class FieldRowState with _$FieldRowState {
  const factory FieldRowState({
    required FieldKey key,

    /// The field's current value — original or edited. The raw/canonical
    /// form (ISO-8601 for `expiryDate`); the view formats it for display.
    required String currentValue,

    /// The machine-extracted value, before any edit. A `ready` state is
    /// only ever reached once every field has been confirmed present — a
    /// missing field blocks the whole screen instead (FR-009,
    /// `DocumentConfirmationViewBlocked`) — so this is never null here.
    required String originalValue,

    /// The processor's confidence for the original value.
    required double originalConfidence,
    @Default(FieldCorrectionStatus.unedited()) FieldCorrectionStatus status,
  }) = _FieldRowState;

  const FieldRowState._();

  /// Whether this field is [FieldSource.passengerCorrected] material — used
  /// to build the `IdentityRecord` on confirm.
  bool get isCorrected => switch (status) {
    FieldCorrectionAcceptedLowConfidence() ||
    FieldCorrectionAcceptedReverified() => true,
    _ => false,
  };

  bool get isReverified => status is FieldCorrectionAcceptedReverified;

  /// Whether this field, on its own, permits confirmation (FR-007).
  bool get blocksConfirmation => switch (status) {
    FieldCorrectionInvalidFormat() ||
    FieldCorrectionReverifying() ||
    FieldCorrectionUnresolved() => true,
    _ => false,
  };
}

/// `DocumentConfirmationViewModel`'s rendered state, per Constitution
/// Principle IX ("sealed types over boolean flags"):
///
/// - [DocumentConfirmationViewLoading]: reading `PendingDocumentController`.
/// - [DocumentConfirmationViewBlocked]: the document can never be confirmed
///   this session (expired) or is missing a required field — FR-008/FR-009.
/// - [DocumentConfirmationViewReady]: the normal review/edit/confirm state.
@freezed
sealed class DocumentConfirmationViewState
    with _$DocumentConfirmationViewState {
  const factory DocumentConfirmationViewState.loading() =
      DocumentConfirmationViewLoading;

  const factory DocumentConfirmationViewState.blocked({
    required DocumentBlockReason reason,
  }) = DocumentConfirmationViewBlocked;

  const factory DocumentConfirmationViewState.ready({
    required List<FieldRowState> fields,
    @Default(false) bool confirming,
    @Default(false) bool confirmFailed,
  }) = DocumentConfirmationViewReady;
}

/// A one-shot navigation instruction `DocumentConfirmationViewModel` raises
/// for `DocumentConfirmationView` to act on and then clear via
/// `consumeNavigation()` — mirrors `CaptureNavigationTarget`'s pattern.
enum DocumentConfirmationNavigationTarget {
  /// `PendingDocumentController` was empty on load (a deep link, or the
  /// process was relaunched) — defensive redirect, mirrors 003's
  /// consent-gate guard.
  documentCapture,

  /// Confirmation succeeded — advance to the selfie step (005 stub).
  selfieInstructions,
}
