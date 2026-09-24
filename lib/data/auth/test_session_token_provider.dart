import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/result.dart';
import '../../core/uuid.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/session_token_provider.dart';

/// The dev flavor's session (015 research.md §5). It answers `test:<id>`,
/// which a local backend in fake-adapter mode accepts as
/// `Authorization: Bearer test:<id>` (`adapters/fakes/auth.py`).
///
/// The id is random, generated once per install, and kept in secure storage
/// so a dev run can exercise resume across restarts. It is wired only when
/// `AUTH_MODE=test`, which a release build refuses (`assertReleaseSafe`,
/// `tool/check_release_env.dart`).
class TestSessionTokenProvider implements SessionTokenProvider {
  TestSessionTokenProvider({required FlutterSecureStorage secureStorage})
    : _storage = secureStorage;

  final FlutterSecureStorage _storage;

  static const storageKey = 'dev.test_session_id';

  @override
  Future<Result<String>> token() async {
    try {
      var id = await _storage.read(key: storageKey);
      if (id == null) {
        id = generateUuidV4();
        await _storage.write(key: storageKey, value: id);
      }
      return Result.ok('test:$id');
    } on Object {
      return const Result.error(SessionUnavailable());
    }
  }

  /// A test token cannot go stale. A 401 from the fake backend means a bug,
  /// so there is nothing to refresh.
  @override
  Future<Result<void>> reestablish() async => const Result.ok(null);

  /// Forgets the id, so the next launch is a new passenger, as a lost Clerk
  /// session would be.
  @override
  Future<void> signOut() async {
    try {
      await _storage.delete(key: storageKey);
    } on Object {
      // Best effort. Withdrawal clears the rest regardless.
    }
  }
}
