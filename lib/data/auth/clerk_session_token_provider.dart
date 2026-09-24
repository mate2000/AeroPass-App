import 'package:clerk_auth/clerk_auth.dart' as clerk show ClerkError;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../app/session_gate.dart';
import '../../core/diagnostics.dart';
import '../../core/result.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/session_token_provider.dart';

/// The operations of Clerk's auth state that the app uses, behind an
/// interface so the logic is testable without Clerk.
abstract class ClerkSession implements Listenable {
  bool get isSignedIn;
  Future<String> sessionToken();
  Future<void> signOut();
}

/// [ClerkSession] over the embedded widget's [ClerkAuthState].
class ClerkAuthStateSession implements ClerkSession {
  ClerkAuthStateSession(this._state);

  final ClerkAuthState _state;

  @override
  bool get isSignedIn => _state.isSignedIn;

  @override
  Future<String> sessionToken() async => (await _state.sessionToken()).jwt;

  @override
  Future<void> signOut() => _state.signOut();

  @override
  void addListener(VoidCallback listener) => _state.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _state.removeListener(listener);
}

/// Session tokens from Clerk's embedded sign-in (015, the backend's
/// authentication document).
///
/// - **A token per call**, never cached here (FR-001).
/// - **The session gate follows Clerk.** Signing in through
///   `ClerkAuthentication` opens it, and the router then leaves the sign-in
///   screen. Signing out, or a session Clerk can no longer refresh, closes
///   it, and every guarded route leads back to sign-in.
class ClerkSessionTokenProvider implements SessionTokenProvider {
  ClerkSessionTokenProvider(
    this._session, {
    required SessionGate gate,
    Diagnostics diagnostics = const Diagnostics(),
  }) : _gate = gate,
       _diagnostics = diagnostics {
    _session.addListener(_sync);
    _sync();
  }

  final ClerkSession _session;
  final SessionGate _gate;
  final Diagnostics _diagnostics;

  void _sync() {
    if (_session.isSignedIn != _gate.signedIn) {
      _diagnostics.info('session_gate', {'signed_in': _session.isSignedIn});
    }
    if (_session.isSignedIn) {
      _gate.markSignedIn();
    } else {
      _gate.markSignedOut();
    }
  }

  @override
  Future<Result<String>> token() async {
    if (!_session.isSignedIn) {
      _diagnostics.warn('session_token_unavailable', {'reason': 'signed_out'});
      return const Result.error(SessionUnavailable());
    }
    final watch = Stopwatch()..start();
    try {
      final jwt = await _session.sessionToken();
      _diagnostics.info('session_token', {'ms': watch.elapsedMilliseconds});
      return Result.ok(jwt);
    } on Object catch (error) {
      _diagnostics.error('session_token_failed', {
        'code': error is clerk.ClerkError ? error.code.name : error.runtimeType,
        'detail': error,
      });
      return const Result.error(SessionUnavailable());
    }
  }

  /// After a 401: one fresh token is tried. If none can be had, the session
  /// is over, and the passenger signs in again.
  @override
  Future<Result<void>> reestablish() async {
    if ((await token()).isOk) return const Result.ok(null);
    _diagnostics.error('session_ended', {'code': 'no_fresh_token'});
    _gate.markSignedOut();
    return const Result.error(SessionUnavailable());
  }

  @override
  Future<void> signOut() async {
    try {
      await _session.signOut();
    } on Object {
      // Locally signed out regardless (consent withdrawal, research.md §14).
    }
    _gate.markSignedOut();
  }
}
