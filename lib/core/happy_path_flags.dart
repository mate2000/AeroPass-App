import 'package:flutter/foundation.dart' show kReleaseMode;

/// Centralizes every "Happy Path First" development-mode relaxation flag
/// (constitution v1.4.0, Principle III's "Happy-Path Development Mode"
/// carve-out), per contracts/happy-path-flags-contract.md
/// (005-instrucciones-selfie).
///
/// Each flag is a `bool.fromEnvironment(...)` compile-time constant, set at
/// build time via `--dart-define=...` (see `env/dev-offline.env`, used by
/// `.vscode/launch.json`'s "dev, offline demo" config) — never a runtime toggle. [assertReleaseSafe] is
/// the interim enforcement of the constitution's "the release pipeline
/// MUST fail if one is enabled" requirement: this project has no CI/release
/// pipeline yet, so the app itself fails fast instead (research.md §4,
/// 005-instrucciones-selfie).
///
/// A future feature introducing a new happy-path flag adds it here, and to
/// [assertReleaseSafe]'s condition — this is the one shared enforcement
/// point, not a per-feature convention to remember.
abstract final class HappyPathFlags {
  /// 002-consentimiento: swaps in `DevConsentRepository` so the consent
  /// gate can be reviewed with no backend deployed.
  static const bool useFakeConsentBackend = bool.fromEnvironment(
    'USE_FAKE_CONSENT_BACKEND',
  );

  /// 004-confirmar-datos: swaps in `DevDocumentVerificationRepository`,
  /// `DevDocumentQualityAssessor`, `DevFieldReverificationRepository`, and
  /// `DevIdentityRecordRepository` so the capture-through-confirmation flow
  /// can be reviewed with no verification backend deployed.
  static const bool useFakeVerificationBackend = bool.fromEnvironment(
    'USE_FAKE_VERIFICATION_BACKEND',
  );

  /// Throws if [releaseMode] is true and any flag above is enabled — a
  /// release build produced with a relaxation left on refuses to run
  /// rather than silently shipping it. [releaseMode] defaults to the real
  /// [kReleaseMode] constant but is overridable so a test can exercise the
  /// release-mode branch without an actual release build (mirroring why
  /// this codebase injects `Clock` rather than calling `DateTime.now()`
  /// directly). [enabledFlagNamesOverride], likewise, lets a test exercise
  /// the "a flag is on" branch without recompiling the test binary with a
  /// `--dart-define` — real callers (`main()`) never pass it, so the real
  /// flags (compile-time constants) are what's actually checked in
  /// production.
  /// 014-qr-pase FR-019 (contracts/release-gate.md): shows "Simular
  /// expirado" on the pass. It manipulates pass validity through the fake
  /// backend only, and a release build refuses to start with it on.
  static const bool devPassControls = bool.fromEnvironment('DEV_PASS_CONTROLS');

  static void assertReleaseSafe({
    bool releaseMode = kReleaseMode,
    List<String>? enabledFlagNamesOverride,
  }) {
    if (!releaseMode) return;
    final enabled =
        enabledFlagNamesOverride ??
        <String>[
          if (useFakeConsentBackend) 'USE_FAKE_CONSENT_BACKEND',
          if (useFakeVerificationBackend) 'USE_FAKE_VERIFICATION_BACKEND',
          if (devPassControls) 'DEV_PASS_CONTROLS',
        ];
    if (enabled.isEmpty) return;
    throw StateError(
      'Happy-path development-mode flag(s) ${enabled.join(', ')} MUST NOT '
      'be enabled in a release build (constitution v1.4.0, Principle III).',
    );
  }
}
