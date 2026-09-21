import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/consent_record.dart';
import '../entities/consent_text_version.dart';

/// The domain-owned port `ConsentViewModel` (and the withdrawal placeholder
/// view) depend on, per contracts/consent-repository-port.md. Constitution
/// Principle IX (Result objects) applies: no `dio` exception type or raw
/// JSON shape may appear outside `data/services/` — consumers only ever see
/// `ConsentTextVersion`/`ConsentRecord`/`Result`.
abstract class ConsentRepository {
  /// Always a live fetch (research.md §5) — a previously-successful fetch
  /// is never reused as a fallback for a failed one. `Error` on any
  /// network/parse failure; `ConsentViewModel` maps this directly to the
  /// gate's blocking "unavailable" state (Edge Cases).
  @useResult
  Future<Result<ConsentTextVersion>> getCurrentText();

  /// Generates a fresh `EnrollmentAttemptId` (research.md §3), submits to
  /// the backend, and — only after the backend confirms — persists the
  /// local copy and returns `Ok`. If the device is offline or the backend
  /// call fails, returns `Error`; the caller does NOT advance past the
  /// gate (FR-008). Recording is never attempted while offline rather than
  /// queued like withdrawal — FR-007 requires the record to exist before
  /// any capture surface is reachable.
  @useResult
  Future<Result<ConsentRecord>> recordConsent({required String textVersionId});

  /// Reads the local secure-storage copy, or `Ok(null)` if none exists.
  /// Used both to decide whether to skip the gate (already consented to
  /// the current version) and to check currency (comparing
  /// `.textVersionId` against a fresh `getCurrentText().id` is the
  /// caller's job, to keep this a single-responsibility read).
  @useResult
  Future<Result<ConsentRecord?>> getLocalRecord();

  /// Transitions the local record to `withdrawalPending` immediately
  /// (local effect, SC-005 — no network dependency for this step) and
  /// attempts backend delivery inline; if that attempt fails, the record
  /// stays `withdrawalPending` locally and `retryPendingWithdrawal()`
  /// picks it up later. Returns `Error` only if there is no local record
  /// to withdraw in the first place.
  @useResult
  Future<Result<ConsentRecord>> withdraw();

  /// No-op if there's no `withdrawalPending` record, or if a delivery
  /// attempt is already in flight. Never throws — failures are swallowed
  /// and simply retried on the next call (research.md §4's opportunistic
  /// trigger from `_redirect`).
  Future<void> retryPendingWithdrawal();
}
