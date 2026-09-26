import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../core/diagnostics.dart';
import '../core/fault_injection.dart';

/// The fault-injection panel of chaos builds (`HappyPathFlags.chaosTools`,
/// contracts/telemetry-events.md §6): a small button over every screen that
/// opens controls to inject network and backend faults, force a crash, and
/// clear everything.
///
/// A developer tool, not passenger UI: its text is not localized, and a
/// release build refuses to start with the flag that shows it. It sits above
/// the navigator, so it uses no widget that needs an overlay (no dropdowns,
/// sliders or tooltips).
class ChaosPanel extends StatefulWidget {
  const ChaosPanel({required this.child, FaultInjection? faults, super.key})
    : _faults = faults;

  final Widget child;
  final FaultInjection? _faults;

  @override
  State<ChaosPanel> createState() => _ChaosPanelState();
}

class _ChaosPanelState extends State<ChaosPanel> {
  bool _open = false;

  FaultInjection get _faults => widget._faults ?? FaultInjection.instance;

  static const _networkLabels = {
    NetworkFault.none: 'Ninguno',
    NetworkFault.latency: 'Latencia',
    NetworkFault.timeout: 'Timeout',
    NetworkFault.connectionLost: 'Sin conexión',
    NetworkFault.http500: '500',
    NetworkFault.http503Storage: '503 Blob',
    NetworkFault.http504: '504 Vercel',
    NetworkFault.http401: '401 sesión',
    NetworkFault.http429: '429 límite',
  };

  static const _scopeLabels = {
    FaultScope.all: 'Todo',
    FaultScope.identity: 'Identidad',
    FaultScope.biometrics: 'Biometría',
    FaultScope.passes: 'Pases',
  };

  static const _latencies = [
    Duration(seconds: 2),
    Duration(seconds: 5),
    Duration(seconds: 12),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 8,
          bottom: 72,
          child: SafeArea(
            child: ListenableBuilder(
              listenable: _faults,
              builder: (context, _) => _open ? _panel(context) : _button(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _button() => Semantics(
    button: true,
    label: 'Inyección de fallos',
    child: FloatingActionButton.small(
      heroTag: null,
      backgroundColor: _faults.active ? Colors.red : Colors.black54,
      foregroundColor: Colors.white,
      onPressed: () => setState(() => _open = true),
      child: const Icon(Icons.bolt),
    ),
  );

  Widget _panel(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 16;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.6;
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Inyección de fallos',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _open = false),
                  ),
                ],
              ),
              Text(
                _faults.active ? 'Activo: ${_faults.label}' : 'Sin fallos',
                style: TextStyle(
                  color: _faults.active ? Colors.red : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Red (lado del teléfono)'),
              _chips<NetworkFault>(
                _networkLabels,
                _faults.network,
                (v) => _faults.network = v,
              ),
              if (_faults.network == NetworkFault.latency) ...[
                const Text('Latencia'),
                _chips<Duration>(
                  {for (final d in _latencies) d: '${d.inSeconds} s'},
                  _faults.latency,
                  (v) => _faults.latency = v,
                ),
              ],
              const Text('Alcance'),
              _chips<FaultScope>(
                _scopeLabels,
                _faults.scope,
                (v) => _faults.scope = v,
              ),
              const Text(
                'Fallo pedido al backend (solo en un Preview con la '
                'inyección activada)',
              ),
              _chips<String?>(
                {null: 'Ninguno', for (final f in BackendFaults.all) f: f},
                _faults.backendFault,
                (v) => _faults.backendFault = v,
              ),
              const Divider(),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  OutlinedButton(
                    onPressed: _faults.clear,
                    child: const Text('Limpiar'),
                  ),
                  OutlinedButton(
                    onPressed: _unhandledError,
                    child: const Text('Error no controlado'),
                  ),
                  OutlinedButton(
                    onPressed: _nativeCrash,
                    child: const Text('Crash nativo'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chips<T>(
    Map<T, String> options,
    T selected,
    ValueChanged<T> onPick,
  ) => Wrap(
    spacing: 6,
    runSpacing: 2,
    children: [
      for (final MapEntry(key: value, value: label) in options.entries)
        ChoiceChip(
          label: Text(label),
          selected: value == selected,
          onSelected: (_) => onPick(value),
        ),
    ],
  );

  /// An unhandled Dart error: Sentry reports it as unhandled, which feeds
  /// the crash-free widgets and alert A2.
  void _unhandledError() {
    const Diagnostics().warn('fault_injected', {'fault': 'unhandled_error'});
    unawaited(
      Future<void>(() => throw StateError('fault injected: unhandled error')),
    );
  }

  /// A native crash: the app closes, and Sentry sends the report on the next
  /// launch.
  void _nativeCrash() {
    const Diagnostics().warn('fault_injected', {'fault': 'native_crash'});
    unawaited(SentryFlutter.nativeCrash());
  }
}
