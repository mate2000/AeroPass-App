import 'package:flutter/foundation.dart';

import '../../../app/enrollment_session_controller.dart';
import '../../../app/pending_document_controller.dart';
import '../../../core/clock.dart';
import '../../../core/command.dart';
import '../../../core/result.dart';
import '../../../domain/entities/extraction_result.dart';
import '../../../domain/entities/field_reverification_outcome.dart';
import '../../../domain/entities/identity_record.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/field_reverification_repository.dart';
import '../../../domain/repositories/identity_record_repository.dart';
import 'document_confirmation_view_state.dart';

/// The argument to [DocumentConfirmationViewModel.editField]: the field
/// being edited and its passenger-submitted value.
typedef FieldEditRequest = ({FieldKey key, String value});

/// FR-005/Clarifications: the processor-reported confidence at or above
/// which a field is "high confidence" and its edits are never accepted on
/// the passenger's assertion alone.
const highConfidenceThreshold = 0.95;

/// FR-019: the session-scoped cap on unresolved correction attempts before
/// the passenger is routed to re-scan.
const correctionAttemptLimit = 3;

/// The data-confirmation step's ViewModel (spec.md screen 04): reads the
/// document image and extraction 003-escanear-documento handed off via
/// [PendingDocumentController], lets the passenger review and correct
/// fields, and confirms — durably, through [IdentityRecordRepository] —
/// before advancing to the selfie step.
///
/// No `package:flutter/material.dart` import, no widget — testable headless
/// (Constitution Principle VIII). Every dependency is constructor-injected
/// (Principle IX).
class DocumentConfirmationViewModel extends ChangeNotifier {
  DocumentConfirmationViewModel({
    required PendingDocumentController pendingDocumentController,
    required FieldReverificationRepository fieldReverificationRepository,
    required IdentityRecordRepository identityRecordRepository,
    required AnalyticsEmitter analyticsEmitter,
    required EnrollmentSessionController enrollmentSessionController,
    required Clock clock,
  }) : _pendingDocumentController = pendingDocumentController,
       _fieldReverificationRepository = fieldReverificationRepository,
       _identityRecordRepository = identityRecordRepository,
       _analyticsEmitter = analyticsEmitter,
       _enrollmentSessionController = enrollmentSessionController,
       _clock = clock {
    confirm = Command0(_confirm);
    rescan = Command0(_rescan);
    editField = Command1(_editField);
    _load();
  }

  final PendingDocumentController _pendingDocumentController;
  final FieldReverificationRepository _fieldReverificationRepository;
  final IdentityRecordRepository _identityRecordRepository;
  final AnalyticsEmitter _analyticsEmitter;
  final EnrollmentSessionController _enrollmentSessionController;
  final Clock _clock;

  /// FR-003/FR-004: the "Los datos son correctos" action.
  late final Command0<void> confirm;

  /// FR-010/FR-019: "Escanear de nuevo," and where the correction-attempt
  /// cap routes automatically.
  late final Command0<void> rescan;

  /// FR-004/FR-005/FR-006: editing a single field.
  late final Command1<void, FieldEditRequest> editField;

  DocumentConfirmationViewState _state =
      const DocumentConfirmationViewState.loading();
  DocumentConfirmationViewState get state => _state;

  DocumentConfirmationNavigationTarget? _pendingNavigation;

  /// A one-shot navigation instruction for `DocumentConfirmationView` to
  /// act on, then clear via [consumeNavigation].
  DocumentConfirmationNavigationTarget? get pendingNavigation =>
      _pendingNavigation;

  void consumeNavigation() {
    _pendingNavigation = null;
  }

  Uint8List? _documentImageBytes;

  /// The retained document image, for the thumbnail (FR-001). `null` before
  /// [state] leaves [DocumentConfirmationViewLoading].
  Uint8List? get documentImageBytes => _documentImageBytes;

  int _unresolvedAttempts = 0;
  bool _outcomeRecorded = false;

  void _setState(DocumentConfirmationViewState next) {
    _state = next;
    notifyListeners();
  }

  void _load() {
    if (!_pendingDocumentController.hasPendingDocument) {
      // A deep link straight into this route, or the process was relaunched
      // and lost the in-memory hand-off — defensive redirect, mirrors
      // 003's consent-gate guard.
      _pendingNavigation = DocumentConfirmationNavigationTarget.documentCapture;
      notifyListeners();
      return;
    }
    _documentImageBytes = _pendingDocumentController.documentImageBytes;
    final extraction = _pendingDocumentController.extraction!;

    final expiryDate = extraction.parsedExpiryDate;
    if (expiryDate != null && expiryDate.isBefore(_clock.now())) {
      _analyticsEmitter.confirmationBlockedUnusableDocument(
        reason: DocumentBlockReason.expired,
      );
      _setState(
        const DocumentConfirmationViewState.blocked(
          reason: DocumentBlockReason.expired,
        ),
      );
      return;
    }
    final hasMissingField = extraction.fields.any(
      (field) => field is ExtractedFieldMissing,
    );
    if (hasMissingField) {
      _analyticsEmitter.confirmationBlockedUnusableDocument(
        reason: DocumentBlockReason.missingRequiredField,
      );
      _setState(
        const DocumentConfirmationViewState.blocked(
          reason: DocumentBlockReason.missingRequiredField,
        ),
      );
      return;
    }

    _analyticsEmitter.confirmationStepEntered();
    final fields = [
      for (final field in extraction.fields)
        if (field is ExtractedFieldPresent)
          FieldRowState(
            key: field.key,
            currentValue: field.value,
            originalValue: field.value,
            originalConfidence: field.confidence,
          ),
    ];
    _setState(DocumentConfirmationViewState.ready(fields: fields));
  }

  Future<Result<void>> _editField(FieldEditRequest request) async {
    final current = _state;
    if (current is! DocumentConfirmationViewReady) return const Result.ok(null);
    final row = current.fields.firstWhere(
      (f) => f.key == request.key,
      orElse: () => throw StateError('unknown field: ${request.key}'),
    );

    _analyticsEmitter.confirmationFieldEdited(field: request.key);
    final trimmed = request.value.trim();

    if (trimmed == row.originalValue.trim()) {
      // Reverted to the original value: clears any unresolved state
      // without counting as a resolved attempt (research.md §6).
      _updateField(
        row.copyWith(
          currentValue: row.originalValue,
          status: const FieldCorrectionStatus.unedited(),
        ),
      );
      return const Result.ok(null);
    }

    if (!_isValidFormat(request.key, trimmed)) {
      _updateField(
        row.copyWith(
          currentValue: trimmed,
          status: const FieldCorrectionStatus.invalidFormat(),
        ),
      );
      return const Result.ok(null);
    }

    if (row.originalConfidence < highConfidenceThreshold) {
      _updateField(
        row.copyWith(
          currentValue: trimmed,
          status: const FieldCorrectionStatus.acceptedLowConfidence(),
        ),
      );
      return const Result.ok(null);
    }

    // FR-005: a material change to a high-confidence field is never
    // accepted on the passenger's assertion alone.
    _updateField(
      row.copyWith(
        currentValue: trimmed,
        status: const FieldCorrectionStatus.reverifying(),
      ),
    );
    final bytes = _documentImageBytes!;
    final result = await _fieldReverificationRepository.reverify(
      documentImageBytes: bytes,
      field: request.key,
      candidateValue: trimmed,
    );
    return result.when(
      ok: (outcome) {
        final confirmed = outcome is FieldReverificationOutcomeConfirmed;
        _analyticsEmitter.confirmationFieldReverified(
          field: request.key,
          confirmed: confirmed,
        );
        if (confirmed) {
          _updateField(
            row.copyWith(
              currentValue: trimmed,
              status: const FieldCorrectionStatus.acceptedReverified(),
            ),
          );
        } else {
          _registerUnresolved(row, trimmed);
        }
        return const Result.ok(null);
      },
      error: (_, _) {
        // Clarifications: a transport failure is treated identically to a
        // disagreed() outcome — no agent-escalation fallback either way.
        _analyticsEmitter.confirmationFieldReverified(
          field: request.key,
          confirmed: false,
        );
        _registerUnresolved(row, trimmed);
        return const Result.ok(null);
      },
    );
  }

  void _updateField(FieldRowState updated) {
    final current = _state;
    if (current is! DocumentConfirmationViewReady) return;
    final fields = [
      for (final f in current.fields)
        if (f.key == updated.key) updated else f,
    ];
    _setState(current.copyWith(fields: fields));
  }

  /// FR-019: counts one unresolved correction attempt (a high-confidence
  /// edit the automated re-check could not confirm) against the
  /// session-scoped cap; on reaching it, discards the extraction and routes
  /// to re-scan rather than permitting further edits.
  void _registerUnresolved(FieldRowState originalRow, String attemptedValue) {
    _updateField(
      originalRow.copyWith(
        currentValue: attemptedValue,
        status: const FieldCorrectionStatus.unresolved(),
      ),
    );
    _unresolvedAttempts++;
    if (_unresolvedAttempts >= correctionAttemptLimit) {
      _analyticsEmitter.confirmationCorrectionAttemptLimitReached();
      _discardAndReturnToCapture();
    }
  }

  bool _isValidFormat(FieldKey key, String value) {
    if (value.isEmpty) return false;
    return switch (key) {
      FieldKey.fullName => true,
      FieldKey.documentNumber => value.contains(RegExp('[0-9]')),
      FieldKey.nationality => true,
      FieldKey.expiryDate => DateTime.tryParse(value) != null,
    };
  }

  Future<Result<void>> _rescan() async {
    _analyticsEmitter.confirmationRescanned();
    _discardAndReturnToCapture();
    return const Result.ok(null);
  }

  void _discardAndReturnToCapture() {
    _outcomeRecorded = true;
    _pendingDocumentController.clear();
    _pendingNavigation = DocumentConfirmationNavigationTarget.documentCapture;
    notifyListeners();
  }

  Future<Result<void>> _confirm() async {
    final current = _state;
    if (current is! DocumentConfirmationViewReady) return const Result.ok(null);
    if (current.confirming || !_canConfirm(current)) {
      return const Result.ok(null);
    }

    _setState(current.copyWith(confirming: true, confirmFailed: false));
    final record = IdentityRecord(
      fields: [
        for (final f in current.fields)
          ConfirmedField(
            key: f.key,
            value: f.currentValue,
            source: f.isCorrected
                ? FieldSource.passengerCorrected
                : FieldSource.machineRead,
            originalValue: f.isCorrected ? f.originalValue : null,
            reverified: f.isReverified,
          ),
      ],
    );
    final result = await _identityRecordRepository.confirm(record);
    return result.when(
      ok: (_) {
        _outcomeRecorded = true;
        _analyticsEmitter.confirmationConfirmed();
        _pendingDocumentController.clear();
        _enrollmentSessionController.markIdentityConfirmed();
        _pendingNavigation =
            DocumentConfirmationNavigationTarget.selfieInstructions;
        _setState(current.copyWith(confirming: false));
        return const Result.ok(null);
      },
      error: (e, st) {
        // FR-017: confirmation not recorded, the flow does not advance.
        _analyticsEmitter.confirmationConfirmFailed();
        _setState(current.copyWith(confirming: false, confirmFailed: true));
        return Result.error(e, st);
      },
    );
  }

  bool _canConfirm(DocumentConfirmationViewReady state) =>
      state.fields.every((f) => !f.blocksConfirmation);

  /// FR-013: called by `DocumentConfirmationView` on explicit back
  /// navigation. Always discards the held image (never on forward
  /// navigation, which clears it via confirm/re-scan instead); records
  /// abandonment only if no outcome was recorded yet.
  void onBackNavigation() {
    _pendingDocumentController.clear();
    if (!_outcomeRecorded) {
      _analyticsEmitter.confirmationStepAbandoned();
    }
  }

  @override
  void dispose() {
    confirm.dispose();
    rescan.dispose();
    editField.dispose();
    super.dispose();
  }
}
