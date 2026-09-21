import 'package:flutter/foundation.dart';

import '../core/clock.dart';
import '../core/uuid.dart';
import '../domain/entities/enrollment_session.dart';

/// App-process-scoped, in-memory holder of the current `EnrollmentSession`,
/// per FR-004 ("Activating the primary action MUST advance to the consent
/// step and MUST create exactly one enrollment session, regardless of
/// repeated or concurrent activation") and FR-008 (resume, process-alive
/// only).
///
/// This is one of the two app-singletons Constitution Principle IX
/// explicitly scopes as composition-root wiring rather than per-consumer
/// constructor injection ("`EnrollmentSessionController` ... generation
/// [is] the one exception already scoped as app-singletons wired through
/// the composition root") — it is constructed once, in
/// `composition_root.dart`, and injected into `WelcomeViewModel` from
/// there via its constructor, like every other dependency.
///
/// **Never persisted.** A fresh instance is created every app launch and
/// holds no state that outlives the process (Constitution Check, plan.md;
/// spec.md Clarifications).
class EnrollmentSessionController extends ChangeNotifier {
  EnrollmentSessionController({required Clock clock}) : _clock = clock;

  final Clock _clock;
  EnrollmentSession? _current;

  /// The in-progress session, or `null` if none has been started (or the
  /// process was relaunched since one was).
  EnrollmentSession? get current => _current;

  /// Starts a new enrollment session if (and only if) none is already in
  /// progress; otherwise returns the existing one. Synchronous and
  /// side-effect-atomic (no `await` inside), so a repeated or "concurrent"
  /// primary-action tap in the same frame is naturally a no-op rather than
  /// a second session — the mechanism FR-004 requires.
  EnrollmentSession startOrResume() {
    final existing = _current;
    if (existing != null) {
      return existing;
    }
    final created = EnrollmentSession(
      id: generateUuidV4(),
      stepReached: const EnrollmentStep.consent(),
      startedAt: _clock.now(),
    );
    _current = created;
    notifyListeners();
    return created;
  }

  /// Advances the current session's step, e.g. as later screens progress
  /// the passenger through enrollment. A no-op if no session is in
  /// progress.
  void advanceTo(EnrollmentStep step) {
    final existing = _current;
    if (existing == null) return;
    _current = existing.copyWith(stepReached: step);
    notifyListeners();
  }

  /// Clears the current session (e.g. on completion or explicit
  /// cancellation). The next [startOrResume] call creates a fresh one.
  void clear() {
    _current = null;
    notifyListeners();
  }
}
