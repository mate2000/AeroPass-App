import '../../core/result.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/session_token_provider.dart';

/// Stands in for `ClerkSessionTokenProvider` while it cannot be built.
///
/// That class persists Clerk's session, which needs amendment 1.5.0's A3
/// (015 tasks.md T024 ⛔A3). Until A3 is ratified, staging and prod get this
/// provider: every authenticated call fails with [SessionUnavailable], and
/// the passenger sees "No pudimos conectar tu sesión". Nothing is persisted,
/// and no Clerk user is created.
class UnavailableSessionTokenProvider implements SessionTokenProvider {
  const UnavailableSessionTokenProvider();

  @override
  Future<Result<String>> token() async =>
      const Result.error(SessionUnavailable());

  @override
  Future<Result<void>> reestablish() async =>
      const Result.error(SessionUnavailable());

  @override
  Future<void> signOut() async {}
}
