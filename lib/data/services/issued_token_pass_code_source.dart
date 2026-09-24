import '../../core/result.dart';
import '../../domain/entities/pass.dart';
import '../../domain/repositories/pass_code_source.dart';
import 'backend_pass_repository.dart';

/// 014's [PassCodeSource] against the real backend, where the code is the
/// issued token and rotation is renewal (015 research.md §10, FR-012).
///
/// - **Before the renewal time**, the current token is the code. Its window
///   ends at the renewal time, so 014's ViewModel asks again then.
/// - **At the renewal time**, a new pass is issued for the same flight.
/// - **If renewal fails**, the still-valid token stays on screen, marked
///   pending, and renewal is retried after the backend's Retry-After, or 2 s.
///   Once `expira_at` passes, 014's own expiry check removes the code
///   (SC-006). This source never extends a pass.
class IssuedTokenPassCodeSource implements PassCodeSource {
  IssuedTokenPassCodeSource(this._repository);

  final BackendPassRepository _repository;

  /// Between renewal attempts, when the backend gives no Retry-After.
  static const retryPause = Duration(seconds: 2);

  DateTime? _nextAttemptAt;

  @override
  Future<Result<PassCode>> codeAt(Pass pass, DateTime instant) async {
    final current = _repository.current;
    if (current == null) return Result.error(StateError('no pass held'));
    if (instant.isBefore(current.renewAt)) return Result.ok(_codeOf(current));

    final nextAttemptAt = _nextAttemptAt;
    if (nextAttemptAt != null && instant.isBefore(nextAttemptAt)) {
      return _pendingOrExpired(current, nextAttemptAt, instant);
    }

    final renewed = await _repository.issue(current.pass.tripId);
    switch (renewed) {
      case Ok():
        _nextAttemptAt = null;
        return Result.ok(_codeOf(_repository.current!));
      case Error(:final error, :final stackTrace):
        final wait = error is PassIssueRefused
            ? error.retryAfter ?? retryPause
            : retryPause;
        _nextAttemptAt = instant.add(wait);
        if (!instant.isBefore(current.pass.validUntil)) {
          return Result.error(error, stackTrace);
        }
        return _pendingOrExpired(current, _nextAttemptAt!, instant);
    }
  }

  static PassCode _codeOf(IssuedPass issued) => PassCode(
    payload: issued.token,
    windowStartsAt: issued.issuedAt,
    windowEndsAt: issued.renewAt,
  );

  static Result<PassCode> _pendingOrExpired(
    IssuedPass current,
    DateTime nextAttemptAt,
    DateTime instant,
  ) {
    final validUntil = current.pass.validUntil;
    if (!instant.isBefore(validUntil)) {
      return Result.error(StateError('pass expired while renewing'));
    }
    return Result.ok(
      PassCode(
        payload: current.token,
        windowStartsAt: current.issuedAt,
        windowEndsAt: nextAttemptAt.isBefore(validUntil)
            ? nextAttemptAt
            : validUntil,
        renewalPending: true,
      ),
    );
  }
}
