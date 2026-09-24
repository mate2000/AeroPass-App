import '../../core/result.dart';

/// Supplies the bearer token for `/v1/*` calls (015 FR-001, research.md §2).
///
/// - Staging and prod: `ClerkSessionTokenProvider`, a silent Clerk session.
/// - Dev: `TestSessionTokenProvider`, `test:<id>` for a local backend in
///   fake mode.
///
/// A token is requested immediately before each request and never cached by
/// the caller. A failure is `Result.error(SessionUnavailable())`.
abstract class SessionTokenProvider {
  /// A token for the next request.
  Future<Result<String>> token();

  /// Recovers after a 401. The session is refreshed, or created again when
  /// it was lost.
  Future<Result<void>> reestablish();

  /// Ends the session. Used by consent withdrawal (research.md §14).
  Future<void> signOut();
}
