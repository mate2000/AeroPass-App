import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/capture_attempt_counter.dart';

/// Wraps the single external data source
/// `CaptureAttemptCounterRepositoryImpl` needs (Constitution Principle
/// VIII): `flutter_secure_storage`, reusing the exact same instance already
/// constructed for the credential/consent records (research.md §3 — no new
/// storage dependency for a two-field counter).
///
/// Constructor-injected (Principle IX). Holds no state itself and exposes
/// only Futures (Principle VIII). Storage keys are derived per
/// [AttemptCounterScope] (006-selfie-liveness, research.md §3) — the
/// `documentCapture` keys are kept byte-identical to what 003-escanear-documento
/// originally wrote, so an in-progress counter on an existing install isn't
/// silently reset by this generalization.
class CaptureAttemptCounterService {
  CaptureAttemptCounterService({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  String _countKey(AttemptCounterScope scope) =>
      'aeropass.capture.${_scopeSegment(scope)}.attempt_count';

  String _lastResetAtKey(AttemptCounterScope scope) =>
      'aeropass.capture.${_scopeSegment(scope)}.last_reset_at';

  String _scopeSegment(AttemptCounterScope scope) => switch (scope) {
    AttemptCounterScope.documentCapture => 'document',
    AttemptCounterScope.selfieLiveness => 'selfie_liveness',
  };

  /// Reads the persisted counter for [scope], or `null` if nothing has ever
  /// been written for it on this device (first-ever attempt).
  Future<CaptureAttemptCounter?> read(AttemptCounterScope scope) async {
    final countRaw = await _secureStorage.read(key: _countKey(scope));
    final lastResetAtRaw = await _secureStorage.read(
      key: _lastResetAtKey(scope),
    );
    if (countRaw == null || lastResetAtRaw == null) {
      return null;
    }
    return CaptureAttemptCounter(
      count: int.parse(countRaw),
      lastResetAt: DateTime.parse(lastResetAtRaw),
    );
  }

  Future<void> write(
    AttemptCounterScope scope,
    CaptureAttemptCounter counter,
  ) async {
    await _secureStorage.write(
      key: _countKey(scope),
      value: counter.count.toString(),
    );
    await _secureStorage.write(
      key: _lastResetAtKey(scope),
      value: counter.lastResetAt.toIso8601String(),
    );
  }
}
