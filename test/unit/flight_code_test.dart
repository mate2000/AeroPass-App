// 015 T075 (FR-010, V-06): the backend's flight-code rule, applied on the
// device, so a malformed code is marked with no request.
import 'package:aeropass_app/domain/entities/flight_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('valid codes, normalized as the backend normalizes them', () {
    for (final (input, expected) in [
      ('AV9201', 'AV9201'),
      ('av 9201', 'AV9201'),
      ('  la123a ', 'LA123A'),
      ('4C1', '4C1'),
    ]) {
      expect(
        FlightCode.parse(input).valueOrNull?.value,
        expected,
        reason: input,
      );
    }
  });

  test('invalid codes are refused', () {
    for (final input in ['', 'AV', 'AV92011', 'AV9201XY', 'A-9201', 'ÁV9201']) {
      expect(FlightCode.parse(input).isError, isTrue, reason: input);
    }
  });
}
