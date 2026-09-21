import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/consent_text_version.dart';
import '../../../domain/entities/consent_unavailable_reason.dart';

export '../../../domain/entities/consent_unavailable_reason.dart'
    show UnavailableReason;

part 'consent_view_state.freezed.dart';

/// `ConsentViewModel`'s rendered state, per Constitution Principle IX
/// ("sealed types over boolean flags"):
///
/// - [ConsentViewLoading]: the current consent text fetch is in flight
///   (research.md §5: always a live fetch, never a stale/cached fallback).
/// - [ConsentViewUnavailable]: the fetch failed (network or parse) — the
///   gate MUST block with an explanation rather than fall back to any
///   previously-fetched text (Edge Cases).
/// - [ConsentViewReady]: the fetched text is shown, gated by the
///   confirmation checkbox's state.
@freezed
sealed class ConsentViewState with _$ConsentViewState {
  const factory ConsentViewState.loading() = ConsentViewLoading;

  const factory ConsentViewState.unavailable({
    required UnavailableReason reason,
  }) = ConsentViewUnavailable;

  const factory ConsentViewState.ready({
    required ConsentTextVersion text,
    @Default(false) bool checkboxChecked,

    /// FR-014: true when a local `ConsentRecord` exists for a version
    /// other than [text]'s own `id` — the gate is being re-presented
    /// because the terms changed, not shown for the first time.
    @Default(false) bool hasPriorRecord,
  }) = ConsentViewReady;
}
