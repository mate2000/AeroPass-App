// 015 T027 (FR-022, V-04, V-05): the device applies the backend's own
// registration rules (`domain/passenger.py`) before sending, so a bad field
// is marked with no round trip. The backend stays the authority.
import 'package:aeropass_app/domain/entities/registration_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('name', () {
    test('2–200 characters after collapsing whitespace', () {
      expect(RegistrationRules.validName('Ana Prueba'), isTrue);
      expect(RegistrationRules.validName('  Al  '), isTrue);
      expect(RegistrationRules.validName('A'), isFalse);
      expect(RegistrationRules.validName('   '), isFalse);
      expect(RegistrationRules.validName('x' * 200), isTrue);
      expect(RegistrationRules.validName('x' * 201), isFalse);
    });

    test('is normalized as the backend normalizes it', () {
      expect(
        RegistrationRules.normalizeName('  Ana   María\tPrueba '),
        'Ana María Prueba',
      );
    });
  });

  group('number', () {
    test('separators are removed and letters upper-cased', () {
      expect(RegistrationRules.normalizeNumber('1.020.304-050'), '1020304050');
      expect(RegistrationRules.normalizeNumber('ab 12 34'), 'AB1234');
    });

    test('4–20 of [A-Z0-9] after normalizing', () {
      expect(RegistrationRules.validNumber('1020304050'), isTrue);
      expect(RegistrationRules.validNumber('AB12'), isTrue);
      expect(RegistrationRules.validNumber('12'), isFalse);
      expect(RegistrationRules.validNumber('1' * 21), isFalse);
      expect(RegistrationRules.validNumber('12#45'), isFalse);
      // Only whitespace, dot and hyphen are separators, as in the backend.
      expect(RegistrationRules.validNumber('1020/304050'), isFalse);
      expect(RegistrationRules.validNumber(''), isFalse);
    });
  });

  group('expiry', () {
    final today = DateTime(2026, 9, 23, 18);

    test('today or later is valid; the time of day does not matter', () {
      expect(
        RegistrationRules.validExpiry(DateTime(2026, 9, 23), today: today),
        isTrue,
      );
      expect(
        RegistrationRules.validExpiry(DateTime(2030, 1, 31), today: today),
        isTrue,
      );
      expect(
        RegistrationRules.validExpiry(DateTime(2026, 9, 22), today: today),
        isFalse,
      );
    });

    test('an ISO date string parses; anything else is invalid', () {
      expect(
        RegistrationRules.parseExpiry('2030-01-31'),
        DateTime(2030, 1, 31),
      );
      expect(RegistrationRules.parseExpiry('31/01/2030'), isNull);
      expect(RegistrationRules.parseExpiry(''), isNull);
    });

    test('the wire form is YYYY-MM-DD', () {
      expect(RegistrationRules.wireDate(DateTime(2030, 1, 5)), '2030-01-05');
    });
  });
}
