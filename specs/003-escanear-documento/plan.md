# Implementation Plan: Identity Document Capture (03 Escanear documento)

**Branch**: `003-escanear-documento` | **Date**: 2026-09-21 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/003-escanear-documento/spec.md`

## Summary

The camera-based capture step gated behind a current consent record (002-consentimiento). The
passenger frames their cédula or passport, captures manually, and the image is assessed on-device
for blur/glare/framing/resolution/wrong-document before ever leaving the device. A capture that
passes is submitted to the verification processor and its outcome translated into the same
passenger-facing vocabulary as device-side rejections. A durable, device-level attempt counter (per
the constitution's freshly-amended Principle I allowlist) caps retries at 3 and routes to the retry
guidance / agent escalation stubs when exhausted. No document image is ever written to disk; this
screen deliberately does not block screenshots (spec.md FR-020/SC-004).

## Technical Context

**Language/Version**: Dart / Flutter, the same FVM-pinned stable channel (3.47.5) — no change.

**Primary Dependencies**: Reuses `provider`, `go_router`, `freezed`, `flutter_secure_storage`, `dio`
(pinned), `mocktail`. **One new dependency**: the official `camera` package (justified in
research.md §1 — no viable path to camera capture without a platform-channel plugin, and this is
the Flutter-team-maintained one). No ML/CV library is added — quality assessment is heuristic,
computed from the captured frame's raw pixel data (research.md §2).

**Storage**: `flutter_secure_storage`, extended with one new key: the capture-attempt counter
(integer count + last-reset timestamp), per the constitution's amended Principle I allowlist. No
document image, extracted data, or verification response is ever persisted.

**Testing**: `flutter_test`, `mocktail`. Principle IV applies doubly hard here — this screen decides
identity-document validity (a named trust-boundary category) AND classifies verification outcomes.

**Target Platform**: Android 8.0 / iOS 15.0 — the app-wide baseline, unchanged. Camera-specific
constraint: the `camera` plugin's own minimum platform support must be compatible with this floor
(verified in research.md §1).

**Project Type**: Mobile app (Flutter, feature-first) — extends the existing project.

**Performance Goals**: ≥95% of passengers complete the step within 45s at p90 (SC-002); on-device
quality assessment must run fast enough not to be the bottleneck (target: well under 1s per frame,
since it gates every single capture attempt, not just a one-time check).

**Constraints**: Camera permission requested only after consent exists, with an explanation, never
re-prompting after a permanent denial (FR-002/FR-014); exactly one capture processed per activation
(FR-016); image never touches disk/gallery/cache/logs/crash reports (FR-010); screenshots
deliberately NOT blocked (FR-020); camera lifecycle correctly stops on backgrounding/lock/interruption
(Edge Cases) and never shows a frozen frame as live.

**Scale/Scope**: One screen (`CaptureView`) with four presentation states (permission-gating,
live/ready, inline error, unavailable), a `DocumentQualityAssessor` port + heuristic implementation,
a `DocumentVerificationRepository` port + real/fake implementation, a `CaptureAttemptCounter` entity
+ repository. Placeholder stub routes for the destinations this feature doesn't own: data
confirmation (004), retry guidance (009), agent escalation (010), help.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS (post-amendment)** | The capture-attempt counter is now explicitly on the allowlist (v1.3.0, amended this planning session — see the constitution's Sync Impact Report). Document images/extracted data remain in-memory only, discarded on every exit path (FR-010) — the strictest reading of Principle I's raw-artifact rule, extended here to a *new* raw-artifact type (document images) exactly as it already covers selfie frames and liveness video. |
| II. The Verification Provider Is an Adapter | **PASS** | `DocumentVerificationRepository` is the adapter boundary: no provider SDK type, DTO, or error taxonomy crosses into `CaptureViewModel`. The fake implementation drives the full contract test suite with no network. |
| III. Every Flow Has a Failure Path | **PASS** | States: permission-gating (loading → granted/denied), capture (idle → assessing → device-rejected/verification-pending → verification-rejected/accepted), each with a named recovery (retry, settings route, agent escalation) — never a snackbar for these. |
| IV. Test-First on the Trust Boundary | **PASS (governs task ordering)** | Both the on-device quality classification and the verification-outcome translation are trust-boundary decisions per Principle IV's own examples ("classification of a verification outcome"). Contract tests for `DocumentVerificationRepository`, unit tests for `DocumentQualityAssessor` and `CaptureViewModel`, written first. |
| V. Airport-Grade Experience Constraints | **PASS** | Torch reachable one-handed (FR-005); primary actions in reach; this screen is the one place in the app where full offline operation is *not* required (FR-015 blocks submission offline, consistent with 002's precedent that recording/submitting sensitive operations requires connectivity) — the camera preview itself still works offline, only submission is gated. |
| VI. Accessibility Is a Gate, Not a Polish Pass | **PASS** | FR-007's "text and iconography, never color alone" for error states; the screen-reader/framing edge case is handled by FR-017's alternative agent-path route rather than an inaccessible camera UI pretending to be usable. |
| VII. Observability Without PII | **PASS** | FR-018's funnel events are keyed to the existing ephemeral `AnalyticsSessionId`, never the durable `EnrollmentAttemptId` or any image/extracted data. |
| VIII. Architecture Follows the Flutter App Architecture Guide | **PASS** | `features/enrollment/capture/`; `DocumentQualityAssessor`, `DocumentVerificationRepository`, `CaptureAttemptCounter`'s repository all live under `domain/`/`data/` since none are feature-private (a future retry-guidance feature will read the attempt counter too). |
| IX. Mandated Code Patterns | **PASS** | `Result<T>` from repository methods; capture/retry/torch-toggle exposed as `Command`s; `CaptureOutcome`/`QualityRejectionReason` are sealed types, not booleans; constructor injection; no optimistic state — the step indicator only marks "document done" after a real `Ok` from submission. |
| X. Craft Standards Apply to Every Line | **PASS (enforced at review)** | Comparable scope to prior features; no anticipated violations. |

No unresolved gate failures. No Complexity Tracking entries required — the one real conflict
(capture-attempt counter persistence) was resolved via constitution amendment before this table was
written, not worked around silently.

## Project Structure

### Documentation (this feature)

```text
specs/003-escanear-documento/
├── plan.md              # This file (/speckit-plan command output)
├── research.md          # Phase 0 output (/speckit-plan command)
├── data-model.md        # Phase 1 output (/speckit-plan command)
├── quickstart.md        # Phase 1 output (/speckit-plan command)
├── contracts/           # Phase 1 output (/speckit-plan command)
│   ├── document-verification-port.md
│   ├── quality-assessor-port.md
│   └── analytics-events.md
└── tasks.md             # Phase 2 output (/speckit-tasks command - NOT created by /speckit-plan)
```

### Source Code (repository root) — additions/changes to the existing project

```text
lib/
├── app/
│   └── router.dart                             # CHANGE: replace document-capture placeholder's
│                                                #   builder with the real CaptureView; consent-
│                                                #   currency guard (FR-001) in _redirect; add
│                                                #   retry-guidance/agent-escalation/help/data-
│                                                #   confirmation placeholder routes
├── domain/
│   ├── entities/
│   │   ├── capture_outcome.dart                 # NEW: sealed CaptureOutcome, QualityRejectionReason
│   │   └── capture_attempt_counter.dart         # NEW: CaptureAttemptCounter (count, lastResetAt)
│   └── repositories/
│       ├── document_verification_repository.dart  # NEW: abstract port
│       ├── document_quality_assessor.dart          # NEW: abstract port (on-device, no network)
│       └── capture_attempt_counter_repository.dart # NEW: abstract port
├── data/
│   └── services/
│       ├── document_verification_service.dart      # NEW: dio (pinned) submission call
│       ├── document_verification_repository_impl.dart  # NEW
│       ├── heuristic_quality_assessor.dart          # NEW: blur/glare/framing/resolution heuristics
│       ├── camera_capture_service.dart              # NEW: wraps the `camera` plugin
│       └── capture_attempt_counter_service.dart     # NEW: flutter_secure_storage-backed
└── features/
    └── enrollment/
        └── capture/
            ├── capture_view.dart                 # NEW: replaces the 002-era placeholder at the route
            ├── capture_viewmodel.dart             # NEW
            ├── widgets/                            # NEW: viewfinder_overlay, torch_toggle,
            │                                        #   capture_button, inline_error_message,
            │                                        #   permission_denied_message, step_indicator
            └── document_confirmation_placeholder_view.dart  # NEW: 004 stub (success destination)

lib/features/
├── retry_guidance_placeholder_view.dart          # NEW: 009 stub
└── agent_escalation_placeholder_view.dart        # NEW: 010 stub

test/
├── contract/
│   ├── document_verification_repository_contract_test.dart  # NEW: fake AND real
│   └── capture_attempt_counter_repository_contract_test.dart  # NEW: fake AND real
├── unit/
│   ├── capture_viewmodel_test.dart
│   └── heuristic_quality_assessor_test.dart
└── widget/
    └── capture_view_test.dart
```

**Structure Decision**: Same feature-first layout. `DocumentVerificationRepository`,
`DocumentQualityAssessor`, and `CaptureAttemptCounterRepository` live under `domain/`/`data/` as
shared ports (not `capture`-private) since the attempt counter in particular will be read by a
future retry-guidance feature. The capture *screen* is feature-private under
`features/enrollment/capture/`.

## Complexity Tracking

*No entries — the Constitution Check passes with no unjustified violations after the constitution
amendment resolved the one real conflict.*
