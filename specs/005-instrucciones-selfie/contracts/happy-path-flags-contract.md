# Contract: `HappyPathFlags` (constitution v1.4.0's release-safety mechanism)

Per research.md §4. Not a domain port — shared, cross-feature build-time/startup infrastructure
every current and future happy-path relaxation flag registers with.

## Interface

```text
abstract final class HappyPathFlags {
  static const bool useFakeConsentBackend;       // USE_FAKE_CONSENT_BACKEND (002-consentimiento)
  static const bool useFakeVerificationBackend;  // USE_FAKE_VERIFICATION_BACKEND (004-confirmar-datos)

  static void assertReleaseSafe({
    bool releaseMode = kReleaseMode,
    List<String>? enabledFlagNamesOverride,
  });
}
```

- Each flag is a `bool.fromEnvironment('...')` compile-time constant, exactly as it is today —
  this contract relocates them, it does not change how they're set (`--dart-define=...` at build
  time, per `.vscode/launch.json`).
- `assertReleaseSafe` throws a descriptive `StateError` iff `releaseMode` is `true` and any flag
  above is `true`. Called exactly once, from `main()`, before `runApp` — a release build with a
  flag mistakenly left on refuses to start rather than silently shipping the relaxation.
- `releaseMode` defaults to `kReleaseMode` (the real compile-time constant) but is an overridable
  parameter specifically so a test can exercise the `releaseMode: true` branch without needing an
  actual release build (research.md §4).
- `enabledFlagNamesOverride` lets a test exercise the "a flag is on" branch against the real
  function without recompiling the test binary with a `--dart-define` (the real flags are
  compile-time constants the test process can't flip at runtime). Real callers (`main()`) never
  pass it — production always checks the real flags.
- A **future feature that introduces a new happy-path flag** adds it to this module's flag list and
  to `assertReleaseSafe`'s condition — this is the one shared place the constitution's "every
  relaxation lives behind a build flag" obligation is enforced, per feature, going forward.

## Contract test suite

1. `releaseMode: false`, all flags off → no throw.
2. `releaseMode: false`, any flag on → no throw (dev/debug builds may use the flags freely).
3. `releaseMode: true`, all flags off → no throw (a clean release build is unaffected).
4. `releaseMode: true`, any one flag on → throws.

## Real usage

`main()` calls `HappyPathFlags.assertReleaseSafe()` (no arguments — the real `kReleaseMode`) as the
first statement, before `runApp(...)`. `composition_root.dart` reads
`HappyPathFlags.useFakeConsentBackend` / `.useFakeVerificationBackend` in place of its own former
private constants.
