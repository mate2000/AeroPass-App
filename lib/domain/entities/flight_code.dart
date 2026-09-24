import '../../core/result.dart';

/// A flight code as the backend accepts it (015 DEC-03, FR-010, V-06):
/// `^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$` after trimming and upper-casing, as
/// `normalizar_codigo_vuelo` in `domain/flight.py` does.
///
/// Internal spaces are removed too, so a passenger's `av 9201` is accepted
/// as `AV9201`. Held in memory only: it is never persisted (Q3 of clarify).
extension type const FlightCode._(String value) {
  static final _pattern = RegExp(r'^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$');

  static Result<FlightCode> parse(String input) {
    final normalized = input.replaceAll(RegExp(r'\s'), '').toUpperCase();
    if (!_pattern.hasMatch(normalized)) {
      return Result.error(FormatException('invalid flight code'));
    }
    return Result.ok(FlightCode._(normalized));
  }
}
