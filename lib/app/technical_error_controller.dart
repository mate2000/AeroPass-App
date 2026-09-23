import 'package:flutter/foundation.dart';

import '../domain/entities/service_failure.dart';

/// 011-error-tecnico FR-008 (Clarifications): how long "Reintentar" is held
/// on each arrival at screen 11 in one app run. The first retry is free;
/// the last step repeats.
const technicalErrorRetryHolds = [
  Duration.zero,
  Duration(seconds: 15),
  Duration(seconds: 30),
  Duration(seconds: 60),
];

/// Hands a verification failure from 007 to screen 11, and paces retries
/// across screen 11's visits (011-error-tecnico, data-model.md).
///
/// In memory only (Principle I): the record and the pacing die with the
/// process, which is exactly when the pacing should reset.
class TechnicalErrorController extends ChangeNotifier {
  ServiceFailure? _current;
  bool _reported = true;
  int _arrivals = 0;
  DateTime? _firstFailureAt;

  /// The failure screen 11 is showing, if 007 recorded one.
  ServiceFailure? get current => _current;

  /// Screen 11 visits since the last resolution.
  int get arrivals => _arrivals;

  /// Called by 007 immediately before it opens screen 11.
  void record(ServiceFailure failure) {
    _current = failure;
    _reported = false;
    _firstFailureAt ??= failure.occurredAt;
    notifyListeners();
  }

  /// True exactly once per recorded `service` failure: the one moment the
  /// operational alert is sent (FR-006).
  bool takeReportable() {
    final failure = _current;
    if (_reported || failure == null) return false;
    _reported = true;
    return failure.failureClass == ServiceFailureClass.service;
  }

  /// Counts one arrival at screen 11 and returns how long its retry is held.
  Duration registerArrival() {
    final index = _arrivals.clamp(0, technicalErrorRetryHolds.length - 1);
    _arrivals++;
    return technicalErrorRetryHolds[index];
  }

  /// Called by 007 when a credential activates. Returns the time since the
  /// first failure of this run, or null if there was none, and starts the
  /// pacing over.
  Duration? resolve(DateTime now) {
    final since = _firstFailureAt;
    _current = null;
    _reported = true;
    _arrivals = 0;
    _firstFailureAt = null;
    notifyListeners();
    return since == null ? null : now.difference(since);
  }
}
