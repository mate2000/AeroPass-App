import 'dart:async' show Timer, unawaited;

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../app/activated_credential_handoff.dart';
import '../../../app/enrollment_session_controller.dart';
import '../../../core/clock.dart';
import '../../../core/result.dart';
import '../../../domain/entities/capture_attempt_counter.dart';
import '../../../domain/entities/escalation.dart';
import '../../../domain/entities/issuance_outcome.dart';
import '../../../domain/repositories/analytics_emitter.dart';
import '../../../domain/repositories/capture_attempt_counter_repository.dart';
import '../../../domain/repositories/credential_issuance_repository.dart';
import '../../../domain/repositories/escalation_repository.dart';

part 'escalation_viewmodel.freezed.dart';

/// How often an open escalation is checked (research.md §4).
const escalationPollInterval = Duration(seconds: 5);

/// What the escalation screen renders (data-model.md).
@freezed
sealed class EscalationViewState with _$EscalationViewState {
  const factory EscalationViewState.loading() = EscalationViewLoading;

  const factory EscalationViewState.open({
    required List<AgentChannel> channels,
  }) = EscalationViewOpen;

  /// A module agent declined to verify (FR-013).
  const factory EscalationViewState.declined() = EscalationViewDeclined;

  /// The 24-hour window passed (FR-022).
  const factory EscalationViewState.expired() = EscalationViewExpired;

  /// The case could not be opened.
  const factory EscalationViewState.unavailable() = EscalationViewUnavailable;
}

/// Where the screen goes next, once.
enum EscalationNavigationTarget {
  credentialActivated,
  documentCapture,
  livenessCapture,
}

/// Screen 10's ViewModel (010-escalar-agente).
///
/// It opens or resumes a backend escalation and checks its status. Every
/// outcome comes from `EscalationRepository.getStatus()`, and an approval
/// reaches 008 **only** through `CredentialIssuanceRepository`: the hand-off
/// is set in exactly one place, the `IssuanceActivated` branch (FR-011). No
/// `material.dart` import (Principle VIII).
class EscalationViewModel extends ChangeNotifier {
  EscalationViewModel({
    required EscalationRepository escalationRepository,
    required CredentialIssuanceRepository issuanceRepository,
    required ActivatedCredentialHandoff handoff,
    required EnrollmentSessionController enrollmentSessionController,
    required CaptureAttemptCounterRepository attemptCounterRepository,
    required AnalyticsEmitter analyticsEmitter,
    required Clock clock,
    @visibleForTesting Duration pollInterval = escalationPollInterval,
  }) : _escalationRepository = escalationRepository,
       _issuanceRepository = issuanceRepository,
       _handoff = handoff,
       _enrollmentSessionController = enrollmentSessionController,
       _attemptCounterRepository = attemptCounterRepository,
       _analyticsEmitter = analyticsEmitter,
       _clock = clock,
       _pollInterval = pollInterval,
       _openedAt = clock.now() {
    unawaited(_start());
  }

  final EscalationRepository _escalationRepository;
  final CredentialIssuanceRepository _issuanceRepository;
  final ActivatedCredentialHandoff _handoff;
  final EnrollmentSessionController _enrollmentSessionController;
  final CaptureAttemptCounterRepository _attemptCounterRepository;
  final AnalyticsEmitter _analyticsEmitter;
  final Clock _clock;
  final Duration _pollInterval;
  final DateTime _openedAt;

  EscalationViewState _state = const EscalationViewState.loading();
  EscalationViewState get state => _state;

  EscalationArrival _arrival = EscalationArrival.byChoice;

  /// Derived from the attempt counters (research.md §2).
  EscalationArrival get arrival => _arrival;

  AgentChannelKind? _selected;
  AgentChannelKind? get selectedChannel => _selected;

  EscalationNavigationTarget? _pendingNavigation;
  EscalationNavigationTarget? get pendingNavigation => _pendingNavigation;

  void consumeNavigation() {
    _pendingNavigation = null;
  }

  Timer? _pollTimer;
  bool _polling = false;
  bool _issuing = false;
  bool _settled = false;
  bool _shownEmitted = false;
  bool _outcomeEmitted = false;
  (bool, bool)? _lastOffered;
  bool _disposed = false;

  Future<void> _start() async {
    _arrival = await _deriveArrival();
    await _open();
  }

  Future<EscalationArrival> _deriveArrival() async {
    for (final scope in AttemptCounterScope.values) {
      final count = (await _attemptCounterRepository.read(scope))
          .valueOrNull
          ?.count;
      if ((count ?? 0) >= captureAttemptLimit) {
        return EscalationArrival.afterLimit;
      }
    }
    return EscalationArrival.byChoice;
  }

  Future<void> _open() async {
    final result = await _escalationRepository.openOrResume(arrival: _arrival);
    if (_disposed) return;
    if (result.isError) {
      _setState(const EscalationViewState.unavailable());
      return;
    }
    _settled = false;
    await _poll();
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => unawaited(_poll()));
  }

  /// "Abrir nueva solicitud" (after expiry), or "Reintentar" (unavailable).
  Future<void> reopen() async {
    _outcomeEmitted = false;
    _shownEmitted = false;
    _setState(const EscalationViewState.loading());
    await _open();
  }

  Future<void> _poll() async {
    if (_settled || _polling || _disposed) return;
    _polling = true;
    final result = await _escalationRepository.getStatus();
    _polling = false;
    if (_settled || _disposed) return;

    switch (result) {
      case Ok(value: EscalationOpen(:final channels)):
        _onOpen(channels);
      case Ok(value: EscalationResolved(:final outcome)):
        await _onOutcome(outcome);
      case Ok(value: EscalationExpired()):
        _settle();
        _emitOutcome(EscalationOutcomeKind.expired);
        _setState(const EscalationViewState.expired());
      case Error():
        // A failed read is never an outcome; the next tick tries again.
        if (_state is EscalationViewLoading) {
          _setState(const EscalationViewState.unavailable());
        }
    }
  }

  void _onOpen(List<AgentChannel> channels) {
    if (!_shownEmitted) {
      _shownEmitted = true;
      _analyticsEmitter.escalationShown(arrival: _arrival);
    }
    final offered = (
      _isAvailable(channels, AgentChannelKind.module),
      _isAvailable(channels, AgentChannelKind.chat),
    );
    if (offered != _lastOffered) {
      _lastOffered = offered;
      _analyticsEmitter.escalationChannelsOffered(
        moduleAvailable: offered.$1,
        chatAvailable: offered.$2,
      );
    }
    // Research.md §3: keep the selection valid; module first, then chat.
    if (_selected == null || !_isAvailable(channels, _selected!)) {
      _selected = _isAvailable(channels, AgentChannelKind.module)
          ? AgentChannelKind.module
          : _isAvailable(channels, AgentChannelKind.chat)
          ? AgentChannelKind.chat
          : null;
    }
    _setState(EscalationViewState.open(channels: channels));
  }

  static bool _isAvailable(
    List<AgentChannel> channels,
    AgentChannelKind kind,
  ) => channels.any((c) => c.kind == kind && c.available);

  Future<void> _onOutcome(EscalationOutcome outcome) async {
    switch (outcome) {
      case EscalationCredentialIssued():
        await _collectCredential();
      case EscalationDeclined():
        _settle();
        _emitOutcome(EscalationOutcomeKind.declined);
        _setState(const EscalationViewState.declined());
      case EscalationAttemptsReset(:final scope):
        _settle();
        // Mirrors the backend's agent reset until FR-006's backend counter
        // replaces the local one (research.md §5).
        final _ = await _attemptCounterRepository.reset(scope);
        _emitOutcome(EscalationOutcomeKind.attemptsReset);
        _navigateTo(switch (scope) {
          AttemptCounterScope.documentCapture =>
            EscalationNavigationTarget.documentCapture,
          AttemptCounterScope.selfieLiveness =>
            EscalationNavigationTarget.livenessCapture,
        });
    }
  }

  /// FR-011: an approval carries no credential. The credential comes only
  /// from the issuance port; anything but `activated` means "not yet", and
  /// the escalation keeps being checked.
  Future<void> _collectCredential() async {
    if (_issuing) return;
    _issuing = true;
    final result = await _issuanceRepository.requestIssuance();
    _issuing = false;
    if (_settled || _disposed) return;
    if (result case Ok(value: IssuanceActivated(:final credential))) {
      _settle();
      _handoff.set(credential);
      _enrollmentSessionController.clear();
      _emitOutcome(EscalationOutcomeKind.credentialIssued);
      _navigateTo(EscalationNavigationTarget.credentialActivated);
    }
  }

  /// Selects [kind] if it is available (FR-005).
  void select(AgentChannelKind kind) {
    final state = _state;
    if (state is! EscalationViewOpen || !_isAvailable(state.channels, kind)) {
      return;
    }
    if (_selected == kind) return;
    _selected = kind;
    _analyticsEmitter.escalationChannelSelected(channel: kind);
    _notify();
  }

  /// The primary action. Returns the channel it applies to, or `null` when
  /// no available channel is selected (FR-020).
  AgentChannelKind? onPrimaryAction() {
    final selected = _selected;
    if (selected == null || _state is! EscalationViewOpen) return null;
    _analyticsEmitter.escalationHandoffStarted(channel: selected);
    return selected;
  }

  void _settle() {
    _settled = true;
    _pollTimer?.cancel();
  }

  void _emitOutcome(EscalationOutcomeKind kind) {
    if (_outcomeEmitted) return;
    _outcomeEmitted = true;
    _analyticsEmitter.escalationOutcome(
      kind: kind,
      elapsedSeconds: _clock.now().difference(_openedAt).inSeconds,
    );
  }

  void _navigateTo(EscalationNavigationTarget target) {
    _pendingNavigation = target;
    _notify();
  }

  void _setState(EscalationViewState next) {
    _state = next;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }
}
