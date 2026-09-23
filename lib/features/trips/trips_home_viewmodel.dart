import 'dart:async' show Timer, unawaited;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;

import '../../core/clock.dart';
import '../../core/result.dart';
import '../../domain/entities/credential_summary.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/analytics_emitter.dart';
import '../../domain/repositories/credential_summary_repository.dart';
import '../../domain/repositories/pass_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import 'trip_time_format.dart';

/// 012-mis-viajes FR-005 (Clarifications): how often the screen re-reads
/// while visible.
const tripsHomeRefreshInterval = Duration(seconds: 60);

/// How often the trip action is re-evaluated, so the 24-hour window opens
/// on time without a network read.
const tripsHomeActionTick = Duration(minutes: 1);

/// Why "Iniciar viaje" is not offered, in precedence order
/// (contracts/trips-home-ui.md).
enum TripActionReason {
  unconfirmed,
  expired,
  revoked,
  suspended,
  cancelled,
  departed,
  notYetOpen,
}

/// What the trip card's action slot shows.
sealed class TripAction {
  const TripAction();
}

/// "Iniciar viaje" is enabled.
final class TripActionStart extends TripAction {
  const TripActionStart();
}

/// 014-qr-pase FR-022: a pass is already issued and valid for this trip, so
/// "Ver pase" opens it directly — no window, confirmation or network needed;
/// the pass screen checks its own state.
final class TripActionViewPass extends TripAction {
  const TripActionViewPass();
}

/// The button is replaced by a stated reason. [availableFrom] is set for
/// [TripActionReason.notYetOpen].
final class TripActionUnavailable extends TripAction {
  const TripActionUnavailable(this.reason, {this.availableFrom});

  final TripActionReason reason;
  final DateTime? availableFrom;
}

/// Where the home screen goes next: a one-shot target the view acts on.
enum TripsHomeTarget { startTrip, viewPass, welcome }

/// Mis viajes' ViewModel (012-mis-viajes, data-model.md).
///
/// It reads the credential summary and the trips on open, on return to the
/// foreground and every 60 s. "ACTIVA" follows the summary's `showsActive`
/// only. "Iniciar viaje" needs a confirmed active credential, a flight that
/// is not cancelled, and the 24-hour window; otherwise the reason is stated
/// (FR-008, FR-009). It never produces a pass: starting leads to 013.
///
/// No `package:flutter/material.dart` import (Principle VIII).
class TripsHomeViewModel extends ChangeNotifier {
  TripsHomeViewModel({
    required CredentialSummaryRepository summaryRepository,
    required TripRepository tripRepository,
    required AnalyticsEmitter analyticsEmitter,
    required Clock clock,
    PassRepository? passRepository,
    @visibleForTesting Duration refreshInterval = tripsHomeRefreshInterval,
    @visibleForTesting Duration actionTick = tripsHomeActionTick,
    @visibleForTesting Duration Function()? deviceOffset,
    @visibleForTesting bool observeLifecycle = true,
  }) : _summaryRepository = summaryRepository,
       _tripRepository = tripRepository,
       _analyticsEmitter = analyticsEmitter,
       _clock = clock,
       _passRepository = passRepository,
       _deviceOffset = deviceOffset ?? (() => DateTime.now().timeZoneOffset) {
    _trips = tripRepository.lastKnown;
    _refreshTimer = Timer.periodic(
      refreshInterval,
      (_) => unawaited(refresh()),
    );
    _tickTimer = Timer.periodic(actionTick, (_) => _notify());
    if (observeLifecycle) {
      _lifecycleListener = AppLifecycleListener(onResume: onAppResumed);
    }
    unawaited(refresh());
  }

  final CredentialSummaryRepository _summaryRepository;
  final TripRepository _tripRepository;
  final AnalyticsEmitter _analyticsEmitter;
  final Clock _clock;
  final PassRepository? _passRepository;
  final Duration Function() _deviceOffset;

  CredentialSummary? _summary;
  TripsSnapshot? _trips;
  bool _tripsStale = false;
  bool _loaded = false;
  bool _refreshing = false;
  bool _disposed = false;
  bool _homeShownEmitted = false;
  bool _tripDisplayedEmitted = false;
  bool _emptyEmitted = false;
  bool _historyEmitted = false;
  TripsHomeTarget? _pendingNavigation;
  Timer? _refreshTimer;
  Timer? _tickTimer;
  AppLifecycleListener? _lifecycleListener;

  // --- What the screen shows ------------------------------------------------

  /// Null until the first read, or when nothing at all is known.
  CredentialSummary? get summary => _summary;

  /// The latest good snapshot this session; null when none has been read.
  TripsSnapshot? get trips => _trips;

  /// True once the first read has finished.
  bool get loaded => _loaded;

  /// The trips shown were not refreshed by the latest read (FR-005).
  bool get tripsStale => _tripsStale && _trips != null;

  /// There has been no good snapshot this session and the read failed.
  bool get tripsUnavailable => _loaded && _trips == null;

  /// Minutes since the shown trips were read, for the stale marker.
  int get minutesSinceTripsFetched {
    final fetched = _trips?.fetchedAt;
    if (fetched == null) return 0;
    return _clock.now().difference(fetched).inMinutes;
  }

  Greeting get greeting =>
      greetingFor(_clock.now().toUtc().add(_deviceOffset()).hour);

  /// The first word of the holder's name, for the greeting.
  String? get firstName {
    final name = _summary?.holderName?.trim();
    if (name == null || name.isEmpty) return null;
    return name.split(RegExp(r'\s+')).first;
  }

  Trip? get nextTrip => _trips?.next;

  List<Trip> get history => _trips?.history ?? const [];

  /// The next trip's departure, in its airport's clock (FR-014).
  DepartureDescription? get nextDeparture {
    final trip = nextTrip;
    if (trip == null) return null;
    return describeDeparture(
      trip,
      nowUtc: _clock.now(),
      deviceOffset: _deviceOffset(),
    );
  }

  /// The trip action, by the precedence of contracts/trips-home-ui.md.
  TripAction get action {
    final trip = nextTrip;
    if (trip != null && _passRepository?.activePassFor(trip.id) != null) {
      return const TripActionViewPass();
    }
    final summary = _summary;
    if (summary == null || !summary.confirmed) {
      return const TripActionUnavailable(TripActionReason.unconfirmed);
    }
    switch (summary.state) {
      case CredentialDisplayState.expired:
        return const TripActionUnavailable(TripActionReason.expired);
      case CredentialDisplayState.revoked:
        return const TripActionUnavailable(TripActionReason.revoked);
      case CredentialDisplayState.suspended:
        return const TripActionUnavailable(TripActionReason.suspended);
      case CredentialDisplayState.active:
        break;
    }
    if (trip == null) {
      return const TripActionUnavailable(TripActionReason.departed);
    }
    if (trip.status == TripStatus.cancelled) {
      return const TripActionUnavailable(TripActionReason.cancelled);
    }
    final now = _clock.now();
    if (!now.isBefore(trip.departureUtc) ||
        trip.status == TripStatus.departed) {
      return const TripActionUnavailable(TripActionReason.departed);
    }
    if (now.isBefore(trip.tripWindowOpensAt)) {
      return TripActionUnavailable(
        TripActionReason.notYetOpen,
        availableFrom: trip.tripWindowOpensAt,
      );
    }
    return const TripActionStart();
  }

  TripsHomeTarget? get pendingNavigation => _pendingNavigation;

  void consumeNavigation() => _pendingNavigation = null;

  // --- Actions --------------------------------------------------------------

  /// "Iniciar viaje": only when the action is enabled. Leads to 013; never
  /// produces a pass (FR-009).
  void startTrip() {
    if (action is! TripActionStart || _pendingNavigation != null) return;
    _analyticsEmitter.tripStarted(completedTripsLast90Days: history.length);
    _navigateTo(TripsHomeTarget.startTrip);
  }

  /// "Ver pase": reopens the pass already issued for the next trip (FR-022).
  void viewPass() {
    if (action is! TripActionViewPass || _pendingNavigation != null) return;
    _navigateTo(TripsHomeTarget.viewPass);
  }

  /// Back from the pass or 013: whether a pass exists may have changed.
  void onReturned() => _notify();

  /// "Reintentar" in the unavailable state.
  Future<void> retryTrips() => refresh();

  /// The history section first scrolled into view in this visit.
  void onHistoryVisible() {
    if (_historyEmitted || history.isEmpty) return;
    _historyEmitted = true;
    _analyticsEmitter.tripsHistoryViewed(rowCount: history.length);
  }

  /// Return to the foreground: re-read before presenting as current
  /// (FR-005).
  @visibleForTesting
  void onAppResumed() => unawaited(refresh());

  /// Reads the credential summary and the trips together.
  @visibleForTesting
  Future<void> refresh() async {
    if (_refreshing || _disposed) return;
    _refreshing = true;
    final summaryRead = _summaryRepository.getSummary();
    final tripsRead = _tripRepository.getTrips();
    final summaryResult = await summaryRead;
    final tripsResult = await tripsRead;
    _refreshing = false;
    if (_disposed) return;

    switch (summaryResult) {
      case Ok(:final value):
        _summary = value;
      case Error(error: NoCredentialFailure()):
        _navigateTo(TripsHomeTarget.welcome);
        return;
      case Error():
        // Nothing known at all: the strip stays as it was, unconfirmed.
        final previous = _summary;
        _summary = previous?.copyWith(confirmed: false);
    }

    switch (tripsResult) {
      case Ok(:final value):
        _trips = value;
        _tripsStale = false;
      case Error():
        _trips = _tripRepository.lastKnown ?? _trips;
        _tripsStale = true;
    }
    _loaded = true;
    _emitVisitEvents();
    _notify();
  }

  // --- Internals --------------------------------------------------------------

  void _emitVisitEvents() {
    if (!_homeShownEmitted) {
      _homeShownEmitted = true;
      _analyticsEmitter.tripsHomeShown(
        hasNextTrip: nextTrip != null,
        credentialConfirmed: _summary?.confirmed ?? false,
      );
    }
    final trip = nextTrip;
    if (trip != null && !_tripDisplayedEmitted) {
      _tripDisplayedEmitted = true;
      final now = _clock.now();
      _analyticsEmitter.tripDisplayed(
        status: trip.status,
        live: trip.live,
        withinWindow:
            !now.isBefore(trip.tripWindowOpensAt) &&
            now.isBefore(trip.departureUtc),
      );
    }
    if (trip == null && _trips != null && !_emptyEmitted) {
      _emptyEmitted = true;
      _analyticsEmitter.tripsEmptyShown();
    }
  }

  void _navigateTo(TripsHomeTarget target) {
    _pendingNavigation = target;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    _tickTimer?.cancel();
    _lifecycleListener?.dispose();
    super.dispose();
  }
}
