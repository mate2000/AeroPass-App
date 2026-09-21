import 'package:freezed_annotation/freezed_annotation.dart';

import 'enrollment_attempt_id.dart';
import 'processing_scope.dart';

part 'consent_record.freezed.dart';

/// A `ConsentRecord`'s state-machine position, per data-model.md:
/// `active -> withdrawalPending -> withdrawn`, with no path back to
/// `active`. A plain closed enum (not a payload-carrying sealed class,
/// mirroring `ExpiryReason`'s precedent) — none of the three states carry
/// state-specific fields; `withdrawalRequestedAt` lives on `ConsentRecord`
/// itself, set only once `status` leaves `active`.
enum ConsentRecordStatus { active, withdrawalPending, withdrawn }

/// The **only** new persisted entity this feature introduces (data-model.md,
/// plan.md's Constitution Check): withdrawal is a status transition on this
/// same record, never a second persisted entity. Backed by the backend as
/// the system of record, with a local secure-storage copy for display and
/// for deciding whether to re-present the gate (Constitution Principle I's
/// persisted-state allowlist: "the user's consent record with timestamp and
/// version").
@freezed
sealed class ConsentRecord with _$ConsentRecord {
  const factory ConsentRecord({
    /// References the `ConsentTextVersion.id` shown at confirmation time.
    required String textVersionId,

    /// Durable anonymous identifier, generated at confirmation
    /// (research.md §3).
    required EnrollmentAttemptId enrollmentAttemptId,

    /// FR-005: never bundles another purpose.
    required ProcessingScope scope,
    required DateTime confirmedAt,
    required ConsentRecordStatus status,

    /// Set when `status` becomes `withdrawalPending`; null while `active`.
    DateTime? withdrawalRequestedAt,
  }) = _ConsentRecord;
}
