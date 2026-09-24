import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart' show AssetBundle;

/// The only TLS roots the app trusts (015 research.md §4). They are loaded
/// from `assets/tls/`, whose README records each root's source and
/// fingerprint.
class TrustAnchors {
  const TrustAnchors._(this.pems);

  factory TrustAnchors.fromPemBytes(List<List<int>> pems) =>
      TrustAnchors._([for (final pem in pems) Uint8List.fromList(pem)]);

  /// The Google Trust Services roots that both the backend
  /// (`*.vercel.app` → WR1 → R1) and Clerk (WE1 → R4) chain to.
  static const assetPaths = [
    'assets/tls/gts-root-r1.pem',
    'assets/tls/gts-root-r2.pem',
    'assets/tls/gts-root-r3.pem',
    'assets/tls/gts-root-r4.pem',
  ];

  static Future<TrustAnchors> load(AssetBundle bundle) async =>
      TrustAnchors.fromPemBytes([
        for (final path in assetPaths)
          (await bundle.load(path)).buffer.asUint8List(),
      ]);

  final List<Uint8List> pems;

  /// A context that trusts these roots and nothing else: the platform's
  /// default roots are not loaded.
  SecurityContext securityContext() {
    final context = SecurityContext(withTrustedRoots: false);
    for (final pem in pems) {
      context.setTrustedCertificatesBytes(pem);
    }
    return context;
  }
}

/// Builds the [Dio] every backend service uses (constitution Security:
/// "All backend communication MUST use TLS with certificate pinning. A
/// pinning failure MUST fail closed").
///
/// Pinning works by trust anchors. The client trusts only [anchors], so a
/// chain that does not end in one of them fails the TLS handshake, on every
/// connection. `badCertificateCallback` is not a way around it, because it
/// always refuses. The earlier callback-hash approach checked pins only for
/// chains that had already failed validation, so a valid certificate was
/// never pinned at all (research.md §4).
///
/// Plain `http://` is refused unless [allowInsecureHttp] is set. Only the
/// dev flavor sets it, for a local backend, and a release build refuses the
/// flag (`HappyPathFlags.allowInsecureLocalBackend`).
/// How long a backend response may take. The first call after the Vercel
/// function and Neon Postgres have gone idle verifies the Clerk token
/// (fetching Clerk's keys) and wakes the database. Production logs showed
/// `GET /v1/identity/me` still waiting after 5 s, so 5 s cut sign-ins off.
const backendReceiveTimeout = Duration(seconds: 20);

Dio buildPinnedDio({
  required String baseUrl,
  required TrustAnchors anchors,
  bool allowInsecureHttp = false,
  Duration connectTimeout = const Duration(seconds: 5),
  Duration sendTimeout = const Duration(seconds: 10),
  Duration receiveTimeout = backendReceiveTimeout,
}) {
  final scheme = Uri.parse(baseUrl).scheme;
  if (scheme != 'https' && !(scheme == 'http' && allowInsecureHttp)) {
    throw ArgumentError.value(baseUrl, 'baseUrl', 'must be https');
  }
  if (anchors.pems.isEmpty) {
    throw ArgumentError.value(anchors, 'anchors', 'no trust anchors');
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    ),
  );

  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () =>
        HttpClient(context: anchors.securityContext())
          ..badCertificateCallback = (_, _, _) => false,
  );

  return dio;
}
