/// The backend's registration rules, applied on the device first (015
/// FR-022). They mirror `DatosDocumento.validar` in `domain/passenger.py`
/// (V-04, V-05), so a bad field is marked with no round trip. The backend
/// remains the authority: its `DATOS_INVALIDOS` still marks fields (FR-016).
abstract final class RegistrationRules {
  static final _whitespace = RegExp(r'\s+');
  // Exactly `_SEPARADORES` in `domain/passenger.py`: whitespace, dot and
  // hyphen. Stripping more would pass a number here that the backend
  // rejects.
  static final _separators = RegExp(r'[\s.\-]');
  static final _number = RegExp(r'^[A-Z0-9]{4,20}$');
  static final _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Collapses runs of whitespace, as `" ".join(nombre.split())` does.
  static String normalizeName(String name) =>
      name.trim().split(_whitespace).where((part) => part.isNotEmpty).join(' ');

  static bool validName(String name) {
    final length = normalizeName(name).length;
    return length >= 2 && length <= 200;
  }

  /// Removes separators and upper-cases, as `normalizar_numero` does.
  static String normalizeNumber(String number) =>
      number.replaceAll(_separators, '').toUpperCase();

  static bool validNumber(String number) =>
      _number.hasMatch(normalizeNumber(number));

  /// `YYYY-MM-DD` only. Any other form is rejected rather than guessed.
  static DateTime? parseExpiry(String value) {
    final trimmed = value.trim();
    if (!_isoDate.hasMatch(trimmed)) return null;
    final parsed = DateTime.tryParse(trimmed);
    return parsed == null
        ? null
        : DateTime(parsed.year, parsed.month, parsed.day);
  }

  /// Today or later, comparing calendar days in the device's zone. The
  /// backend decides with its own clock (`DOCUMENTO_VENCIDO`).
  static bool validExpiry(DateTime expiry, {required DateTime today}) {
    final day = DateTime(expiry.year, expiry.month, expiry.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return !day.isBefore(todayDay);
  }

  static String wireDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
