# AeroPass

AeroPass is a B2B airport digital-identity mobile app: a passenger enrolls once (identity document
+ liveness selfie), receives a digital credential, and passes security and boarding with a dynamic
QR pass instead of physical documents. This repository is the Flutter passenger app — the
passenger's entire surface of the product.

The project is built spec-first with [Spec Kit](https://github.com/github/spec-kit): every feature
starts as a specification under `specs/`, is planned against the project constitution, broken into
tasks, and only then implemented. See [Governance](#governance--specs) below before adding a
feature.

## Status

Three enrollment screens are implemented end to end (domain/data/view layers, tests, and the routes
wiring them together):

| # | Feature | Spec |
|---|---|---|
| 001 | Welcome & entry point | [`specs/001-bienvenida`](specs/001-bienvenida) |
| 002 | Informed consent gate | [`specs/002-consentimiento`](specs/002-consentimiento) |
| 003 | Identity document capture | [`specs/003-escanear-documento`](specs/003-escanear-documento) |

Everything past document capture (data confirmation, selfie/liveness, retry guidance, agent
escalation, credential issuance, trips/pass, account/withdrawal surface) exists only as placeholder
stub routes — enough to navigate to and demonstrate the flow, not real screens yet.

**There is no backend yet.** Every network call (credential status, consent text/recording,
document verification) hits a placeholder host and fails by design — see
[Running without a backend](#running-without-a-backend).

## Architecture

The app follows
[Flutter's official app-architecture guidance](https://docs.flutter.dev/app-architecture), enforced
by the project constitution (`.specify/memory/constitution.md`):

```text
View → ViewModel → (Use-case) → Repository → Service
```

- **View** — widget composition only, no business logic, no direct repository/service calls.
- **ViewModel** — one per view, exposes state and `Command` objects for actions, no Flutter import,
  testable headless.
- **Repository** — the source of truth for one domain model, returns `Result<T>`, never a DTO or
  exception, across layer boundaries.
- **Service** — one per external data source (a REST endpoint, secure storage, the camera), stateless.

State management is `provider` with `ChangeNotifier` ViewModels; dependency composition happens once,
at `lib/app/composition_root.dart`, and again at route boundaries in `lib/app/router.dart`
(`go_router`) — never via a service locator. Domain/status types are sealed classes (`freezed`), not
booleans. See `lib/features/enrollment/*` for the established pattern before adding a new screen.

## Getting started

Requires Flutter (the pinned version is in `.fvmrc`; install [FVM](https://fvm.app/) or just match
that Flutter version manually) and Dart, both already satisfied if `flutter --version` matches
`.fvmrc`.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # generates *.freezed.dart, *.g.dart, l10n
flutter analyze                                              # must be zero warnings
flutter test                                                 # full suite, headless
```

### Running the app

Build-time values (backend URL, Sentry DSN and environment, dev-only flags) live in env files under
`env/`, one per launch config. Flutter reads them with `--dart-define-from-file`:

```bash
flutter run --dart-define-from-file=env/dev.env           # local backend (see below)
flutter run --dart-define-from-file=env/staging.env       # deployed backend, synthetic images only
flutter run --dart-define-from-file=env/dev-offline.env   # dev fakes, no backend needed
flutter run --dart-define-from-file=env/demo.env          # dev fakes, `demo` Sentry environment
flutter run --dart-define-from-file=env/chaos.env         # fault injection panel, `chaos` Sentry environment
flutter run --release --dart-define-from-file=env/prod.env
```

**Fault injection** (`env/chaos.env`): a ⚡ button on every screen injects network faults into
real requests (latency, timeout, lost connection, 500/503/504/401/429), requests backend faults,
and forces crashes, so the Sentry dashboards and alerts can be seen reacting. Injected failures
are tagged `fault_injected`. How to run the experiments: `specs/015-observabilidad-sentry/fault-injection.md`.
A release build refuses to start with it.

**Three flavors** (specs/015-integracion-backend/contracts/flavor-wiring.md):

| Flavor | Backend | Auth | Images sent |
|---|---|---|---|
| `dev` | a local backend in fake-adapter mode, `http://10.0.2.2:8000` | `Bearer test:<id>`, no Clerk | synthetic `MOCK:` markers only |
| `staging` | the deployed service, `https://aeropass-lac.vercel.app` | Clerk sign-in | synthetic markers only; the camera runs, its frames are never sent |
| `prod` | the deployed service | Clerk sign-in | real capture |

`tool/check_release_env.dart env/prod.env` (run in CI) refuses test auth, plain HTTP, synthetic
capture and any happy-path flag.

**Running the local backend** for the dev flavor. In the backend repository (`AirPass/Aeropass`),
start Postgres, then:

```bash
uv run alembic upgrade head
AEROPASS_ADAPTERS=fake uv run uvicorn aeropass.main:app --host 0.0.0.0 --port 8000
```

The Android emulator reaches it at `10.0.2.2:8000`. In dev and staging, 006 shows a dev-only picker.
It chooses which mock result the synthetic selfie asks for (approved, liveness failure, no match,
no answer), so screens 009, 010 and 011 can be reached against a real backend.

**The "DEMO · biometría simulada" ribbon.** The deployed biometric provider is a mock that approves
any image (015 R-01). While `BIOMETRIC_PROVIDER_MOCK` is true, which is the default in every flavor,
every screen carries the ribbon and nothing says the identity is verified or active. It can be
turned off only with a real `BIOMETRIC_PROVIDER_NAME` in the same env file.

Set `SENTRY_SEND_TEST_EVENT=true` in an env file to report one test error at startup. With no
`SENTRY_DSN`, Sentry stays off. The files hold nothing secret, since the DSN is a public client key.

### Observability (Sentry)

Spec: [`specs/015-observabilidad-sentry/`](specs/015-observabilidad-sentry/spec.md). What each env
file controls:

| Variable | Meaning |
|---|---|
| `SENTRY_DSN` | Project key for `aeropass-app`; empty turns Sentry off |
| `SENTRY_ENVIRONMENT` | `dev`, `demo` or `prod`; the dashboard and alerts filter on it |
| `SENTRY_TRACES_SAMPLE_RATE`, `SENTRY_PROFILES_SAMPLE_RATE`, `SENTRY_REPLAY_SESSION_SAMPLE_RATE`, `SENTRY_REPLAY_ON_ERROR_SAMPLE_RATE` | Sampling in [0, 1]; prod defaults 0.2 / 0.2 / 0.1 / 1.0. Errors, crashes and funnel events are always sent in full |
| `SENTRY_ALERT_RULE_CONFIRMED` | `true` only while the Sentry alert on `failure_class:service` covers that environment (011 FR-006) |

- **Privacy**: every event, trace, breadcrumb, log and metric passes through
  `lib/data/services/sentry_privacy_filter.dart`, and funnel log attributes follow an allowlist
  (`contracts/telemetry-events.md`). A new analytics payload key fails
  `test/contract/telemetry_allowlist_contract_test.dart` until it is added to the contract.
- **Before each release**: check that Session Replay masks the document, selfie, liveness,
  confirmation, credential and pass screens, QR included (`quickstart.md` §4).
- **Dashboard and alerts**: configured by hand in Sentry; the definitions and their ids are in
  `specs/015-observabilidad-sentry/contracts/dashboard-and-alerts.md`.
- **Debug symbols** for readable crash stack traces: build release with split debug info, then
  upload with `sentry_dart_plugin` (org and project come from `pubspec.yaml`; the token only from
  your environment or the CI secret, never from the repo):

```bash
flutter build apk --release --obfuscate --split-debug-info=debug-info --dart-define-from-file=env/prod.env
SENTRY_AUTH_TOKEN=<token> dart run sentry_dart_plugin
```

The VS Code launch configs in `.vscode/launch.json` pass the matching file:

- **`aeropass_app (dev, local backend)`** — debug mode, against a local backend.
- **`aeropass_app (dev, offline demo)`** — debug mode with dev fakes, offline.
- **`aeropass_app (staging)`** — debug mode, against the deployed service with synthetic images.
- **`aeropass_app (demo)`** — debug mode with dev fakes, reported to Sentry as `demo`
  (presentation data, see `specs/015-observabilidad-sentry/quickstart.md` §6).
- **`aeropass_app (prod)`** — release mode, against the deployed service.

Staging and prod sign in through Clerk's embedded sign-in widget, which asks for whatever the
Clerk instance requires. The sign-in screen comes
after consent, and "Ya tengo cuenta" opens it too. Set `CLERK_PUBLISHABLE_KEY` in the env file.
Only the publishable key (`pk_…`) goes there: a secret key (`sk_…`) must never be in the app. The
session is held in memory until constitution amendment 1.5.0 (A3) allows storing it, so a restart
means signing in again.

### Running without a backend

The **`aeropass_app (dev, offline demo)`** launch config (`env/dev-offline.env`) wires every port to
a dev fake under `lib/data/dev/`, so the whole flow can be walked with no backend. A release build
refuses its flags.

Document capture (003) additionally needs a physical device or emulator with a camera — it cannot be
exercised in a pure widget-test environment for its camera-dependent paths.

## Testing

```bash
flutter analyze                 # zero-warning gate
flutter test                    # unit + widget + contract tests
flutter test --coverage         # generates coverage/lcov.info
```

Every repository port (`CredentialRepository`, `ConsentRepository`, `DocumentVerificationRepository`,
`CaptureAttemptCounterRepository`) has a contract test suite that runs against both a fake and the
real implementation — see `test/contract/` and `specs/*/contracts/`. Trust-boundary code (identity
state, consent capture, verification outcomes) is test-first per the constitution: the test exists
and fails before the implementation does.

`test/architecture/import_boundary_test.dart` enforces the View → ViewModel → Repository → Service
import direction at test time (no `custom_lint` dependency needed for one rule).

## Project layout

```text
lib/
├── app/            # composition root, go_router config, theme, splash
├── core/            # Result<T>, Command<T>, design tokens, shared utilities
├── domain/          # entities + abstract repository ports (no Flutter import)
├── data/            # port implementations: services (network/storage/camera) + repository impls
│   └── dev/          # dev-only fakes wired behind --dart-define flags, never used in prod builds
├── features/         # one folder per screen/feature, feature-first
│   └── enrollment/
├── l10n/             # ARB source + generated localization (es default, device-locale detection)
test/
├── contract/         # repository port contract suites (fake + real)
├── unit/              # ViewModel / domain logic
├── widget/            # screen-level widget tests
├── fakes/             # shared test doubles
└── architecture/      # import-boundary enforcement
specs/                # Spec Kit: one directory per feature (spec/plan/tasks/research/contracts)
.specify/             # Spec Kit tooling + the project constitution
```

## Governance & specs

`.specify/memory/constitution.md` is binding: data minimization, the verification-provider adapter
boundary, test-first on trust-boundary code, accessibility, architecture layering, and the mandated
code patterns above all come from it. Any new feature should go through the Spec Kit flow —
`/speckit-specify` → `/speckit-clarify` → `/speckit-plan` → `/speckit-tasks` → `/speckit-implement`
— rather than being hand-written outside `specs/`, so the constitution's Constitution Check gate
actually runs against it.

## Known limitations

- **Release blockers carried by 015** (specs/015-integracion-backend/quickstart.md):
  - the biometric provider is a mock that approves any image (R-01);
  - retention has three figures and no deletion job, so screen 02's retention sentence cannot ship
    (F-03);
  - consent is recorded on the device only, so it is not auditable (DEC-02);
  - withdrawal cannot delete what the server holds;
  - constitution amendment 1.5.0 is not ratified;
  - Sentry `sendDefaultPii` is still on;
  - the Clerk instance configuration is unconfirmed.
- The pass is online-only (DEC-01). In a terminal with poor connectivity, a failed renewal leaves
  the passenger with the conventional lane.
- Document capture's on-device quality heuristics (blur/glare/framing thresholds) are tuned against
  synthetic test fixtures only, not real document photographs — see
  `specs/003-escanear-documento`'s implementation notes before relying on its accuracy targets.
- The iOS native handler for routing to system settings (used when the camera permission is
  permanently denied) has not been compiled/verified — this repository's tooling is Windows-only so
  far.
- Visual design uses plain Material 3 defaults plus hand-picked colors read off Figma screenshots —
  no generated design-token source exists yet (constitution's Development Workflow "Design fidelity"
  requirement).
