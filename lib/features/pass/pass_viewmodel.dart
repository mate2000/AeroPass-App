import 'dart:async' show Timer, unawaited;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;

import '../../app/clock_trust_monitor.dart';
import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/pass.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/transport_failure.dart';
import '../../domain/repositories/analytics_emitter.dart';
import '../../domain/repositories/device_posture_checker.dart';
import '../../domain/repositories/pass_code_source.dart';
import '../../domain/repositories/pass_display_guard.dart';
import '../../domain/repositories/pass_repository.dart';
import '../trips/trip_time_format.dart';

/// How often the countdown is recomputed from the clock.
const passTick = Duration(seconds: 1);

/// What the pass screen shows (data-model.md).
sealed class PassViewState {
  const PassViewState();
}

final class PassLoading extends PassViewState {
  const PassLoading();
}

/// A usable code, from the backend (phase A) — never from device state
/// alone (FR-002).
final class PassShowing extends PassViewState {
  const PassShowing(this.pass, this.code);

  final Pass pass;
  final PassCode code;
}

/// Boarding confirmed: no code is shown any more.
final class PassBoardedView extends PassViewState {
  const PassBoardedView();
}

/// No code, a stated reason, and a way forward (contracts/pass-ui.md).
final class PassUnavailable extends PassViewState {
  const PassUnavailable(this.reason);

  final PassUnavailableReason reason;
}

/// Screen 14's ViewModel (014-qr-pase, data-model.md).
///
/// The backend is the only authority. The screen shows a code only while
/// the backend says the pass is active, the clock is trusted, the validity
/// has not passed and the device posture is trusted. Every other state
/// shows no code. Rotation and the countdown are recomputed from the
/// clock every second, so a paused timer can never leave an old code on
/// screen (FR-020). Pass mode — brightness, keep-awake, capture blocking —
/// is on only while a code is shown.
///
/// No `package:flutter/material.dart` import (Principle VIII).
class PassViewModel extends ChangeNotifier {
  PassViewModel({
    required String? tripId,
    required PassRepository passRepository,
    required PassCodeSource codeSource,
    required PassDisplayGuard displayGuard,
    required DevicePostureChecker postureChecker,
    required ClockTrustMonitor clockTrust,
    required AnalyticsEmitter analyticsEmitter,
    required Clock clock,
    VoidCallback? onDevExpire,
    Trip? trip,
    Future<String?> Function()? loadHolderName,
    @visibleForTesting Duration Function()? deviceOffset,
    @visibleForTesting Duration tick = passTick,
    @visibleForTesting Duration statusPollInterval = passStatusPollInterval,
    @visibleForTesting bool observeLifecycle = true,
  }) : _tripId = tripId,
       _passRepository = passRepository,
       _codeSource = codeSource,
       _displayGuard = displayGuard,
       _postureChecker = postureChecker,
       _clockTrust = clockTrust,
       _analyticsEmitter = analyticsEmitter,
       _clock = clock,
       _onDevExpire = onDevExpire,
       _trip = trip,
       _deviceOffset = deviceOffset ?? (() => DateTime.now().timeZoneOffset),
       _openedAt = clock.now() {
    if (loadHolderName != null) unawaited(_loadHolderName(loadHolderName));
    _tickTimer = Timer.periodic(tick, (_) => unawaited(_onTick()));
    _pollTimer = Timer.periodic(
      statusPollInterval,
      (_) => unawaited(pollStatus()),
    );
    if (observeLifecycle) {
      _lifecycle = AppLifecycleListener(
        onPause: onAppPaused,
        onResume: onAppResumed,
      );
    }
    unawaited(start());
  }

  final String? _tripId;
  final Trip? _trip;
  final Duration Function() _deviceOffset;
  String? _holderName;
  final PassRepository _passRepository;
  final PassCodeSource _codeSource;
  final PassDisplayGuard _displayGuard;
  final DevicePostureChecker _postureChecker;
  final ClockTrustMonitor _clockTrust;
  final AnalyticsEmitter _analyticsEmitter;
  final Clock _clock;
  final VoidCallback? _onDevExpire;
  final DateTime _openedAt;

  PassViewState _state = const PassLoading();
  Pass? _pass;
  bool _passModeOn = false;
  bool _paused = false;
  bool _busy = false;
  bool _displayedEmitted = false;
  bool _disposed = false;
  int _rotations = 0;
  Timer? _tickTimer;
  Timer? _pollTimer;
  AppLifecycleListener? _lifecycle;

  PassViewState get state => _state;

  /// The trip the pass is for, for the header (FR-008).
  Trip? get trip => _trip;

  /// The trip's departure in its airport's clock (FR-014), for the header.
  DepartureDescription? get departure {
    final trip = _trip;
    if (trip == null) return null;
    return describeDeparture(
      trip,
      nowUtc: _clock.now(),
      deviceOffset: _deviceOffset(),
    );
  }

  /// The holder's name, for the header; null until known.
  String? get holderName => _holderName;

  /// Counts rotations, so the view announces "Código actualizado" once
  /// per new code.
  int get rotations => _rotations;

  /// Whether the dev "Simular expirado" affordance can act. The view shows
  /// it only when the release-refused flag is on (FR-019).
  bool get canDevExpire => _onDevExpire != null && _state is PassShowing;

  /// 015 FR-012: the shown code is still valid, but its renewal failed and
  /// is being retried.
  bool get renewalPending {
    final state = _state;
    return state is PassShowing && state.code.renewalPending;
  }

  /// Whole seconds until the next code, from the backend-corrected clock.
  int get secondsLeft {
    final state = _state;
    if (state is! PassShowing) return 0;
    final left = state.code.windowEndsAt.difference(_clockTrust.serverNow());
    if (left.isNegative) return 0;
    return (left.inMilliseconds / 1000).ceil();
  }

  /// 0.0–1.0 of the window left, for the progress ring.
  double get windowFractionLeft {
    final state = _state;
    if (state is! PassShowing) return 0;
    final total = state.code.windowEndsAt.difference(state.code.windowStartsAt);
    if (total <= Duration.zero) return 0;
    final left = state.code.windowEndsAt.difference(_clockTrust.serverNow());
    return (left.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  // --- Lifecycle of the pass ------------------------------------------------

  /// Opens the pass: posture first, then the active pass or a new one.
  @visibleForTesting
  Future<void> start() async {
    if (_busy || _disposed) return;
    _busy = true;
    try {
      final posture = await _postureChecker.check();
      if (_disposed) return;
      if (posture is DeviceCompromised) {
        _becomeUnavailable(PassUnavailableReason.compromisedDevice);
        return;
      }
      final tripId = _tripId;
      if (tripId == null) {
        // No started trip is known: there is nothing to issue a pass for.
        _becomeUnavailable(PassUnavailableReason.issuanceFailed);
        return;
      }
      final pass = _passRepository.activePassFor(tripId);
      if (pass != null) {
        _pass = pass;
      } else {
        final issued = await _passRepository.issue(tripId);
        if (_disposed) return;
        switch (issued) {
          case Ok(:final value):
            _pass = value;
          case Error(:final error):
            _becomeUnavailable(_reasonFor(error));
            return;
        }
      }
      await _refreshCode();
    } finally {
      _busy = false;
    }
  }

  /// Reads the backend's word on the pass (every 5 s while shown).
  @visibleForTesting
  Future<void> pollStatus() async {
    final pass = _pass;
    if (pass == null || _disposed || _state is PassBoardedView) return;
    final result = await _passRepository.status(pass.passId);
    if (_disposed) return;
    switch (result) {
      case Ok(value: PassActive(:final pass)):
        for (final checkpoint in pass.validated.difference(
          _pass?.validated ?? const {},
        )) {
          _analyticsEmitter.passValidated(
            checkpoint: checkpoint,
            secondsSinceOpened: _clock.now().difference(_openedAt).inSeconds,
          );
        }
        _pass = pass;
        final state = _state;
        if (state is PassShowing) {
          _state = PassShowing(pass, state.code);
          _notify();
        } else if (state is PassUnavailable &&
            state.reason == PassUnavailableReason.untrustedClock) {
          await _refreshCode();
        }
      case Ok(value: PassBoarded()):
        _analyticsEmitter.passValidated(
          checkpoint: Checkpoint.boarding,
          secondsSinceOpened: _clock.now().difference(_openedAt).inSeconds,
        );
        await _passRepository.forget(pass.passId);
        _pass = null;
        _pollTimer?.cancel();
        _setState(const PassBoardedView());
      case Ok(value: PassExpired()):
        await _passRepository.forget(pass.passId);
        _becomeUnavailable(PassUnavailableReason.expired);
      case Ok(value: PassRevoked()):
        await _passRepository.forget(pass.passId);
        _becomeUnavailable(PassUnavailableReason.revoked);
      case Ok(value: PassFlightChanged(:final cancelled)):
        _becomeUnavailable(
          cancelled
              ? PassUnavailableReason.flightCancelled
              : PassUnavailableReason.flightChanged,
        );
      case Error():
        // Offline or a failed read: the pass stands as it was; its expiry
        // and the clock are still checked every second.
        break;
    }
  }

  // --- Actions --------------------------------------------------------------

  /// "Reintentar": start again from the backend.
  Future<void> retry() async {
    if (_state is! PassUnavailable) return;
    _setState(const PassLoading());
    await pollStatus();
    if (_state is PassLoading) await start();
  }

  /// "Solicitar nuevo código": the backend issues a new pass.
  Future<void> requestNewPass() async {
    final previous = _pass;
    if (previous != null) await _passRepository.forget(previous.passId);
    _pass = null;
    final tripId = _tripId;
    if (tripId == null) return;
    _setState(const PassLoading());
    final issued = await _passRepository.issue(tripId);
    if (_disposed) return;
    _analyticsEmitter.passReissueRequested(succeeded: issued.isOk);
    switch (issued) {
      case Ok(:final value):
        _pass = value;
        _pollTimer ??= Timer.periodic(
          passStatusPollInterval,
          (_) => unawaited(pollStatus()),
        );
        await _refreshCode();
      case Error(:final error):
        _becomeUnavailable(_reasonFor(error));
    }
  }

  void onHelpOpened() => _analyticsEmitter.passHelpOpened();

  /// The flag-gated dev control: asks the fake backend to expire the pass,
  /// then reads its word like any other expiry.
  Future<void> devExpire() async {
    final expire = _onDevExpire;
    if (expire == null) return;
    expire();
    await pollStatus();
  }

  @visibleForTesting
  void onAppPaused() {
    _paused = true;
    unawaited(_exitPassMode());
  }

  @visibleForTesting
  void onAppResumed() {
    _paused = false;
    // Never show the code from before the pause: recompute first.
    unawaited(_refreshCode());
  }

  // --- Internals --------------------------------------------------------------

  Future<void> _loadHolderName(Future<String?> Function() load) async {
    final name = await load();
    if (_disposed || name == null) return;
    _holderName = name;
    _notify();
  }

  /// A tick still running (a renewal on a slow network) makes later ticks
  /// skip, so one renewal is never sent twice (015: issuance is rate-limited).
  bool _tickInFlight = false;

  Future<void> _onTick() async {
    if (_disposed || _paused || _tickInFlight) return;
    _tickInFlight = true;
    try {
      await _tickOnce();
    } finally {
      _tickInFlight = false;
    }
  }

  Future<void> _tickOnce() async {
    final state = _state;
    if (state is! PassShowing) return;
    if (!_clockTrust.isTrusted) {
      _becomeUnavailable(PassUnavailableReason.untrustedClock);
      return;
    }
    if (!_clockTrust.serverNow().isBefore(state.pass.validUntil)) {
      await _passRepository.forget(state.pass.passId);
      _becomeUnavailable(PassUnavailableReason.expired);
      return;
    }
    if (!_clockTrust.serverNow().isBefore(state.code.windowEndsAt)) {
      await _refreshCode(rotation: true);
      return;
    }
    _notify();
  }

  /// Computes the current window's code, or the reason there is none.
  Future<void> _refreshCode({bool rotation = false}) async {
    final pass = _pass;
    if (pass == null || _disposed) return;
    if (!_clockTrust.isTrusted) {
      _becomeUnavailable(PassUnavailableReason.untrustedClock);
      return;
    }
    final now = _clockTrust.serverNow();
    if (!now.isBefore(pass.validUntil)) {
      await _passRepository.forget(pass.passId);
      _becomeUnavailable(PassUnavailableReason.expired);
      return;
    }
    final result = await _codeSource.codeAt(pass, now);
    if (_disposed) return;
    switch (result) {
      case Ok(:final value):
        // 015 research.md §10: a renewal replaces the pass (new id, new
        // expiry), so the repository's current pass is the one to hold.
        final current =
            _passRepository.activePassFor(pass.tripId) ?? _pass ?? pass;
        _pass = current;
        final previous = _state;
        final changed =
            previous is! PassShowing || previous.code.payload != value.payload;
        if (rotation && changed) {
          _rotations++;
          _analyticsEmitter.passRotated(checkpoint: current.nextCheckpoint);
        }
        _setState(PassShowing(current, value));
        if (!_displayedEmitted) {
          _displayedEmitted = true;
          _analyticsEmitter.passDisplayed(
            checkpoint: current.nextCheckpoint,
            offlineCapable: false,
          );
        }
      case Error(:final error):
        _becomeUnavailable(_reasonFor(error));
    }
  }

  /// 015 FR-015: an expired document and an inactive identity are told
  /// apart, and neither is a generic failure.
  static PassUnavailableReason _reasonFor(Object error) => switch (error) {
    ConnectivityFailure() => PassUnavailableReason.offlineWithoutPass,
    PassIssueRefused(refusal: PassIssueRefusal.documentExpired) =>
      PassUnavailableReason.documentExpired,
    PassIssueRefused(refusal: PassIssueRefusal.identityNotActive) =>
      PassUnavailableReason.identityNotActive,
    _ => PassUnavailableReason.issuanceFailed,
  };

  void _becomeUnavailable(PassUnavailableReason reason) {
    final current = _state;
    if (current is PassUnavailable && current.reason == reason) return;
    _analyticsEmitter.passUnavailable(reason: reason);
    _setState(PassUnavailable(reason));
  }

  void _setState(PassViewState next) {
    _state = next;
    if (next is PassShowing && !_paused) {
      unawaited(_enterPassMode());
    } else if (next is! PassShowing) {
      unawaited(_exitPassMode());
    }
    _notify();
  }

  Future<void> _enterPassMode() async {
    if (_passModeOn || _disposed) return;
    _passModeOn = true;
    await _displayGuard.enterPassMode();
  }

  Future<void> _exitPassMode() async {
    if (!_passModeOn) return;
    _passModeOn = false;
    await _displayGuard.exitPassMode();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _tickTimer?.cancel();
    _pollTimer?.cancel();
    _lifecycle?.dispose();
    if (_passModeOn) {
      _passModeOn = false;
      unawaited(_displayGuard.exitPassMode());
    }
    super.dispose();
  }
}
