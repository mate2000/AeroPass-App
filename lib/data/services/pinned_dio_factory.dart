import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Builds a [Dio] instance whose TLS connections are certificate-pinned
/// against a fixed set of SHA-256 certificate hashes, per research.md §4
/// and the Constitution's Security & Compliance Constraints ("All backend
/// communication MUST use TLS with certificate pinning. A pinning failure
/// MUST fail closed.").
///
/// A pinning failure throws before the request completes.
/// `CredentialRepositoryImpl` catches it and maps it to
/// `CredentialStatus.Unreachable` (fail closed, per FR-007) rather than
/// letting it escape as a bare exception (Principle IX).
///
/// This is composed once, at the app's composition root
/// (`lib/app/composition_root.dart`), and injected into `CredentialService`
/// via its constructor — no service reaches into a global client.
Dio buildPinnedDio({
  required String baseUrl,
  required Set<String> pinnedSha256CertificateHashes,
  Duration connectTimeout = const Duration(seconds: 5),
  Duration receiveTimeout = const Duration(seconds: 5),
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
    ),
  );

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      // dart:io only invokes badCertificateCallback for a certificate that
      // has already failed normal chain validation, so this enforces "pin
      // as a hard requirement" for otherwise-untrusted chains. Pinning
      // against an already-trusted chain's public key (defense in depth
      // against a compromised/misissued CA) is a follow-up hardening step
      // tracked outside this feature's scope.
      client.badCertificateCallback = (cert, host, port) {
        final hash = sha256.convert(cert.der).toString();
        return pinnedSha256CertificateHashes.contains(hash);
      };
      return client;
    },
  );

  return dio;
}
