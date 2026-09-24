import 'package:flutter/foundation.dart';

/// The `MOCK:` markers the backend's mock biometric provider reads from an
/// image's bytes (`adapters/biometrics/mock_adapter.py`, 015 research.md
/// §6). Used only when `SYNTHETIC_CAPTURE` is on, in dev and staging, and a
/// release build refuses that flag.
///
/// R-01 is why these matter: a real photo always passes the mock, so only a
/// marker can drive 009, 010 and 011 against a real backend.
enum SyntheticSelfieMarker {
  /// Liveness 0.95, comparison 0.93: `EXITOSO`.
  ok,

  /// Liveness 0.20: `FALLIDO` / `LIVENESS`.
  spoof,

  /// Comparison 0.30: `FALLIDO` / `COMPARACION`.
  other,

  /// The provider hangs, the breaker opens: `NO_CONCLUYENTE`.
  timeout,
}

/// The marker the next synthetic selfie carries. A dev-only picker on 006
/// sets it (T044), and the synthetic camera reads it. In memory only.
class SyntheticMarkerSelection extends ChangeNotifier {
  SyntheticSelfieMarker _selfie = SyntheticSelfieMarker.ok;
  SyntheticSelfieMarker get selfie => _selfie;

  set selfie(SyntheticSelfieMarker marker) {
    if (marker == _selfie) return;
    _selfie = marker;
    notifyListeners();
  }
}
