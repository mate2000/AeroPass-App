import 'dart:async' show unawaited;

import 'package:flutter/foundation.dart';

import '../../core/command.dart';
import '../../core/result.dart';
import '../../domain/repositories/consent_repository.dart';

/// The withdrawal placeholder route's ViewModel — deliberately minimal,
/// per plan.md ("a minimal, two-action entry point"; the polished account
/// surface itself is out of scope, spec.md Out of Scope). No `material.dart`
/// import, testable headless (Constitution Principle VIII); the
/// `ConsentRepository` dependency is constructor-injected (Principle IX).
class WithdrawalViewModel extends ChangeNotifier {
  WithdrawalViewModel({required ConsentRepository consentRepository})
    : _consentRepository = consentRepository {
    withdraw = Command0(_withdraw);
    unawaited(_load());
  }

  final ConsentRepository _consentRepository;

  /// FR-016: invalidates the local credential immediately (handled inside
  /// `ConsentRepositoryImpl.withdraw()`, SC-005 — no network dependency for
  /// that local effect) and submits for backend processing.
  late final Command0<void> withdraw;

  bool _loading = true;

  /// True while the initial local-record check is in flight.
  bool get loading => _loading;

  bool _hasRecord = false;

  /// Whether a local `ConsentRecord` exists to withdraw. `false` after a
  /// successful withdrawal too, since it's no longer an *active* consent
  /// (used to decide whether the confirm action is offered at all).
  bool get hasRecord => _hasRecord;

  Future<void> _load() async {
    final result = await _consentRepository.getLocalRecord();
    _hasRecord = result.valueOrNull != null;
    _loading = false;
    notifyListeners();
  }

  Future<Result<void>> _withdraw() async {
    final result = await _consentRepository.withdraw();
    return result.when(
      ok: (_) {
        _hasRecord = false;
        return const Result.ok(null);
      },
      error: (error, stackTrace) => Result.error(error, stackTrace),
    );
  }

  @override
  void dispose() {
    withdraw.dispose();
    super.dispose();
  }
}
