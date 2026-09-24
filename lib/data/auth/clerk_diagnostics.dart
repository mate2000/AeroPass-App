import 'dart:async';

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';

import '../../core/diagnostics.dart';

/// Makes Clerk's embedded sign-in observable in production.
///
/// The passenger only ever sees generic Spanish errors
/// (`ClerkSdkLocalizationsEs`), so the real reason for a failed sign-in is
/// logged here instead: the SDK's error code, Clerk's server error codes and
/// messages, and each step of the sign-in or sign-up (its status, the
/// strategies on offer, the fields still missing). No identifier, code or
/// password is logged.
class ClerkDiagnostics {
  ClerkDiagnostics(this._state, {Diagnostics diagnostics = const Diagnostics()})
    : _diagnostics = diagnostics {
    _errors = _state.errorStream.listen(onError);
    _state.addListener(_onChange);
    _diagnostics.info('clerk_ready', {
      'client_loaded': _state.client.isNotEmpty,
      'environment_loaded': _state.env.isNotEmpty,
      'signed_in': _state.isSignedIn,
    });
    _last = _snapshot();
  }

  final ClerkAuthState _state;
  final Diagnostics _diagnostics;
  late final StreamSubscription<clerk.ClerkError> _errors;
  String? _last;

  /// Logs one error from the SDK. Public for tests.
  void onError(clerk.ClerkError error) {
    // ExternalError is not exported, so its type is left to inference.
    final server = [...?error.errors?.errors];
    _diagnostics.error('clerk_error', {
      'code': error.code.name,
      'server_codes': server.map((e) => e.code).nonNulls.join(','),
      'params': server.map((e) => e.meta?['param_name']).nonNulls.join(','),
      'message': server.isEmpty
          ? error.toString()
          : server.map((e) => e.fullMessage).join('; '),
      ..._stepAttributes(),
    });
  }

  void _onChange() {
    final snapshot = _snapshot();
    if (snapshot == _last) return;
    _last = snapshot;
    _diagnostics.info('clerk_step', _stepAttributes());
  }

  String _snapshot() => _stepAttributes().toString();

  Map<String, Object?> _stepAttributes() {
    final client = _state.client;
    final signIn = client.signIn;
    final signUp = client.signUp;
    return {
      'signed_in': _state.isSignedIn,
      'client_loaded': client.isNotEmpty,
      'environment_loaded': _state.env.isNotEmpty,
      'sign_in_status': signIn?.status.name,
      'sign_in_first_factors': signIn?.supportedFirstFactors
          .map((f) => f.strategy.toString())
          .join(','),
      'sign_in_second_factors': signIn?.supportedSecondFactors
          .map((f) => f.strategy.toString())
          .join(','),
      'sign_in_verification': _verification(
        signIn?.secondFactorVerification ?? signIn?.firstFactorVerification,
      ),
      'sign_up_status': signUp?.status.name,
      'sign_up_missing': signUp?.missingFields.map((f) => f.name).join(','),
      'sign_up_unverified': signUp?.unverifiedFields
          .map((f) => f.name)
          .join(','),
    };
  }

  static String? _verification(clerk.Verification? v) => v == null
      ? null
      : [
          v.strategy.toString(),
          v.status.name,
          if (v.attempts case final int attempts) 'attempts=$attempts',
          if (v.errorMessage case final String message) message,
        ].join(' ');

  void dispose() {
    unawaited(_errors.cancel());
    _state.removeListener(_onChange);
  }
}
