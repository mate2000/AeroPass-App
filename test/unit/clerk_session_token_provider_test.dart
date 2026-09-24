import 'package:aeropass_app/app/session_gate.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/auth/clerk_session_token_provider.dart';
import 'package:aeropass_app/domain/entities/session_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeSession extends ChangeNotifier implements ClerkSession {
  bool signedIn = false;
  int tokenCalls = 0;
  bool tokenThrows = false;
  bool signOutThrows = false;

  void set(bool value) {
    signedIn = value;
    notifyListeners();
  }

  @override
  bool get isSignedIn => signedIn;

  @override
  Future<String> sessionToken() async {
    tokenCalls++;
    if (tokenThrows) throw StateError('no session');
    return 'jwt-$tokenCalls';
  }

  @override
  Future<void> signOut() async {
    if (signOutThrows) throw StateError('offline');
    signedIn = false;
  }
}

void main() {
  late _FakeSession session;
  late SessionGate gate;
  late ClerkSessionTokenProvider provider;

  setUp(() {
    session = _FakeSession();
    gate = SessionGate();
    provider = ClerkSessionTokenProvider(session, gate: gate);
  });

  test('the gate follows Clerk: signing in opens it, out closes it', () {
    expect(gate.signedIn, isFalse);
    session.set(true);
    expect(gate.signedIn, isTrue);
    session.set(false);
    expect(gate.signedIn, isFalse);
  });

  test('an already signed-in session opens the gate at construction', () {
    final signedIn = _FakeSession()..signedIn = true;
    final openGate = SessionGate();
    ClerkSessionTokenProvider(signedIn, gate: openGate);
    expect(openGate.signedIn, isTrue);
  });

  test('a fresh token is requested per call, never cached (FR-001)', () async {
    session.set(true);
    final first = await provider.token();
    final second = await provider.token();
    expect((first as Ok<String>).value, 'jwt-1');
    expect((second as Ok<String>).value, 'jwt-2');
  });

  test('signed out means SessionUnavailable, without asking Clerk', () async {
    final result = await provider.token();
    expect((result as Error<String>).error, isA<SessionUnavailable>());
    expect(session.tokenCalls, 0);
  });

  test('a Clerk failure is SessionUnavailable', () async {
    session
      ..set(true)
      ..tokenThrows = true;
    final result = await provider.token();
    expect((result as Error<String>).error, isA<SessionUnavailable>());
  });

  test('reestablish succeeds while a token can be had', () async {
    session.set(true);
    expect((await provider.reestablish()).isOk, isTrue);
    expect(gate.signedIn, isTrue);
  });

  test('reestablish without a token closes the gate', () async {
    session
      ..set(true)
      ..tokenThrows = true;
    final result = await provider.reestablish();
    expect((result as Error<void>).error, isA<SessionUnavailable>());
    expect(gate.signedIn, isFalse);
  });

  test('signOut closes the gate even when Clerk fails', () async {
    session
      ..set(true)
      ..signOutThrows = true;
    await provider.signOut();
    expect(gate.signedIn, isFalse);
  });
}
