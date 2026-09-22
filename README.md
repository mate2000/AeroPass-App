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

Two VS Code launch configs exist in `.vscode/launch.json`:

- **`aeropass_app (dev)`** — debug mode, points at the (nonexistent) dev backend URL.
- **`aeropass_app (prod)`** — release mode, points at the (nonexistent) prod backend URL.

Both currently fail to reach a real backend — see below.

### Running without a backend

There is no backend deployed anywhere yet. Most screens handle this gracefully (e.g. the welcome
screen falls back to "last known state" when the credential check is unreachable), but the consent
gate's text is intentionally never faked or cached on a failed fetch — that's a legal/audit
requirement, not a bug (see `specs/002-consentimiento/spec.md`'s Edge Cases and
`research.md` §5). To actually see the consent gate's content without a backend, use the
**`aeropass_app (dev, offline demo)`** launch config, which sets
`--dart-define=USE_FAKE_CONSENT_BACKEND=true` and swaps in `lib/data/dev/dev_consent_repository.dart`
— an explicitly-flagged, dev-only in-memory substitute. It does not weaken the real
`ConsentRepositoryImpl`'s behavior in any build where the flag isn't set.

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

- No backend exists — every network path is currently unreachable by design (see above).
- Document capture's on-device quality heuristics (blur/glare/framing thresholds) are tuned against
  synthetic test fixtures only, not real document photographs — see
  `specs/003-escanear-documento`'s implementation notes before relying on its accuracy targets.
- The iOS native handler for routing to system settings (used when the camera permission is
  permanently denied) has not been compiled/verified — this repository's tooling is Windows-only so
  far.
- Visual design uses plain Material 3 defaults plus hand-picked colors read off Figma screenshots —
  no generated design-token source exists yet (constitution's Development Workflow "Design fidelity"
  requirement).
