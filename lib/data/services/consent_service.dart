import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/consent_record.dart';
import '../../domain/entities/enrollment_attempt_id.dart';
import '../../domain/entities/processing_scope.dart';
import '../models/consent_text_version_response.dart';

/// Wraps the pair of external data sources `ConsentRepositoryImpl` needs
/// (Constitution Principle VIII: "Service — one per external data source,
/// stateless"): a certificate-pinned `dio` client for the current-text,
/// consent-submission, and withdrawal calls, and `flutter_secure_storage`
/// for the local `ConsentRecord` copy.
///
/// Both dependencies are constructor-injected (Principle IX). Holds no
/// state itself and exposes only Futures (Principle VIII); any transport or
/// storage failure is left to throw — mapping that into `Result.error` is
/// `ConsentRepositoryImpl`'s job, at the service boundary (Principle IX).
class ConsentService {
  ConsentService({required Dio dio, required FlutterSecureStorage secureStorage})
    : _dio = dio,
      _secureStorage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const String textVersionIdKey = 'aeropass.consent.text_version_id';
  static const String enrollmentAttemptIdKey =
      'aeropass.consent.enrollment_attempt_id';
  static const String scopeKey = 'aeropass.consent.scope';
  static const String confirmedAtKey = 'aeropass.consent.confirmed_at';
  static const String statusKey = 'aeropass.consent.status';
  static const String withdrawalRequestedAtKey =
      'aeropass.consent.withdrawal_requested_at';

  /// GET the current, versioned consent text. Always a live call
  /// (research.md §5) — never cached by this service.
  Future<ConsentTextVersionResponse> fetchCurrentText() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/consent/current-text',
    );
    return ConsentTextVersionResponse.fromJson(response.data!);
  }

  /// POSTs a new consent confirmation. Throws on any transport failure
  /// (network, timeout, non-2xx, TLS/pinning failure) — the caller MUST
  /// NOT persist a local record unless this completes without throwing
  /// (FR-008).
  Future<void> submitConsent(Map<String, dynamic> body) async {
    await _dio.post<void>('/v1/consent', data: body);
  }

  /// POSTs a withdrawal request. Throws on any transport failure; the
  /// caller is responsible for leaving the local record `withdrawalPending`
  /// when this throws, per research.md §4's retry-later behavior.
  Future<void> submitWithdrawal(Map<String, dynamic> body) async {
    await _dio.post<void>('/v1/consent/withdraw', data: body);
  }

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
