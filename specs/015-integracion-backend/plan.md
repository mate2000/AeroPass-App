# Implementation Plan: Backend Integration (015)

**Branch**: `015-integracion-backend` | **Date**: 2026-09-23 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/015-integracion-backend/spec.md`

**Review gate (DEC-04)**: this plan and its contracts are the review artifact. No client code is
written until the plan is reviewed and amendment 1.5.0 is ratified or rejected.

## Summary

Replace the app's invented backend contract with the real one. The app's data layer targets 17 paths
on a host that does not exist. The real service has five endpoints.

**Approach**: keep the domain ports that 001–014 built, and swap their release implementations.
Each port ends up in one of three states:

- **backend**: a new implementation over the real API. This covers registration, `/me`,
  verification and the pass.
- **local**: an implementation that makes no network call. This covers consent, document capture
  and liveness samples.
- **not wired**: the screen shows its release variant. This covers escalation chat, the service
  status card, trips and field re-verification.

Every old network implementation is deleted. Its dev fake stays, per spec Q3.

Three pieces are new:

- **A session layer**: a silent Clerk sign-up, and one token per call.
- **A `VerificationSubmission` broker**: it lets 007's polling UI sit on a synchronous call.
- **A token-renewal pass**: it replaces 014's per-window code fetch.

Around those, the plan adds:

- flavors named dev, staging and prod;
- synthetic marker images generated in code;
- a permanent "DEMO · biometría simulada" ribbon;
- trust-anchor TLS pinning, which is correct for the first time;
- a release-wiring test that proves prod calls only the five real paths.

## Technical Context

- **Language/Version**: Dart 3.13 / Flutter stable (unchanged).
- **Primary Dependencies**:
  - existing: `dio` 5, `flutter_secure_storage` 11, `go_router` 18, `provider`, `freezed`,
    `json_serializable`, `camera`, `sentry_flutter` 9, `qr` 4;
  - **new**: `clerk_auth` (beta, publisher clerk.com; justified in research.md §2).
- **Storage**: secure storage only, per data-model.md "Persisted state".
- **Testing**:
  - `flutter_test` and `mocktail`;
  - contract tests replaying JSON fixtures copied from the backend schemas;
  - an architecture test over the prod composition, with a recording `HttpClientAdapter`;
  - no live-network tests in CI. The staging walk is manual (quickstart S).
- **Target Platform**: Android (the minimum-spec device) and iOS.
- **Project Type**: mobile app. The backend is a separate repository, and it is not changed.
- **Performance Goals**:
  - pass request to displayed code: p90 under 2 s on 4G (amendment A1);
  - renewal: at 40 s, before expiry in at least 99% of connected sessions (SC-005).
- **Constraints**:
  - online-only pass (DEC-01);
  - images of 4 MB or less, with the content type matching the bytes;
  - a fresh token per call;
  - no scores, `mensaje` or tokens outside the data layer.
- **Scale/Scope**:
  - 5 endpoints;
  - about 15 ports rewired;
  - about 11 services and their implementations deleted;
  - 5 screens with visible changes: 004 form, 008 wording, 010 release variant, 012 flight entry,
    014 renewal and stepper;
  - a ribbon on all screens.

There are no open NEEDS CLARIFICATION items. Research resolved every unknown. Two items are external
confirmations, tracked under Gates:

- the Clerk instance configuration;
- whether `clerk_auth` accepts an injected HTTP client.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

Evaluated against constitution **v1.4.0**, with the 1.5.0 proposal
([contracts/constitution-amendment-proposal.md](./contracts/constitution-amendment-proposal.md)).

| Principle | Status | Notes |
|---|---|---|
| I. Consent and Data Minimization | **PASS with A3 pending; one unmet clause** | Images stay in memory and are dropped after the response. Only the display subset is persisted. The Clerk session needs A3, so it is not written before ratification. **Unmet**: withdrawal cannot reach server data (research.md §14). It is recorded as a release blocker, and not claimed |
| II. The Verification Provider Is an Adapter | **PASS** | Every backend shape is mapped at the service boundary. The liveness reason is erased to `generic` in the mapper. Unknown codes → the generic path, never success |
| III. Every Flow Has a Failure Path | **PASS** | Every documented code has a row in outcome-mapping.md, and SC-004 is enforced by iterating over the enum. Deferrals are listed by identifier in the spec |
| IV. Test-First on the Trust Boundary | **PASS (mandatory)** | These are written before their implementations: contract fixtures, the outcome and wording map, pass renewal and expiry, the 401 retry, the release wiring, and no-token-in-logs |
| V. Airport-Grade Experience | **VIOLATION pending A1** | Online-only pass, and the cold-start budget redefined (DEC-01, research.md §17). Justified below |
| VI. Accessibility | **PASS** | The ribbon has a Semantics label. The 004 form fields are labeled, and errors are announced. The pass countdown stays text |
| VII. Observability Without PII | **PASS** | No logging interceptor. `mensaje` is never parsed. `beforeSend` and `beforeBreadcrumb` strip requests and http breadcrumbs. `sendDefaultPii` is still true and is an inherited release gate |
| VIII. Architecture | **PASS** | The ports stay domain-owned. The broker lives in `lib/app/`. ViewModels get optional ports. The import-boundary tests are extended to the new services |
| IX. Mandated Code Patterns | **VIOLATION pending A2** | "Offline-first for the issued pass" is replaced by server-first. Every other pattern holds: sealed outcomes, `Result<T>`, no optimistic identity state |
| X. Craft Standards | **PASS** | One new dependency, justified. Named constants: 35 s verification timeout, 5 s status poll, 4 MB image limit, flight regex |
| Budgets: agent path with context | **SHORTFALL (recorded)** | In release, 010 has no backend. It points to the lane and carries no context (research.md §17) |
| Security: secure storage | **PASS** | A custom `Persistor` puts Clerk's session in secure storage, not `clerk_auth`'s default file |
| Security: TLS pinning, fail-closed | **PASS (root anchors)** | The first real pinning in the app (research.md §4). It is weaker than leaf pinning, and recorded below. The Clerk host's pinning depends on HTTP client injection |
| Security: QR TTL, not regenerable offline | **PASS** | Nothing is derived on the device. The TTL is server-defined, from 30 to 60 s |
| Security: third-party dependency review | **PASS** | `clerk_auth` was reviewed for network, storage and logging (research.md §2) |
| Workflow: flavors dev, staging and prod | **PASS** | `env/staging.env` is the spec's "integration". The publishable key is not a credential |

**Gate result**: **PROCEED to tasks, but implementation is gated.**

- Tasks touching the pass lifecycle (A1, A2) or storing the Clerk session (A3) are marked
  **blocked on ratification**.
- Everything else may proceed after DEC-04 review:
  - contract, DTOs and errors;
  - registration;
  - verification;
  - wording;
  - the ribbon;
  - flavors and the release check;
  - deletions.
- Dev-flavor auth needs no A3, because the test id is dev-only.

**Post-design re-check**: unchanged. The design added no new violation. It surfaced the withdrawal
gap, recorded under I, and the context shortfall, recorded under Budgets.

## Project Structure

### Documentation (this feature)

```text
specs/015-integracion-backend/
├── spec.md
├── plan.md                                   # this file
├── research.md                               # §1–§17
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── verification-record.md                # input audit trail (D-, R-, F- registers)
│   ├── backend-api.md                        # the five endpoints, as consumed
│   ├── outcome-mapping.md                    # backend → state → passenger wording
│   ├── flavor-wiring.md                      # env keys, release check, port wiring per flavor
│   └── constitution-amendment-proposal.md    # 1.4.0 → 1.5.0 (A1–A4); supersedes 014's
├── checklists/requirements.md
└── tasks.md                                  # /speckit-tasks
```

### Source Code (repository root): additions, changes and deletions

```text
env/dev.env                          # CHANGE: local backend, AUTH_MODE=test, SYNTHETIC_CAPTURE, mock
env/staging.env                      # NEW
env/prod.env                         # CHANGE: aeropass-lac.vercel.app, clerk, mock=true
tool/check_release_env.dart          # CHANGE: rules from flavor-wiring.md
pubspec.yaml                         # CHANGE: clerk_auth; assets/tls/
assets/tls/gts-root-r1..r4.pem, README.md       # NEW (public GTS roots; research.md §4)
lib/
├── core/happy_path_flags.dart       # CHANGE: new flags and assertReleaseSafe
├── core/design/app_colors.dart      # CHANGE: demoRibbon tokens
├── app/
│   ├── composition_root.dart        # CHANGE: wiring per flavor-wiring.md
│   ├── verification_submission.dart # NEW: in-memory broker (research.md §7)
│   ├── demo_ribbon.dart             # NEW: MaterialApp.builder overlay (FR-020)
│   └── router.dart                  # CHANGE: resume from /me; 012 entry → /trip/pass
├── domain/
│   ├── entities/                    # NEW: backend_error, passenger_record, registration_form,
│   │                                #   registration_outcome, verification_result, flight_code,
│   │                                #   session_state
│   │                                # CHANGE: pass.dart (token model, boarded)
│   └── repositories/                # NEW: session_token_provider.dart, passenger_repository.dart
│                                    # CHANGE: pass_repository.dart (issue(FlightCode))
├── data/
│   ├── models/backend/              # NEW: five DTOs, plus TransicionDto
│   ├── auth/                        # NEW: clerk_session_token_provider, secure_clerk_persistor,
│   │                                #   test_session_token_provider, auth_interceptor
│   ├── services/
│   │   ├── pinned_dio_factory.dart  # CHANGE: trust-anchor SecurityContext
│   │   ├── backend_error_mapper.dart            # NEW
│   │   ├── passenger_service.dart               # NEW: /v1/identity, /v1/identity/me
│   │   ├── biometric_service.dart               # NEW: /v1/biometrics/verifications
│   │   ├── pass_service.dart                    # CHANGE: POST /v1/passes {codigo_vuelo}, GET detail
│   │   ├── backend_identity_record_repository.dart
│   │   ├── passenger_backed_credential_repository.dart
│   │   ├── submission_backed_job_repository.dart
│   │   ├── backend_pass_repository.dart
│   │   ├── issued_token_pass_code_source.dart
│   │   ├── local_consent_repository.dart
│   │   ├── local_document_capture_repository.dart
│   │   └── local_liveness_repository.dart
│   ├── dev/synthetic_image_source.dart          # NEW: MOCK: marker JPEGs (research.md §6)
│   └── DELETED: document_verification_service, field_reverification_service,
│       identity_record_service, liveness_verification_service, verification_job_service,
│       credential_issuance_service, escalation_service, agent_chat_service,
│       service_status_service, trip_service, backend_pass_code_source, and their *_impl
│       wrappers (flavor-wiring.md)
└── features/
    ├── enrollment/confirmation/     # CHANGE: typed form (FR-002a, FR-022), masked number
    ├── enrollment/liveness/         # CHANGE (006): one still to the broker; dev marker picker
    ├── enrollment/credential_activated/  # CHANGE (008): "Registro completado" under the mock
    ├── enrollment/escalation/       # CHANGE: release variant with no chat
    ├── enrollment/technical_error/  # CHANGE: optional status card; retryAfter countdown
    ├── account/                     # CHANGE: withdrawal copy (research.md §14)
    ├── trips/                       # CHANGE: flight-code entry, "REGISTRADO" badge
    └── pass/                        # CHANGE: renewal loop, Embarque-only stepper, boarded
test/
├── fixtures/backend/*.json          # NEW: one per schema and error
├── contract/backend_api_contract_test.dart      # NEW
├── architecture/release_wiring_test.dart        # NEW
├── unit/outcome_wording_test.dart, backend_error_mapping_test.dart,
│   no_token_in_logs_test.dart, verification_submission_test.dart,
│   flight_code_test.dart, registration_form_test.dart,
│   auth_interceptor_test.dart, backend_pass_repository_test.dart   # NEW
└── (deleted tests for deleted services; existing ViewModel tests updated)
```

**Structure Decision**: the existing feature-first MVVM layout. New network code goes in
`lib/data/services/` and `lib/data/auth/`, and new ports in `lib/domain/repositories/`. The
single cross-screen state is `VerificationSubmission`, which goes in `lib/app/`, next to the other
session controllers.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|---|---|---|
| Principle V: the pass is online-only, and the cold-start budget is redefined (A1) | The backend's TTL is 30–60 s, enforced by a database CHECK, and it has no offline derivation. DEC-01 accepts it | Offline derivation needs a backend change (out of scope) and was the withdrawn 014 amendment |
| Principle IX: server-first pass (A2) | This follows from DEC-01. Local state cannot be the source of truth for a 45 s credential | Caching the token past `expira_at` would display an invalid pass, which breaks the zero-false-accept budget |
| Root-anchor pinning instead of leaf pinning | Vercel rotates leaf certificates and controls the intermediates. A leaf pin would brick the app on rotation | No pinning violates the Security clause. A custom domain with a controlled certificate is recommended before an airport pilot |
| A beta dependency (`clerk_auth`) | The backend authenticates Clerk sessions only | A hand-rolled Clerk Frontend API client means owning session rotation. The port keeps the swap cheap |
| Withdrawal does not delete server data | No backend endpoint exists | Claiming deletion would be false under Ley 1581. It is recorded as a release blocker |

## Gates before implementation

**Status on 2026-09-23**:

| Gate | Status |
|---|---|
| 1 | Taken as given by the user's `/speckit-implement` invocation |
| 2 | **Open**. The ⛔ tasks stay blocked |
| 3 | **Open**. This is on the user's side |
| 4 | **Confirmed** (research.md §2) |

1. **DEC-04**: the plan and contracts are reviewed.
2. **Amendment 1.5.0** (A1–A4) is ratified or rejected. A rejection of A1 or A2 blocks the pass
   tasks. A rejection of A3 blocks signed-in staging and prod builds.
3. **Clerk instance** configured for silent username sign-up, confirmed with a manual sign-up
   against it.
4. **`clerk_auth` HTTP-client injection** confirmed. If it is unavailable, the Clerk host is
   recorded as unpinned in Complexity Tracking.
