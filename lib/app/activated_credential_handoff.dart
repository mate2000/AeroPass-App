import 'package:flutter/foundation.dart';

import '../domain/entities/activated_credential.dart';

/// App-process-scoped, in-memory hand-off of a just-issued credential from
/// the verification-progress step to screen 08 (008-identidad-activa,
/// research.md §4) — mirroring `PendingDocumentController`'s shape and
/// lifecycle rules exactly.
///
/// **Never persisted, never logged.** Empty after any process restart,
/// which is what makes screen 08 one-time without any persisted "already
/// shown" state (FR-009): a relaunch starts empty, and a later link in the
/// same process finds the credential already consumed.
class ActivatedCredentialHandoff extends ChangeNotifier {
  ActivatedCredential? _current;

  /// The credential waiting to be shown, or `null`.
  ActivatedCredential? get current => _current;

  /// Read by the router guard (research.md §5).
  bool get hasCredential => _current != null;

  /// Called once by `VerificationProgressViewModel` on
  /// `IssuanceOutcome.activated`.
  void set(ActivatedCredential credential) {
    _current = credential;
    notifyListeners();
  }

  /// Returns the pending credential and clears it. Called once by screen
  /// 08's ViewModel on creation.
  ActivatedCredential? consume() {
    final credential = _current;
    _current = null;
    return credential;
  }

  /// Called on consent withdrawal, and by the router guard when consent is
  /// no longer active.
  void clear() {
    if (_current == null) return;
    _current = null;
    notifyListeners();
  }
}
