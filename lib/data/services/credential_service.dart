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

  /// Reads the credential cached by the credential-issuance feature. This
  /// screen only ever reads this value; it never writes it (Constitution
  /// Principle I's persisted-state allowlist).
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
}
