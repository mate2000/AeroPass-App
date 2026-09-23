import 'dart:async' show unawaited;
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart';

import '../../../core/command.dart';
import '../../../core/result.dart';
import '../../../domain/entities/consent_record.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/consent_repository.dart';
import 'consent_view_state.dart';

/// The consent gate's ViewModel: fetches the current consent text,
/// classifies it into [ConsentViewState], gates the confirm action behind
/// the confirmation checkbox, and records (or declines) consent.
///
/// No `package:flutter/material.dart` import, no widget — testable
/// headless (Constitution Principle VIII). Both dependencies are
/// constructor-injected (Principle IX); this class never reaches into a
/// service locator.
class ConsentViewModel extends ChangeNotifier {
  ConsentViewModel({
    required ConsentRepository consentRepository,
    required AnalyticsEmitter analyticsEmitter,
  }) : _consentRepository = consentRepository,
       _analyticsEmitter = analyticsEmitter {
    confirm = Command0(_confirm);
    // The bool argument distinguishes the explicit "Ahora no" tap (false)
    // from every dismissal-equivalent vector — back gesture, barrier tap,
    // system navigation (true) — per research.md §2: all three vectors
    // invoke this SAME Command, so "dismissal is never treated as
    // acceptance" (FR-010) is structurally guaranteed rather than
    // remembered per call site.
    decline = Command1(_decline);
    unawaited(_load());
  }

  final ConsentRepository _consentRepository;
  final AnalyticsEmitter _analyticsEmitter;

  /// Records consent for the currently-displayed text version (FR-007).
  /// A defensive no-op if the checkbox isn't checked — the primary action
  /// button is disabled in that state (FR-006), so this only guards
  /// against a stray invocation.
  late final Command0<void> confirm;

  /// Declines/dismisses the gate. `run(true)` for a dismissal-equivalent
  /// vector, `run(false)` for the explicit "Ahora no" tap — both produce
  /// the identical no-record outcome (FR-009/FR-010); only the analytics
  /// event emitted differs.
  late final Command1<void, bool> decline;

  ConsentViewState _state = const ConsentViewState.loading();
  ConsentViewState get state => _state;

  /// True only when the gate is [ConsentViewReady] and the confirmation
  /// checkbox is checked — the single source of truth the primary action
  /// button's enabled state (and its semantics) is derived from (FR-006).
  bool get canConfirm {
    final state = _state;
    return state is ConsentViewReady && state.checkboxChecked;
  }

  /// Classifies the most recent [confirm] failure, or `null` if it hasn't
  /// failed (including while it has never run, or is currently running).
  /// `ConsentView` uses this to render the inline blocked-start message
  /// (FR-008).
  UnavailableReason? get confirmFailureReason {
    final result = confirm.result;
    return result?.when(
      ok: (_) => null,
      error: (error, _) => _classifyUnavailable(error),
    );
  }

  /// Re-attempts the current-text fetch (e.g. after a tap on the
  /// full-page unavailable state's retry action).
  void retry() {
    unawaited(_load());
  }

  void _setState(ConsentViewState next) {
    _state = next;
    notifyListeners();
  }

  /// Toggles the confirmation checkbox (FR-004: unchecked by default,
  /// never pre-selected). A no-op if the gate isn't in its ready state.
  void toggleCheckbox(bool checked) {
    final state = _state;
    if (state is! ConsentViewReady) return;
    _setState(state.copyWith(checkboxChecked: checked));
  }

  Future<void> _load() async {
    _setState(const ConsentViewState.loading());

    final localResult = await _consentRepository.getLocalRecord();
    final localRecord = localResult.valueOrNull;

    final textResult = await _consentRepository.getCurrentText();
    textResult.when(
      ok: (text) {
        // FR-014: re-presenting the gate for a superseded version is
        // this comparison's job — a local record whose textVersionId no
        // longer matches the freshly-fetched current version's id is
        // stale evidence, surfaced here (and to analytics) rather than
        // silently treated as still covering the new terms.
        final hasPriorRecord =
            localRecord != null &&
            localRecord.status == ConsentRecordStatus.active &&
            localRecord.textVersionId != text.id;
        _analyticsEmitter.consentGateShown(hasPriorRecord: hasPriorRecord);
        _setState(
          ConsentViewState.ready(text: text, hasPriorRecord: hasPriorRecord),
        );
      },
      error: (error, stackTrace) {
        final reason = _classifyUnavailable(error);
        _analyticsEmitter.consentGateUnavailableShown(reason: reason);
        _setState(ConsentViewState.unavailable(reason: reason));
      },
    );
  }

  UnavailableReason _classifyUnavailable(Object error) {
    return error is SocketException
        ? UnavailableReason.offline
        : UnavailableReason.fetchError;
  }

  Future<Result<void>> _confirm() async {
    final state = _state;
    if (state is! ConsentViewReady || !state.checkboxChecked) {
      // Defensive: the button is disabled in this state (FR-006), so this
      // path is never reachable from the UI.
      return const Result.ok(null);
    }

    final result = await _consentRepository.recordConsent(
      textVersionId: state.text.id,
    );
    return result.when(
      ok: (record) {
        _analyticsEmitter.consentConfirmed(textVersionId: record.textVersionId);
        return const Result.ok(null);
      },
      error: (error, stackTrace) {
        // FR-008: the flow does NOT advance; the confirm Command's own
        // error state is what `ConsentView` renders the blocked-start
        // message from (no optimistic state, Principle IX).
        _analyticsEmitter.consentConfirmFailed();
        return Result.error(error, stackTrace);
      },
    );
  }

  Future<Result<void>> _decline(bool dismissed) async {
    if (dismissed) {
      _analyticsEmitter.consentDismissed();
    } else {
      _analyticsEmitter.consentDeclined();
    }
    // FR-009/FR-010: no repository call — declining/dismissing records
    // nothing and transmits nothing.
    return const Result.ok(null);
  }

  @override
  void dispose() {
    confirm.dispose();
    decline.dispose();
    super.dispose();
  }
}
