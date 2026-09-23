import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../../app/activated_credential_handoff.dart';
import '../../../data/services/screen_capture_guard.dart';
import '../../../domain/entities/activated_credential.dart';
import '../../../domain/repositories/analytics_emitter.dart';

/// Screen 08's ViewModel (008-identidad-activa). Deliberately thin: the
/// screen has exactly one rendered state — the settled one — because the
/// route cannot build without a confirmed credential (research.md §5).
///
/// Consumes the one-time [ActivatedCredentialHandoff] on creation
/// (research.md §4), so the same credential can never be presented twice
/// (FR-009). It never requests, derives or re-validates the credential:
/// holding an [ActivatedCredential] already proves the backend affirmed it
/// (FR-001). No `package:flutter/material.dart` import (Principle VIII).
class CredentialActivatedViewModel extends ChangeNotifier {
  CredentialActivatedViewModel({
    required ActivatedCredentialHandoff handoff,
    required AnalyticsEmitter analyticsEmitter,
    required ScreenCaptureGuard screenCaptureGuard,
  }) : _analyticsEmitter = analyticsEmitter,
       _screenCaptureGuard = screenCaptureGuard,
       credential = handoff.consume() {
    if (credential != null) {
      _analyticsEmitter.credentialActivatedShown();
    }
  }

  final AnalyticsEmitter _analyticsEmitter;
  final ScreenCaptureGuard _screenCaptureGuard;

  /// The credential being shown, or `null` if the hand-off was already
  /// empty (only reachable if the router guard were bypassed; the view then
  /// renders nothing rather than inventing a credential).
  final ActivatedCredential? credential;

  bool _exited = false;

  /// Called by the view when the screen appears: blocks screenshots and
  /// screen recording while the credential is displayed (FR-012). A failure
  /// is logged without personal data and never blocks the screen.
  Future<void> onShown() async {
    try {
      await _screenCaptureGuard.enable();
    } catch (e) {
      developer.log(
        'screen capture guard enable failed: ${e.runtimeType}',
        name: 'aeropass.screen_capture',
      );
    }
  }

  /// Called by the view when the screen goes away.
  Future<void> onHidden() async {
    try {
      await _screenCaptureGuard.disable();
    } catch (e) {
      developer.log(
        'screen capture guard disable failed: ${e.runtimeType}',
        name: 'aeropass.screen_capture',
      );
    }
  }

  /// "Ir a mis viajes".
  void goToTrips() => _exit(OnwardRoute.trips);

  /// "Ver mi identidad".
  void openCredentialDetail() => _exit(OnwardRoute.credentialDetail);

  /// The system back gesture, redirected to trips (FR-017).
  void onBackGesture() => _exit(OnwardRoute.backGestureToTrips);

  /// Records only the first exit: a double tap, or a tap followed by a back
  /// gesture during the transition, is one departure, not two.
  void _exit(OnwardRoute route) {
    if (_exited) return;
    _exited = true;
    _analyticsEmitter.credentialActivatedRouteTaken(route: route);
  }
}
