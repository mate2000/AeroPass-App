import 'package:flutter/foundation.dart';

import 'result.dart';

/// Wraps a single ViewModel action (e.g. a primary/secondary button tap)
/// with its own running/completed/error state, per Constitution Principle
/// IX ("Command objects for view actions"). This is the mechanism that
/// structurally guarantees Principle III's four async states (loading,
/// success, recoverable failure, terminal failure) instead of relying on
/// each ViewModel to remember them.
///
/// `Command` extends `ChangeNotifier` (not a widget, not `material.dart`)
/// so a `WelcomeView` can listen to it directly via `ListenableBuilder`
/// without the ViewModel itself needing extra plumbing.
abstract class Command<T> extends ChangeNotifier {
  bool _running = false;

  /// True while the wrapped action is in flight.
  bool get running => _running;

  Result<T>? _result;

  /// The most recent completed result, or `null` if the command has never
  /// completed (including while it is currently running).
  Result<T>? get result => _result;

  /// True when the most recent execution completed with an [Error].
  bool get error => _result is Error<T>;

  /// True when the most recent execution completed with an [Ok].
  bool get completed => _result is Ok<T>;

  /// Clears the last result (e.g. after the view has consumed/displayed an
  /// error) without re-running the action.
  void clearResult() {
    _result = null;
    notifyListeners();
  }

  Future<void> execute(Future<Result<T>> Function() action) async {
    if (_running) {
      // FR-004: exactly one concurrent execution — a repeated/double tap
      // while already running is a no-op, not a second invocation.
      return;
    }
    _running = true;
    _result = null;
    notifyListeners();
    try {
      _result = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

/// A [Command] for a zero-argument ViewModel action.
class Command0<T> extends Command<T> {
  Command0(this._action);

  final Future<Result<T>> Function() _action;

  Future<void> run() => execute(_action);
}

/// A [Command] for a single-argument ViewModel action.
class Command1<T, A> extends Command<T> {
  Command1(this._action);

  final Future<Result<T>> Function(A) _action;

  Future<void> run(A argument) => execute(() => _action(argument));
}
