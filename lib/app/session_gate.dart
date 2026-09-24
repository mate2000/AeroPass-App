import 'package:flutter/foundation.dart';

/// Whether a signed-in session exists (015 sign-in). The router listens to
/// it, so losing the session mid-flow sends the passenger to the sign-in
/// screen, as the backend's authentication document asks.
///
/// Provided only when sign-in is required (the Clerk flavors). Dev, with
/// `test:` tokens, and the offline demo have none, so nothing is guarded
/// there.
class SessionGate extends ChangeNotifier {
  bool _signedIn = false;
  bool get signedIn => _signedIn;

  void markSignedIn() => _set(true);

  void markSignedOut() => _set(false);

  void _set(bool value) {
    if (value == _signedIn) return;
    _signedIn = value;
    notifyListeners();
  }
}
