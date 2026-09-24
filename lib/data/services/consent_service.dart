import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/consent_record.dart';
import '../../domain/entities/enrollment_attempt_id.dart';
import '../../domain/entities/processing_scope.dart';

/// The secure storage holding the local `ConsentRecord` (002, Principle I's
/// allowlist). 015 DEC-02: consent is recorded locally only. There is no
/// consent endpoint, so the network calls this class once made are gone
/// (`LocalConsentRepository`).
///
/// Holds no state itself and exposes only Futures (Principle VIII). A
/// storage failure is left to throw, and the repository maps it.
class ConsentService {
  ConsentService({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;

  static const String textVersionIdKey = 'aeropass.consent.text_version_id';
  static const String enrollmentAttemptIdKey =
      'aeropass.consent.enrollment_attempt_id';
  static const String scopeKey = 'aeropass.consent.scope';
  static const String confirmedAtKey = 'aeropass.consent.confirmed_at';
  static const String statusKey = 'aeropass.consent.status';
  static const String withdrawalRequestedAtKey =
      'aeropass.consent.withdrawal_requested_at';

  /// Writes the local `ConsentRecord` copy as individual secure-storage
  /// entries (mirroring `CredentialService`'s pattern), rather than a
  /// single JSON blob — keeps this service, not a domain entity, owning
  /// (de)serialization.
  Future<void> writeLocalRecord(ConsentRecord record) async {
    await _secureStorage.write(
      key: textVersionIdKey,
      value: record.textVersionId,
    );
    await _secureStorage.write(
      key: enrollmentAttemptIdKey,
      value: record.enrollmentAttemptId.value,
    );
    await _secureStorage.write(key: scopeKey, value: record.scope.name);
    await _secureStorage.write(
      key: confirmedAtKey,
      value: record.confirmedAt.toIso8601String(),
    );
    await _secureStorage.write(key: statusKey, value: record.status.name);
    final withdrawalRequestedAt = record.withdrawalRequestedAt;
    if (withdrawalRequestedAt != null) {
      await _secureStorage.write(
        key: withdrawalRequestedAtKey,
        value: withdrawalRequestedAt.toIso8601String(),
      );
    } else {
      await _secureStorage.delete(key: withdrawalRequestedAtKey);
    }
  }

  /// Reads the local `ConsentRecord` copy, or `null` if none has ever been
  /// written on this device.
  Future<ConsentRecord?> readLocalRecord() async {
    final textVersionId = await _secureStorage.read(key: textVersionIdKey);
    final enrollmentAttemptIdRaw = await _secureStorage.read(
      key: enrollmentAttemptIdKey,
    );
    final scopeRaw = await _secureStorage.read(key: scopeKey);
    final confirmedAtRaw = await _secureStorage.read(key: confirmedAtKey);
    final statusRaw = await _secureStorage.read(key: statusKey);
    if (textVersionId == null ||
        enrollmentAttemptIdRaw == null ||
        scopeRaw == null ||
        confirmedAtRaw == null ||
        statusRaw == null) {
      return null;
    }
    final withdrawalRequestedAtRaw = await _secureStorage.read(
      key: withdrawalRequestedAtKey,
    );
    return ConsentRecord(
      textVersionId: textVersionId,
      enrollmentAttemptId: EnrollmentAttemptId(enrollmentAttemptIdRaw),
      scope: ProcessingScope.values.byName(scopeRaw),
      confirmedAt: DateTime.parse(confirmedAtRaw),
      status: ConsentRecordStatus.values.byName(statusRaw),
      withdrawalRequestedAt: withdrawalRequestedAtRaw == null
          ? null
          : DateTime.parse(withdrawalRequestedAtRaw),
    );
  }
}
