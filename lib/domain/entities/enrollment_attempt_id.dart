import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/uuid.dart';

part 'enrollment_attempt_id.freezed.dart';

/// A durable, anonymous identifier generated once, at consent confirmation,
/// and persisted as part of the `ConsentRecord` (data-model.md, research.md
/// §3, spec.md's Clarifications).
///
/// **Distinct from `AnalyticsSessionId`**: that identifier is deliberately
/// in-memory/per-launch only and never persisted; this one is durable
/// specifically so later steps (document capture, credential issuance) can
/// still be correlated with the same enrollment attempt across a resume
/// that spans app launches. Carries no personal data itself.
///
/// Reuses the existing `core/uuid.dart` generator (research.md §3) — no new
/// `uuid` package dependency.
@freezed
sealed class EnrollmentAttemptId with _$EnrollmentAttemptId {
  const factory EnrollmentAttemptId(String value) = _EnrollmentAttemptId;

  /// Generates a fresh v4-UUID-backed identifier.
  factory EnrollmentAttemptId.generate() =>
      EnrollmentAttemptId(generateUuidV4());
}
