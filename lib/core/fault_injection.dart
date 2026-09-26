import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// A failure injected on the phone's side, before the request reaches the
/// backend (fault injection, contracts/telemetry-events.md §6).
enum NetworkFault {
  none,

  /// The request goes through after [FaultInjection.latency].
  latency,

  /// The request waits its real receive timeout, then fails as a timeout.
  timeout,

  /// The connection fails at once, as with no network.
  connectionLost,

  /// 500 with no `codigo`.
  http500,

  /// 503 `ALMACENAMIENTO_NO_DISPONIBLE`, as when Vercel Blob fails.
  http503Storage,

  /// 504 with no `codigo`, as when Vercel cuts the function at 30 s.
  http504,

  /// 401 `NO_AUTENTICADO`, as when the Clerk session is no longer valid.
  http401,

  /// 429 `LIMITE_EMISION_EXCEDIDO`, the backend's issuance limit.
  http429,
}

/// Which backend calls a fault applies to.
enum FaultScope {
  all(''),
  identity('/v1/identity'),
  biometrics('/v1/biometrics/verifications'),
  passes('/v1/passes');

  const FaultScope(this.pathPrefix);

  final String pathPrefix;

  bool matches(String path) => path.startsWith(pathPrefix);
}

/// A fault requested from the backend in the `X-AeroPass-Fault` header. The
/// backend honours it only on a deployment with its fault injection enabled
/// (never production).
abstract final class BackendFaults {
  static const all = [
    'blob_down',
    'mxface_down',
    'mxface_slow:12000',
    'mxface_quota',
    'db_down',
    'redis_down',
    'signing_down',
    'qstash_down',
  ];
}

/// What a chaos build is injecting right now. Only chaos builds
/// (`HappyPathFlags.chaosTools`) show the panel that changes it, so
/// everywhere else it stays off and costs one boolean check per request.
///
/// While a fault is active, every `Diagnostics` log and every Sentry event
/// is marked, so the dashboards can tell an injected failure from a real
/// incident.
class FaultInjection extends ChangeNotifier {
  FaultInjection();

  /// The one instance the app uses. `Diagnostics` reads it to mark its logs.
  static final FaultInjection instance = FaultInjection();

  static const defaultLatency = Duration(seconds: 5);

  NetworkFault _network = NetworkFault.none;
  FaultScope _scope = FaultScope.all;
  Duration _latency = defaultLatency;
  String? _backendFault;

  NetworkFault get network => _network;
  FaultScope get scope => _scope;
  Duration get latency => _latency;
  String? get backendFault => _backendFault;

  bool get active => _network != NetworkFault.none || _backendFault != null;

  /// A short name for the active faults, for logs and the Sentry tag.
  String get label => [
    if (_network != NetworkFault.none) _network.name,
    if (_backendFault != null) 'backend:$_backendFault',
    if (active && _scope != FaultScope.all) 'scope:${_scope.name}',
  ].join(',');

  set network(NetworkFault value) => _update(() => _network = value);
  set scope(FaultScope value) => _update(() => _scope = value);
  set latency(Duration value) => _update(() => _latency = value);
  set backendFault(String? value) => _update(() => _backendFault = value);

  void clear() => _update(() {
    _network = NetworkFault.none;
    _scope = FaultScope.all;
    _latency = defaultLatency;
    _backendFault = null;
  });

  void _update(VoidCallback change) {
    change();
    _tagSentryScope();
    notifyListeners();
  }

  void _tagSentryScope() {
    if (!Sentry.isEnabled) return;
    final label = this.label;
    unawaited(
      Future.sync(
        () => Sentry.configureScope((scope) async {
          if (label.isEmpty) {
            await scope.removeTag('fault_injected');
          } else {
            await scope.setTag('fault_injected', label);
          }
        }),
      ),
    );
  }
}
