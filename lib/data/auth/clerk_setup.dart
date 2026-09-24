import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
// ClerkFileCache is not exported, and the only way to keep Clerk from
// writing image files to the documents folder is to supply one.
// ignore: implementation_imports
import 'package:clerk_flutter/src/utils/clerk_file_cache.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../core/diagnostics.dart';
import '../services/pinned_dio_factory.dart';
import 'clerk_localizations_es.dart';

/// Clerk's embedded sign-in, configured for AeroPass (015; the backend's
/// authentication document).
///
/// - **Telemetry and background polling are off.** The SDK's defaults send
///   telemetry to clerk-telemetry.com every 29 s and poll every 9.7 s
///   (research.md §2). The app asks for a token per call instead.
/// - **Traffic uses the pinned trust anchors** (research.md §4), through
///   [PinnedClerkHttpService].
/// - **Nothing is written to disk.** The session lives in memory
///   ([MemoryPersistor]) until amendment A3 allows secure storage (T024), so
///   a restart means signing in again. The image cache is off
///   ([NoFileCache]), so `path_provider`'s documents folder is never used.
/// - **Spanish** ([ClerkSdkLocalizationsEs]).
ClerkAuthConfig aeroPassClerkConfig({
  required String publishableKey,
  required TrustAnchors trustAnchors,
}) {
  final spanish = ClerkSdkLocalizationsEs();
  return ClerkAuthConfig(
    publishableKey: publishableKey,
    persistor: MemoryPersistor(),
    fileCache: const NoFileCache(),
    httpService: PinnedClerkHttpService(
      trustAnchors,
      frontendApiHost: clerkFrontendApiHost(publishableKey),
    ),
    sessionTokenPolling: false,
    telemetryPeriod: Duration.zero,
    clientRefreshPeriod: Duration.zero,
    localizations: {'es': spanish},
    fallbackLocalization: spanish,
  );
}

/// The Clerk Frontend API host a publishable key names: the key is
/// `pk_(test|live)_` + base64(`<host>$`). Null when the key is malformed.
String? clerkFrontendApiHost(String publishableKey) {
  final parts = publishableKey.split('_');
  if (parts.length < 3) return null;
  try {
    final decoded = utf8.decode(base64.decode(base64.normalize(parts.last)));
    final host = decoded.endsWith(r'$')
        ? decoded.substring(0, decoded.length - 1)
        : decoded;
    return host.isEmpty ? null : host;
  } on FormatException {
    return null;
  }
}

/// No image cache: Clerk's logos and avatars are simply not shown, so no
/// file is ever written.
class NoFileCache implements ClerkFileCache {
  const NoFileCache();

  @override
  Future<void> initialize() async {}

  @override
  void terminate() {}

  @override
  Stream<File> stream(
    Uri uri, {
    Duration ttl = ClerkFileCache.defaultTTL,
    Map<String, String>? headers,
  }) => const Stream.empty();
}

/// Keeps Clerk's client state in memory only (015 T024, pending A3).
class MemoryPersistor implements clerk.Persistor {
  final _values = <String, Object?>{};

  @override
  Future<void> initialize() async {}

  @override
  void terminate() => _values.clear();

  @override
  FutureOr<T?> read<T>(String key) => _values[key] as T?;

  @override
  FutureOr<void> write<T>(String key, T value) => _values[key] = value;

  @override
  FutureOr<void> delete(String key) => _values.remove(key);
}

/// Clerk's HTTP through the app's trust anchors, so a chain not ending in
/// a pinned root fails the handshake (research.md §4). The instance
/// `*.clerk.accounts.dev` chains to GTS Root R4, which is pinned.
class PinnedClerkHttpService implements clerk.HttpService {
  PinnedClerkHttpService(
    this._anchors, {
    this.frontendApiHost,
    Diagnostics diagnostics = const Diagnostics(),
  }) : _diagnostics = diagnostics;

  final TrustAnchors _anchors;
  final Diagnostics _diagnostics;

  /// The instance's Frontend API host. When known, [initialize] opens the
  /// pinned connection to it ahead of the SDK's first calls.
  final String? frontendApiHost;

  /// How long the warm-up may take. The SDK allows only 1 s each for its
  /// first two calls (`Auth._initialisationTimeout`), which a cold TLS
  /// handshake on a phone can exceed; a sign-in then fails until the SDK's
  /// retry 10 s later. An already-open connection makes those calls fit.
  static const warmUpTimeout = Duration(seconds: 6);

  http.Client? _client;

  http.Client get _http => _client ??= IOClient(
    HttpClient(context: _anchors.securityContext())
      ..badCertificateCallback = (_, _, _) => false,
  );

  @override
  Future<void> initialize() async {
    final host = frontendApiHost;
    if (host == null) {
      _diagnostics.warn('clerk_http_warmup_skipped', {'reason': 'no_host'});
      return;
    }
    final watch = Stopwatch()..start();
    try {
      final response = await _http
          .get(Uri.https(host, '/v1/health'))
          .timeout(warmUpTimeout);
      _diagnostics.info('clerk_http_warmup', {
        'status': response.statusCode,
        'ms': watch.elapsedMilliseconds,
      });
    } on Object catch (error) {
      _diagnostics.error('clerk_http_warmup_failed', {
        'code': error.runtimeType,
        'detail': error,
        'ms': watch.elapsedMilliseconds,
      });
    }
  }

  @override
  void terminate() {
    _client?.close();
    _client = null;
  }

  @override
  Future<bool> ping(Uri uri, {required Duration timeout}) async {
    try {
      final response = await _http.head(uri).timeout(timeout);
      return response.statusCode == 200;
    } on Exception {
      return false;
    }
  }

  @override
  Future<http.Response> send(
    clerk.HttpMethod method,
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    String? body,
  }) {
    final request = http.Request(method.toString(), uri);
    if (headers != null) request.headers.addAll(headers);
    if (params != null) {
      // As the SDK's own service does (`toStringMap`).
      request.bodyFields = {
        for (final MapEntry(:key, :value) in params.entries)
          key: value.toString(),
      };
    }
    if (body != null) request.body = body;
    return _logged(request);
  }

  @override
  Future<http.Response> sendByteStream(
    clerk.HttpMethod method,
    Uri uri,
    http.ByteStream byteStream,
    int length,
    Map<String, String> headers,
  ) {
    final request = http.MultipartRequest(method.toString(), uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile(
          'file',
          byteStream,
          length,
          filename: byteStream.hashCode.toString(),
        ),
      );
    return _logged(request);
  }

  /// Sends [request] and logs its method, path (never the query or body),
  /// status and duration, plus Clerk's error codes on a failure.
  Future<http.Response> _logged(http.BaseRequest request) async {
    final watch = Stopwatch()..start();
    final path = request.url.path;
    try {
      final response = await http.Response.fromStream(
        await _http.send(request),
      );
      final attributes = {
        'method': request.method,
        'path': path,
        'status': response.statusCode,
        'ms': watch.elapsedMilliseconds,
      };
      if (response.statusCode >= 400) {
        _diagnostics.warn('clerk_http_error', {
          ...attributes,
          ...clerkErrorSummary(response.body),
        });
      } else {
        _diagnostics.info('clerk_http', attributes);
      }
      return response;
    } on Object catch (error) {
      // A TLS handshake refused by the pinned roots lands here.
      _diagnostics.error('clerk_http_failed', {
        'code': error.runtimeType,
        'method': request.method,
        'path': path,
        'detail': error,
        'ms': watch.elapsedMilliseconds,
      });
      rethrow;
    }
  }
}

/// The error codes, parameter names and long messages of a Clerk Frontend
/// API error body (`{"errors": [{"code", "long_message", "meta":
/// {"param_name"}}]}`). Values still pass through [redactDiagnostic].
Map<String, String> clerkErrorSummary(String body) {
  try {
    final json = jsonDecode(body);
    if (json case {'errors': final List<dynamic> errors}) {
      final items = errors.whereType<Map<String, dynamic>>();
      return {
        'code': items.map((e) => e['code']).nonNulls.join(','),
        'params': items
            .map((e) => (e['meta'] as Map<String, dynamic>?)?['param_name'])
            .nonNulls
            .join(','),
        'message': items
            .map((e) => e['long_message'] ?? e['message'])
            .nonNulls
            .join('; '),
      };
    }
  } on FormatException {
    // Not JSON: nothing to add.
  }
  return const {};
}
