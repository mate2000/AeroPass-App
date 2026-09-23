# Contract: the "Simular expirado" release gate (FR-019, SC-006)

## Flag

`HappyPathFlags.devPassControls` is a `const bool` read from `DEV_PASS_CONTROLS`. It is added to
`assertReleaseSafe`'s list, so a release build with it enabled throws at startup.

## Absence in release

The control is built only as `if (HappyPathFlags.devPassControls) _DevExpireControl(...)`. The flag
is a compile-time constant, so a release build that defines it false contains neither the widget nor
its callback. The callback asks the **fake backend** to expire the pass. No client-side "expired"
flag exists anywhere.

## Pipeline

- `tool/check_release_env.dart <env-file>` exits non-zero if the file sets any of these to `true`:
  - `USE_FAKE_CONSENT_BACKEND`,
  - `USE_FAKE_VERIFICATION_BACKEND`,
  - `DEV_VERIFICATION_FAILURE` (any value),
  - `DEV_PASS_CONTROLS`.
- `.github/workflows/ci.yaml` gains the step "Release env has no development flags", which runs it
  on `env/prod.env`.

## Tests

1. The tool fails on a fixture env with `DEV_PASS_CONTROLS=true`, and passes on `env/prod.env`.
2. `assertReleaseSafe(releaseMode: true, enabledFlagNamesOverride: ['DEV_PASS_CONTROLS'])` throws.
3. A widget test with the flag off, the test default, finds no "Simular expirado".
