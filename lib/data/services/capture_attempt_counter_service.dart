import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/capture_attempt_counter.dart';

/// Wraps the single external data source
/// `CaptureAttemptCounterRepositoryImpl` needs (Constitution Principle
/// VIII): `flutter_secure_storage`, reusing the exact same instance already
/// constructed for the credential/consent records (research.md §3 — no new
/// storage dependency for a two-field counter).
///
/// Constructor-injected (Principle IX). Holds no state itself and exposes
/// only Futures (Principle VIII).
class CaptureAttemptCounterService {
  CaptureAttemptCounterService({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  static const String countKey = 'aeropass.capture.document.attempt_count';
  static const String lastResetAtKey =
      'aeropass.capture.document.last_reset_at';

  /// Reads the persisted counter, or `null` if nothing has ever been
  /// written on this device (first-ever attempt).
  Future<CaptureAttemptCounter?> read() async {
    final countRaw = await _secureStorage.read(key: countKey);
    final lastResetAtRaw = await _secureStorage.read(key: lastResetAtKey);
    if (countRaw == null || lastResetAtRaw == null) {
      return null;
    }
    return CaptureAttemptCounter(
      count: int.parse(countRaw),
      lastResetAt: DateTime.parse(lastResetAtRaw),
    );
  }

  Future<void> write(CaptureAttemptCounter counter) async {
    await _secureStorage.write(key: countKey, value: counter.count.toString());
    await _secureStorage.write(
      key: lastResetAtKey,
      value: counter.lastResetAt.toIso8601String(),
    );
  }
}
