# Implementation Plan: Dynamic QR Pass (14 QR Pase)

**Branch**: `014-qr-pase` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/014-qr-pase/spec.md`

## Summary

Screen 14 is the pass the passenger shows at the checkpoint readers. It is reached from 013's
placeholder, "Continuar a tu pase", or from Mis viajes' new "Ver pase".

**How it works**:

- The screen asks the backend to issue a pass for the started trip. The QR code rotates every 30
  seconds, with a countdown and a progress arc.
- The stepper shows Seguridad and Embarque. A step completes only when the backend reports a
  reader's validation, which is polled every 5 seconds.
- After boarding, the screen shows "Abordaje confirmado · Buen viaje", and the pass is forgotten.
- Brightness is raised, the screen is kept awake, and capture is blocked while a code is shown.
- The phone's clock is checked against the backend's, with a 30-second tolerance.
- A compromised device never gets a pass, and is sent to an agent.

**"Simular expirado"** exists only behind a development flag that a release build refuses. CI also
fails if the production env enables any development flag.

**One governance gate shapes the plan.** Clarification Q1 chose codes derived on the device from a
stored secret, and constitution v1.4.0 forbids both storing a pass secret and regenerating a pass
offline. The plan therefore delivers in two phases:

- **Phase A** (now): codes are fetched per rotation from the backend. This is compliant today, and
  is the spec's allowed happy-path relaxation for offline rotation.
- **Phase B**: secure storage of the secret and on-device derivation, behind the same port. It is
  **blocked until the user ratifies** contracts/constitution-amendment-proposal.md (v1.5.0).

## Technical Context

**Language/Version**: Dart / Flutter, the same pinned stable channel as 001–012.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `json_serializable`, `dio`
(pinned), `crypto` (already present) and `flutter_secure_storage` (phase B). **One new package: `qr`**,
a pure-Dart QR encoder. It has no access to the camera, storage, network or device identifiers
(justified in research.md §3). There is also one new native channel, `aeropass/pass_display`, for
brightness, keep-awake, capture blocking and device posture.

**Storage**: phase A stores nothing new. Phase B stores one `PassSecret` in secure storage, only
after ratification.

**Testing**: `flutter_test`, `mocktail`, golden tests, plus a Dart tool test for the release gate.
Test-first on the code derivation, the clock trust, the validity states, the posture refusal and
the release gate (Principle IV).

**Target Platform**: Android 8.0 / iOS 15.0. iOS cannot block screenshots; this is recorded as a
platform limitation of FR-007.

**Project Type**: Mobile app (Flutter, feature-first). Adds one screen, four ports, a native
channel, a CI step and a tool. Changes 012's card, 013's placeholder and `HappyPathFlags`.

**Performance Goals**: the pass is legible within 2 s of opening (SC-002). Rotation happens exactly
on window boundaries, recomputed from the clock every second.

**Constraints**:

- The backend is the only authority on validity (FR-002).
- No code is shown in any unavailable state.
- There is no client-side expiry flag.
- The payload never reaches a log, event or report (FR-015).
- The dev control is absent from release builds (FR-019).

**Scale/Scope**:

- one screen with a QR painter and a stepper;
- `PassRepository` and `PassCodeSource`, each with backend, derived (B) and dev implementations;
- `PassDisplayGuard` and `DevicePostureChecker`;
- a `ClockTrustMonitor`;
- six events;
- a release-env tool and a CI step;
- a constitution amendment proposal.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

Evaluated against constitution **v1.4.0**.

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS for phase A. BLOCKED for phase B** | Phase A persists nothing. Phase B's secret storage needs the amendment (research.md §1). Its tasks are marked blocked, and none may start before ratification |
| II. The Verification Provider Is an Adapter | **PASS** | Pass issuance and status are normalized at the data boundary. An unknown state is an error, never "active" |
| III. Every Flow Has a Failure Path | **PASS** | Every unavailable reason has a forward action and the checkpoint line. The offline-rotation deferral is listed by identifier in the spec. The dev control is flag-gated and release-refused |
| IV. Test-First on the Trust Boundary | **PASS (mandatory here)** | Derivation, clock trust, validity, posture, pass mode and the release gate are tested first. The pass surface has goldens, as the constitution names |
| V. Airport-Grade Experience Constraints | **PASS for A with a recorded deferral. Full after B** | Brightness raised and restored. Countdown kept offline. Usability offline needs phase B. A cold start to a usable pass under 3 s is measured in the quickstart |
| VI. Accessibility Is a Gate | **PASS** | The countdown is text, rotation is announced, the stepper is read as text, and there is a help route for passengers who cannot present the code |
| VII. Observability Without PII | **PASS** | Events carry enums, booleans and integers. A payload-free log test is included |
| VIII. Architecture | **PASS** | The ports are domain-owned. The native channel is behind ports, and the ViewModel has no `dio` and no platform channel |
| IX. Mandated Code Patterns | **PASS for A. Offline-first after B** | Sealed `PassState`, `PassViewState` and `ClockTrust`; `Result<T>`; no optimistic validity |
| X. Craft Standards | **PASS** | One new pure-Dart dependency, justified. The 30 s, 5 s, 24 h and 30 s-tolerance values are named constants |
| Security: capture blocking | **PASS on Android; platform limitation on iOS** | Recorded in research.md §6 |
| Security: compromised device | **PASS (heuristic)** | Added as spec FR-023. Backend attestation is recommended (research.md §8) |
| Security: QR TTL, not regenerable offline | **PASS for A. B blocked** | Phase A does not regenerate offline. Phase B needs the amendment |

**Gate result**: phase A may proceed. **Phase B is blocked on ratification**; this is not an
unjustified violation, because nothing in phase B is built before then.

**Post-design re-check**: no change.

## Project Structure

### Documentation (this feature)

```text
specs/014-qr-pase/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── constitution-amendment-proposal.md   # 1.4.0 → 1.5.0, awaiting ratification
│   ├── pass-port.md                         # issuance, status, code sources
│   ├── pass-display-and-posture.md          # native channel
│   ├── release-gate.md                      # "Simular expirado" flag + CI
│   ├── pass-ui.md                           # screen, unavailable states, 012 change
│   └── analytics-events.md
├── assets/14-qr-pase.png
└── tasks.md                                 # /speckit-tasks
```

### Source Code (repository root) — additions and changes

```text
android/app/src/main/kotlin/com/aeropass/aeropass_app/MainActivity.kt   # CHANGE: aeropass/pass_display
ios/Runner/AppDelegate.swift                                            # CHANGE: brightness, idle timer, jailbreak paths
tool/check_release_env.dart                                             # NEW
.github/workflows/ci.yaml                                               # CHANGE: release env step
pubspec.yaml                                                            # CHANGE: qr
lib/
├── app/
│   ├── clock_trust_monitor.dart           # NEW
│   ├── router.dart                        # CHANGE: /trip/pass
│   └── composition_root.dart              # CHANGE: ports
├── core/happy_path_flags.dart             # CHANGE: devPassControls
├── domain/
│   ├── entities/pass.dart                 # NEW: Checkpoint, Pass, PassCode, PassState, ClockTrust, reasons
│   └── repositories/
│       ├── pass_repository.dart           # NEW
│       ├── pass_code_source.dart          # NEW
│       ├── pass_display_guard.dart        # NEW
│       ├── device_posture_checker.dart    # NEW
│       └── analytics_emitter.dart         # CHANGE: 6 methods
├── data/
│   ├── dev/dev_pass_repository.dart, dev_pass_code_source.dart, dev_device_posture_checker.dart  # NEW
│   ├── models/pass_responses.dart         # NEW DTOs
│   └── services/
│       ├── pass_service.dart, pass_repository_impl.dart     # NEW
│       ├── backend_pass_code_source.dart                    # NEW (A)
│       ├── derived_pass_code_source.dart, pass_secret_store.dart  # NEW (B, blocked)
│       └── platform_pass_display.dart                        # NEW: guard + posture
├── features/
│   ├── trip_verification_placeholder_view.dart              # CHANGE: "Continuar a tu pase"
│   ├── trips/trips_home_viewmodel.dart, widgets/next_trip_card.dart  # CHANGE: "Ver pase"
│   └── pass/
│       ├── pass_view.dart, pass_viewmodel.dart               # NEW
│       └── widgets/qr_code_painter.dart, journey_stepper.dart, rotation_ring.dart  # NEW
└── l10n/app_es.arb                        # CHANGE
test/ …                                    # contract, unit, widget, tool tests per the contracts
```

**Structure Decision**: a new `features/pass/` for the screen. The trips feature changes only its
action. The clock monitor is app-layer because the repository and the ViewModel both use it.

## Complexity Tracking

| Item | Why it is needed | Simpler alternative rejected |
|---|---|---|
| Two-phase delivery (A now, B after ratification) | Q1's design conflicts with constitution v1.4.0 | Building B now would violate Principle I and the Security clause. Dropping offline would contradict Principle V and the spec's US2 |
| A new native channel | Brightness, keep-awake and posture have no Flutter API | A package per concern would add three dependencies with device access, which the constitution requires to be reviewed |
| The `qr` dependency | A QR encoder is needed | Writing Reed–Solomon by hand |
