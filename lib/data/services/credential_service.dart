import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/credential.dart';
import '../models/credential_status_response.dart';

/// Wraps a single external data source per Constitution Principle VIII
/// ("Service — one per external data source, stateless"): here, the pair
/// of `flutter_secure_storage` (cached credential read) and `dio`
/// (certificate-pinned credential-status call) that together back
/// `CredentialRepositoryImpl`.
///
/// Both dependencies are constructor-injected (Principle IX) — this class
/// never reaches into a singleton/service locator for either. Composition
/// happens once, at `lib/app/composition_root.dart`.
///
/// Holds no state itself and exposes only Futures, per Principle VIII.
class CredentialService {
  CredentialService({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  }) : _dio = dio,
       _secureStorage = secureStorage;

  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const String tokenKey = 'aeropass.credential.token';
  static const String validUntilKey = 'aeropass.credential.valid_until';

  /// 012-mis-viajes research.md §1: the display-only identity fields the
  /// passenger already saw on 004 and 008, allowed by Principle I's
  /// allowlist, so the home strip renders offline. Never the full number.
  static const String holderNameKey = 'aeropass.credential.holder_name';
  static const String documentLast4Key = 'aeropass.credential.document_last4';

  /// Reads the credential cached by the credential-issuance feature
  /// (008-identidad-activa). The welcome screen only ever reads this value;
  /// the issuance repository writes it, and consent withdrawal deletes it
  /// (Constitution Principle I's persisted-state allowlist: the token and
  /// its validity window, nothing else).
  Future<Credential?> readCachedCredential() async {
    final token = await _secureStorage.read(key: tokenKey);
    final validUntilRaw = await _secureStorage.read(key: validUntilKey);
    if (token == null || validUntilRaw == null) {
      return null;
    }
    return Credential(token: token, validUntil: DateTime.parse(validUntilRaw));
  }

  /// Calls the backend's credential-status endpoint. Any transport failure
  /// (network, timeout, non-2xx, TLS/pinning failure) is left to throw —
  /// mapping that into `CredentialStatus.Unreachable` is
  /// `CredentialRepositoryImpl`'s job, at the service boundary (Principle
  /// IX: exceptions are caught and converted there, not left as a bare
  /// try/catch in a ViewModel).
  Future<CredentialStatusResponse> fetchStatus({String? token}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/credential/status',
      queryParameters: token == null ? null : {'token': token},
    );
    return CredentialStatusResponse.fromJson(response.data!);
  }

  /// 008-identidad-activa, research.md §3: written by the issuance
  /// repository on a confirmed active credential, before success is
  /// reported. Exactly the two allowlisted values.
  Future<void> writeCachedCredential({
    required String token,
    required DateTime validUntil,
    String? holderName,
    String? documentLast4,
  }) async {
    await _secureStorage.write(key: tokenKey, value: token);
    await _secureStorage.write(
      key: validUntilKey,
      value: validUntil.toUtc().toIso8601String(),
    );
    await writeDisplayFields(
      holderName: holderName,
      documentLast4: documentLast4,
    );
  }

  /// 012-mis-viajes: the stored display fields, or nulls.
  Future<({String? holderName, String? documentLast4})>
  readDisplayFields() async => (
    holderName: await _secureStorage.read(key: holderNameKey),
    documentLast4: await _secureStorage.read(key: documentLast4Key),
  );

  /// 012-mis-viajes: stores whichever display fields are given; a null
  /// leaves that field as it is.
  Future<void> writeDisplayFields({
    String? holderName,
    String? documentLast4,
  }) async {
    if (holderName != null) {
      await _secureStorage.write(key: holderNameKey, value: holderName);
    }
    if (documentLast4 != null) {
      await _secureStorage.write(key: documentLast4Key, value: documentLast4);
    }
  }

  /// 008-identidad-activa, research.md §6: called by consent withdrawal —
  /// "revoking MUST immediately invalidate the local credential"
  /// (Constitution Principle I).
  Future<void> clearCachedCredential() async {
    await _secureStorage.delete(key: tokenKey);
    await _secureStorage.delete(key: validUntilKey);
    await _secureStorage.delete(key: holderNameKey);
    await _secureStorage.delete(key: documentLast4Key);
  }
}
