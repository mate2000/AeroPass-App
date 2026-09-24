import 'package:flutter/foundation.dart';

import '../domain/entities/flight_code.dart';

/// Carries the passenger's flight code from Mis viajes to the pass (015
/// DEC-03, T078). It is in memory only (Q3 of clarify) and kept out of the
/// route, so it never appears in navigation breadcrumbs.
class FlightCodeHandoff extends ChangeNotifier {
  FlightCode? _code;
  FlightCode? get code => _code;

  void set(FlightCode code) {
    _code = code;
    notifyListeners();
  }

  void clear() {
    _code = null;
    notifyListeners();
  }
}
