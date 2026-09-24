# Quickstart: Backend Integration (015)

These are validation scenarios, not implementation. The contracts are in [contracts/](./contracts/).

## Prerequisites

- **Local backend, for dev.** In `AirPass/Aeropass`:
  1. Start Postgres.
  2. Run `uv run alembic upgrade head`.
  3. Run `AEROPASS_ADAPTERS=fake uv run uvicorn aeropass.main:app --host 0.0.0.0 --port 8000`.

  The Android emulator reaches it at `10.0.2.2:8000`.
- **Staging.** A Clerk instance configured per research.md §2, and its `pk_…` in `env/staging.env`.
  Amendment A3 must be ratified before this flavor can store a session.
- **Automated tests.** Nothing external: `flutter test`. The contract tests replay the fixtures.

## Automated gates

| Command | Proves |
|---|---|
| `flutter analyze --fatal-infos` | zero warnings |
| `flutter test test/contract/backend_api_contract_test.dart` | every endpoint and status parses, and a renamed field or enum value fails (FR-019, SC-001) |
| `flutter test test/unit/outcome_wording_test.dart` | no backend identifier, score or `mensaje` in any passenger string (SC-002) |
| `flutter test test/unit/backend_error_mapping_test.dart` | every `BackendErrorCode` has an explicit outcome (SC-004) |
| `flutter test test/architecture/release_wiring_test.dart` | prod composition calls only the five real paths (FR-025) |
| `flutter test test/unit/no_token_in_logs_test.dart` | no token, header or image in captured logs or Sentry events (FR-017, SC-003) |
| `dart run tool/check_release_env.dart env/prod.env` | no dev flag, no test auth, no synthetic capture, and a mock pairing that holds |

## Walk-throughs

### D — dev flavor, against the local backend

| # | Steps | Expected |
|---|---|---|
| D-1 | Fresh install, run dev | The ribbon "DEMO · biometría simulada" is on every screen. Launch reads `/me` → 404 → Bienvenida |
| D-2 | Consent → 003 (synthetic `documento`) → 004: type CC, `Ana Prueba`, `1020304050`, a date next year → Confirmar | 201. 004 shows `******4050` |
| D-3 | Kill and relaunch | `/me` → `PENDIENTE_VERIFICACION` → the selfie step |
| D-4 | 006, choose the marker `other` | 009, with the match guidance and "Te quedan 2 intentos" |
| D-5 | Retry, choose `spoof` | 009 with the **generic** copy. Compare the text with D-4's generic case: identical |
| D-6 | Retry, choose `timeout` | 011. No attempt is consumed, and the counter still reads 1 left on the next 009 |
| D-7 | Retry, choose `ok` | 008 reads "Registro completado". No "verificada" anywhere |
| D-8 | Mis viajes → type `av 9201` → Mostrar mi pase | The pass for `AV9201`. Only the Embarque step shows, and no security line |
| D-9 | Wait 45 s on the pass | The code changes around 40 s without a tap |
| D-10 | Stop the backend, wait | The code stays until `expira_at`, then "Este código ya no sirve. Pasa por el carril convencional." No QR code |
| D-11 | 004 with number `12`, or a date last year | The field is marked before any request |
| D-12 | A fresh install, then register the same document as D-2 | 010's copy (`DOCUMENTO_YA_REGISTRADO`), not an error |

### S — staging flavor, against the deployed service

| # | Steps | Expected |
|---|---|---|
| S-1 | Fresh install | A silent sign-up. No sign-in screen. `/me` → 404 |
| S-2 | Repeat D-2 to D-8 with synthetic markers | The same outcomes against production. This is SC-009's walk |
| S-3 | Try to use the real camera for the selfie | The picker shows markers only, and no camera frame is sent (FR-018) |

### I — prod-configuration checks, no install needed

| # | Check | Expected |
|---|---|---|
| I-1 | Build a prod APK with `USE_FAKE_VERIFICATION_BACKEND=true` | The release check fails, and the app refuses to start |
| I-2 | Set `BIOMETRIC_PROVIDER_MOCK=false` with no provider name | The release check fails |

## Before a real passenger — release blockers carried by this feature

- **R-01**: a real biometric provider. Until then the ribbon stays, and the release is a demo.
- **F-03**: one retention figure and a deletion job. Screen 02's retention sentence stays
  un-shippable until then.
- **DEC-02**: a server-side consent record.
- **Withdrawal** cannot delete server data (research.md §14).
- **Amendment 1.5.0** (A1–A4) must be ratified.
- **Sentry**: `sendDefaultPii` must be false.
- **Clerk instance** configuration must be confirmed (research.md §2).
