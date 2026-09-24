import 'package:flutter/widgets.dart';

import '../data/services/full_display_reporter.dart';

/// Wraps a critical screen at its route and reports it fully displayed once,
/// after the first frame in which [ready] is true (015 research §8). Screens
/// ready on first build pass `ready: true`; the pass waits for its QR.
class FullDisplayMarker extends StatefulWidget {
  const FullDisplayMarker({
    required this.reporter,
    required this.ready,
    required this.child,
    super.key,
  });

  final FullDisplayReporter reporter;
  final bool ready;
  final Widget child;

  @override
  State<FullDisplayMarker> createState() => _FullDisplayMarkerState();
}

class _FullDisplayMarkerState extends State<FullDisplayMarker> {
  bool _reported = false;

  @override
  void initState() {
    super.initState();
    _reportOnceReady();
  }

  @override
  void didUpdateWidget(FullDisplayMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _reportOnceReady();
  }

  void _reportOnceReady() {
    if (_reported || !widget.ready) return;
    _reported = true;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.reporter.reportFullyDisplayed(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
