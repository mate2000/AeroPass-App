/// Why no authenticated call could be made (015 FR-001, research.md §2).
///
/// It is returned when the session provider cannot produce a token: it could
/// not sign up silently, could not reach the identity provider, or has no
/// stored session to refresh. Presentation shows "No pudimos conectar tu
/// sesión" for it (contracts/outcome-mapping.md "Session"), never 011's
/// service copy and never a generic error.
final class SessionUnavailable {
  const SessionUnavailable();

  @override
  String toString() => 'SessionUnavailable';
}
