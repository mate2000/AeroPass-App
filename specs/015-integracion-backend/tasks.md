---
description: "Task list for 015 Backend Integration"
---

# Tasks: Backend Integration (015)

**Input**: Design documents from `specs/015-integracion-backend/`, namely:

- plan.md
- spec.md
- research.md
- data-model.md
- contracts/
- quickstart.md

**Tests**: required.

- Constitution Principle IV makes test-first mandatory on the trust boundary.
- FR-019 and SC-001 to SC-004 are test-defined.
- Each test task is written first and must fail before its implementation task starts.

**Organization**: tasks are grouped by user story (spec.md):

| Story | Priority | Subject |
|---|---|---|
| US1 | P1 | The app speaks the real contract |
| US2 | P1 | Outcomes are translated, never echoed |
| US3 | P1 | The pass renews, and says when it cannot |
| US4 | P2 | Flight-code entry |

**Blocked markers**: a task tagged **⛔A1/A2** or **⛔A3** must not start until that part of
amendment 1.5.0 is ratified
([contracts/constitution-amendment-proposal.md](./contracts/constitution-amendment-proposal.md)).
If a part is rejected, its tasks are dropped and the spec is revisited.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: can run in parallel, because it touches different files and depends on nothing
  incomplete.
- **[Story]**: US1–US4. Setup, Foundational and Polish tasks carry no story label.

---

## Phase 0: Gates (plan.md "Gates before implementation")

No code task starts before T001. Nothing marked ⛔ starts before T002.

- [X] T001 DEC-04 review of plan.md and contracts/: record the reviewer and date in the Gates section of specs/015-integracion-backend/plan.md
- [ ] T002 Ratify or reject amendment 1.5.0:
  - A1–A4 per specs/015-integracion-backend/contracts/constitution-amendment-proposal.md;
  - on ratification, edit .specify/memory/constitution.md, bump the version to 1.5.0, and update the Sync Impact Report;
  - mark specs/014-qr-pase/contracts/constitution-amendment-proposal.md as withdrawn.
- [ ] T003 Confirm the Clerk instance allows a username-and-password sign-up with no email, no phone and no bot challenge. Do one manual sign-up, and record the result in specs/015-integracion-backend/research.md §2
- [X] T004 Confirm `clerk_auth` accepts an injected HTTP client (see its `ClerkHttpClient` or `Auth` constructor). Record the result in specs/015-integracion-backend/research.md §2. If it does not, add "Clerk host unpinned" to Complexity Tracking in plan.md

---

## Phase 1: Setup

- [X] T005 Add `clerk_auth` and declare `assets/tls/` in pubspec.yaml. Run `flutter pub get`
- [X] T006 [P] Add the public trust-anchor PEMs, with their source URL and SHA-256 in assets/tls/README.md. The deployed chains end in Google Trust Services, not ISRG as first planned, so these are the four GTS roots: assets/tls/gts-root-r1.pem to gts-root-r4.pem (research.md §4)
- [X] T007 [P] Rewrite the env files per contracts/flavor-wiring.md:
  - env/dev.env: `http://10.0.2.2:8000`, `AUTH_MODE=test`, `ALLOW_INSECURE_LOCAL_BACKEND=true`, `SYNTHETIC_CAPTURE=true`, `BIOMETRIC_PROVIDER_MOCK=true`;
  - env/staging.env: new;
  - env/prod.env: `https://aeropass-lac.vercel.app`, `AUTH_MODE=clerk`, the `CLERK_PUBLISHABLE_KEY` placeholder, `BIOMETRIC_PROVIDER_MOCK=true`;
  - leave env/dev-offline.env unchanged.
- [X] T008 [P] Add the launch configs "dev (local backend)" and "staging" to .vscode/launch.json, using --dart-define-from-file
- [X] T009 [P] Copy the backend response shapes into JSON fixtures under test/fixtures/backend/:
  - one fixture per schema: PasajeroResponse, ResultadoVerificacionResponse (EXITOSO, FALLIDO/LIVENESS, FALLIDO/COMPARACION, NO_CONCLUYENTE), PaseResponse, DetallePaseResponse (ACTIVA, CONSUMIDA, REVOCADA);
  - one fixture per error code in contracts/backend-api.md;
  - take the shapes from AirPass/Aeropass/src/aeropass/api/schemas.py and domain/errors.py;
  - record the source commit in test/fixtures/backend/README.md.

---

## Phase 2: Foundational (blocks every story)

### Tests first

- [X] T010 [P] Extend the release-check test in test/unit/release_env_check_test.dart. The check must fail on each of these in prod:
  - `ALLOW_INSECURE_LOCAL_BACKEND`;
  - `SYNTHETIC_CAPTURE`;
  - `AUTH_MODE=test`;
  - a missing `CLERK_PUBLISHABLE_KEY` with `AUTH_MODE=clerk`;
  - an `http://` or `.example` `API_BASE_URL`;
  - `BIOMETRIC_PROVIDER_MOCK=false` without a non-`mock` `BIOMETRIC_PROVIDER_NAME`.

  It must pass on the new env/prod.env.
- [X] T011 [P] Extend the flag test in test/unit/happy_path_flags_test.dart: `assertReleaseSafe` lists `ALLOW_INSECURE_LOCAL_BACKEND`, `SYNTHETIC_CAPTURE` and test auth
- [X] T012 [P] Write the error-mapping test in test/unit/backend_error_mapper_test.dart. It covers every fixture error, the Retry-After parse, `detalles.campos`, and an unparseable body → `unknown`. It asserts that `mensaje` is never stored
- [X] T013 [P] Write the auth-interceptor test in test/unit/auth_interceptor_test.dart:
  - a fresh token is requested per request, with no caching;
  - a 401 re-establishes the session and retries once;
  - a second 401 → `AuthFailure`;
  - `/.well-known/*` gets no header;
  - no interceptor logs the header.
- [X] T014 [P] Write the pinning test in test/unit/pinned_dio_factory_test.dart:
  - the `SecurityContext` is built with no default roots, only the bundled anchors;
  - `badCertificateCallback` always returns false;
  - dev's insecure HTTP is allowed only with its flag.

### Implementation

- [X] T015 Add the flags `allowInsecureLocalBackend`, `syntheticCapture`, `biometricProviderMock`, `authMode` and `apiBaseUrl` to lib/core/happy_path_flags.dart, and extend `assertReleaseSafe` (makes T011 pass)
- [X] T016 Extend tool/check_release_env.dart with the flavor-wiring.md rules (makes T010 pass)
- [X] T017 [P] Create the `BackendError` and `BackendErrorCode` entities in lib/domain/entities/backend_error.dart (freezed; data-model.md)
- [X] T018 [P] Create the DTOs in lib/data/models/backend/:
  - pasajero_dto.dart
  - resultado_verificacion_dto.dart
  - pase_dto.dart
  - detalle_pase_dto.dart (with TransicionDto)
  - error_dto.dart

  Use `@JsonSerializable(checked: true)`, and `@JsonEnum` with no unknown fallback. `ErrorDto` has no `mensaje` field. Run build_runner.
- [X] T019 Create lib/data/services/backend_error_mapper.dart, mapping a `DioException` with a response to `BackendError`, and one without to `TransportFailure` (reuse transport_error_mapper.dart). This makes T012 pass
- [X] T020 [P] Create the `SessionTokenProvider` port in lib/domain/repositories/session_token_provider.dart and the `SessionState` entity in lib/domain/entities/session_state.dart:
  - `token()` returns `Result<String>`;
  - `reestablish()`.
- [X] T021 [P] Create lib/data/auth/test_session_token_provider.dart for dev only. It keeps one random id per install in secure storage and returns `test:<id>`
- [X] T022 Create lib/data/auth/auth_interceptor.dart, following the fresh-token and single-retry rules in contracts/backend-api.md Transport (makes T013 pass)
- [X] T023 Rewrite lib/data/services/pinned_dio_factory.dart to use a trust-anchor `SecurityContext` loaded from assets/tls/, with `badCertificateCallback` returning false, dev's insecure branch behind its flag, and per-call timeout options (makes T014 pass)
- [ ] T024 ⛔A3 Create lib/data/auth/secure_clerk_persistor.dart, a `clerk_auth` `Persistor` over flutter_secure_storage, and lib/data/auth/clerk_session_token_provider.dart:
  - sign up once with a random `ap_…` username and a 32-byte password;
  - discard the password;
  - get a token per call through `clerk_auth`;
  - test it in test/unit/clerk_session_token_provider_test.dart with a fake Clerk client.
- [X] T025 Restructure lib/app/composition_root.dart so it picks implementations by flavor, per the contracts/flavor-wiring.md table:
  - build `Dio` with `AuthInterceptor` and `SessionTokenProvider` (dev: test provider; staging and prod: Clerk, once T024 lands);
  - optional ports are null where the table says "not wired";
  - the dev-offline path is unchanged.

  *Done:* until T024, staging and prod get `UnavailableSessionTokenProvider`. Every call then fails as `SessionUnavailable`, and no Clerk user is created. `main()` loads the trust anchors before the first frame.

**Checkpoint**: the app builds in all four configurations and the existing suite passes.

---

## Phase 3: User Story 1 — The app speaks the real contract (P1) 🎯 MVP

**Goal**: registration, resume and verification work against the real API in dev and staging.

**Independent test**: quickstart D-1 to D-3 and D-7 against the local backend. The contract test
passes on every fixture and fails when a fixture key is renamed.

### Tests first

- [X] T026 [P] [US1] Write the contract test in test/contract/backend_api_contract_test.dart. It covers:
  - every fixture parses;
  - renaming any key, or changing any enum value, in a copy fails with that field's name;
  - multipart builders produce exactly the five parts and `image/jpeg` part types;
  - the flight-code JSON body.
- [X] T027 [P] [US1] Write the form test in test/unit/registration_form_test.dart. It covers the FR-022 rules (name 2–200 characters after collapsing whitespace; number 4–20 of `[A-Z0-9]` after removing separators; expiry today or later), the three document types, and that the form is cleared after `Registered`
- [X] T028 [P] [US1] Write the repository test in test/unit/backend_identity_record_repository_test.dart:
  - 201 and 200 → `Registered`;
  - each 409, 413, 415, 422 and 503 → its outcome from contracts/outcome-mapping.md;
  - a photo over 4 MB → `RecaptureDocument` with no request sent;
  - only the name and masked number are persisted.
- [X] T029 [P] [US1] Write the credential test in test/unit/passenger_backed_credential_repository_test.dart, covering the research.md §9 table, including `VERIFICADO` with a null `identidad_id`
- [X] T030 [P] [US1] Write the broker test in test/unit/verification_submission_test.dart:
  - `idle → inFlight → done/failed`;
  - `submit` is rejected unless the state is idle;
  - the bytes are released when leaving inFlight;
  - `SubmissionBackedJobRepository` reports processing, then 007's terminal status.
- [X] T031 [P] [US1] Write the synthetic-image test in test/unit/synthetic_image_source_test.dart:
  - it produces bytes starting `FF D8 FF` that carry `MOCK:<marker>` for ok, spoof, other, timeout and documento;
  - it is unreachable when `SYNTHETIC_CAPTURE` is false.
- [X] T032 [P] [US1] Write the release-wiring test in test/architecture/release_wiring_test.dart. It builds the prod composition with a recording `HttpClientAdapter`, drives welcome → pass with fakes behind the adapter, and asserts that every requested path is one of the five real ones (FR-025)

### Implementation

- [X] T033 [P] [US1] Create the `PassengerRecord`, `DocumentType`, `PassengerState`, `RegistrationForm`, `RegistrationField` and `RegistrationOutcome` entities in lib/domain/entities/, one file each per data-model.md (makes T027 pass)
- [X] T034 [P] [US1] Create the `PassengerRepository` port (`me()`, `register(form, photo)`) in lib/domain/repositories/passenger_repository.dart
- [X] T035 [US1] Create lib/data/services/passenger_service.dart:
  - multipart `POST /v1/identity` with `foto_documento` as `MultipartFile.fromBytes(..., filename: 'documento.jpg', contentType: MediaType('image','jpeg'))`;
  - `GET /v1/identity/me`.
- [X] T036 [US1] Create lib/data/services/biometric_service.dart: a multipart `selfie` upload to `POST /v1/biometrics/verifications`, with a 35 s receive timeout
- [X] T037 [US1] Create lib/data/services/backend_identity_record_repository.dart, implementing `IdentityRecordRepository` and `PassengerRepository.register` over `PassengerService` (makes T028 pass)
- [X] T038 [US1] Create lib/data/services/passenger_backed_credential_repository.dart, implementing `CredentialRepository` and `CredentialSummaryRepository` over `/me` (makes T029 pass)
- [X] T039 [P] [US1] Create lib/data/services/local_document_capture_repository.dart: it holds the JPEG in memory, applies `HeuristicQualityAssessor`, and returns accepted with empty extraction (research.md §8)
- [X] T040 [US1] Rework 004 as a typed form:
  - lib/features/enrollment/confirmation/document_confirmation_viewmodel.dart;
  - lib/features/enrollment/confirmation/document_confirmation_view_state.dart;
  - lib/features/enrollment/confirmation/document_confirmation_view.dart.

  The form has a CC/CE/Pasaporte choice, a name field, a number field and an expiry date picker, with local validation and the line "Revisa que los datos coincidan con tu documento". After `Registered` it shows the masked number verbatim. The field-reverification entry is hidden when its port is null. Update test/unit/document_confirmation_viewmodel_test.dart and the widget tests.
- [X] T041 [US1] Create lib/app/verification_submission.dart, the broker, and lib/data/services/submission_backed_job_repository.dart, the adapter (makes T030 pass)
- [X] T042 [P] [US1] Create lib/data/services/local_liveness_repository.dart: it accepts samples locally and sends nothing
- [X] T043 [US1] Change 006: when the challenge completes, take one JPEG still and call `VerificationSubmission.submit`. This touches lib/features/enrollment/liveness/liveness_capture_viewmodel.dart. Update test/unit/liveness_capture_viewmodel_test.dart
- [X] T044 [P] [US1] Create lib/data/dev/synthetic_image_source.dart (makes T031 pass). Add a dev-only marker picker to 006 and to 003, under `if (HappyPathFlags.syntheticCapture)`, in lib/features/enrollment/liveness/liveness_capture_view.dart and lib/features/enrollment/capture/capture_view.dart
- [X] T045 [US1] Make launch resume read `/me`: 404 → welcome, `PENDIENTE_VERIFICACION` → the selfie step, `VERIFICADO` → Mis viajes, `REQUIERE_REVISION_MANUAL` → 010 (FR-023). This touches lib/app/router.dart and lib/app/splash_view.dart. Update test/widget/router_test.dart
- [X] T046 [US1] Change 008 so its release path re-reads `/me` instead of `CredentialIssuanceRepository`, which is null in release. This touches lib/features/enrollment/credential_activated/credential_activated_viewmodel.dart. Update its test
- [X] T047 [US1] Wire US1's ports in lib/app/composition_root.dart for dev, staging and prod (makes T032 pass for the enrollment half)
- [X] T048 [US1] Delete the services and wrappers for nonexistent paths, keeping the ports and dev fakes. The list is in contracts/flavor-wiring.md "Classes deleted":
  - lib/data/services/document_verification_service.dart and document_verification_repository_impl.dart;
  - field_reverification_service.dart and field_reverification_repository_impl.dart;
  - identity_record_service.dart and identity_record_repository_impl.dart;
  - liveness_verification_service.dart and liveness_verification_repository_impl.dart;
  - verification_job_service.dart and verification_job_repository_impl.dart;
  - credential_issuance_service.dart and credential_issuance_repository_impl.dart;
  - consent_service.dart's network methods;
  - escalation_service.dart and escalation_repository_impl.dart;
  - agent_chat_service.dart and agent_chat_repository_impl.dart;
  - service_status_service.dart and service_status_repository_impl.dart;
  - trip_service.dart and trip_repository_impl.dart;
  - their DTOs under lib/data/models/ and their contract tests under test/contract/.

  `flutter analyze` must be clean afterwards.

**Checkpoint**: quickstart D-1 to D-3, D-7, D-11 and D-12 pass against the local backend. T026 and
T032 are green.

---

## Phase 4: User Story 2 — Outcomes are translated, never echoed (P1)

**Goal**: no score, enum name or `mensaje` reaches a screen or a log. `LIVENESS` reads as generic.
The mock is visible everywhere.

**Independent test**: quickstart D-4 to D-6 with markers. The two generic texts are identical. The
wording, error-mapping and no-token tests are green.

### Tests first

- [X] T049 [P] [US2] Write the wording test in test/unit/outcome_wording_test.dart. It renders every row of contracts/outcome-mapping.md, and asserts that no `BackendErrorCode` name, no `ResultadoIntento`, `MotivoFallo` or `EstadoPasajero` value, no digit-dot-digit score and no fixture `mensaje` appears. It also asserts that rows 6 and 7 are identical
- [X] T050 [P] [US2] Write the mapper test in test/unit/verification_result_mapper_test.dart. It covers the row order in outcome-mapping.md (review wins over the counter), `LIVENESS` → generic, `remaining` = `intentos_restantes`, and that `NO_CONCLUYENTE` consumes nothing
- [X] T051 [P] [US2] Write the coverage test in test/unit/backend_error_mapping_test.dart: iterate over `BackendErrorCode.values` and assert each has an explicit outcome in each repository that can receive it (SC-004)
- [X] T052 [P] [US2] Write the log test in test/unit/no_token_in_logs_test.dart. Capture `developer.log`, print and Sentry `beforeSend` and `beforeBreadcrumb` output during a full fake-backend run, and assert that no bearer token, `Authorization`, JPEG magic bytes, typed name or document number appears (FR-017, SC-003)
- [X] T053 [P] [US2] Write the ribbon test in test/widget/demo_ribbon_test.dart:
  - with `BIOMETRIC_PROVIDER_MOCK` on, every routed screen shows "DEMO · biometría simulada" with a Semantics label;
  - no screen's text contains "verificad" or "identidad activa";
  - screen 008 reads "Registro completado".

### Implementation

- [X] T054 [US2] Create the `VerificationResult` entity in lib/domain/entities/verification_result.dart, and lib/data/services/verification_result_mapper.dart, which drops scores and erases `LIVENESS` to generic. Use it from `SubmissionBackedJobRepository` (makes T050 pass)
- [X] T055 [US2] Change 009 so the remaining count comes from the outcome, and release wiring has no local verification counter (FR-008). This touches lib/features/enrollment/retry/retry_guidance_viewmodel.dart. Update its tests
- [X] T056 [P] [US2] Add 010's release variant, shown when `EscalationRepository` is null: the checkpoint and lane copy, no chat, "Hablar con un agente" → lane instructions. This touches lib/features/enrollment/escalation/escalation_viewmodel.dart and escalation_view.dart. Update the widget test
- [X] T057 [P] [US2] Change 011 so it hides the status card when `ServiceStatusRepository` is null, and counts down from `retryAfter` when one is provided (FR-014). This touches lib/features/enrollment/technical_error/technical_error_viewmodel.dart and technical_error_view.dart
- [X] T058 [US2] Create lib/app/demo_ribbon.dart, and add it through `MaterialApp.builder` in lib/app/app.dart. Add the `demoRibbon` tokens to lib/core/design/app_colors.dart
- [X] T059 [US2] Apply the mock wording (FR-020, makes T053 pass):
  - 008 reads "Registro completado": lib/features/enrollment/credential_activated/credential_activated_viewmodel.dart;
  - the 012 strip badge reads "REGISTRADO": lib/features/trips/widgets/credential_strip.dart.
- [X] T060 [P] [US2] Create lib/data/services/local_consent_repository.dart: bundled text version `consent_text_es_v1`, the record kept in secure storage, and withdrawal clearing local state and signing out the session (research.md §14, §15). Test it in test/unit/local_consent_repository_test.dart
- [X] T061 [P] [US2] Add the withdrawal line "Tus datos en el servidor no se eliminan todavía desde la app." to lib/features/account/withdrawal_placeholder_view.dart and withdrawal_viewmodel.dart
- [X] T062 [US2] Extend the Sentry hooks in lib/core/sentry_config.dart: `beforeSend` strips `request` on all events, and `beforeBreadcrumb` drops the `http` category (makes T052 pass)
- [X] T063 [US2] Wire consent, retry, escalation and the ribbon in lib/app/composition_root.dart, and make T049 and T051 pass

**Checkpoint**: quickstart D-4 to D-7 pass. T049 to T053 are green.

---

## Phase 5: User Story 3 — The pass renews before it dies (P1)

**Goal**: the pass is issued by flight code, renewed at `renovar_en_segundos`, and hidden at
`expira_at` if renewal failed. `CONSUMIDA` means boarded.

**Unblocked at implementation (2026-09-23).** 014 phase A was already an online pass, built under
014's recorded deferral of offline rotation (FR-004, FR-005, SC-003). An online token that renews
every 40 s is that same deferral, and it persists nothing. So US3 is built in happy-path mode now.
Ratifying A1 and A2 is still required to **exit** happy-path mode, before any real passenger sees
the pass. The ⛔A1/A2 tags below are kept as that release gate, not as a build block.

**Independent test**: quickstart D-8 to D-10. It uses the dev `DevPassRepository` on the 40 s
model, or the local backend with a fixed flight code.

### Tests first

- [X] T064 [P] [US3] ⛔A1/A2 Write the pass-repository test in test/unit/backend_pass_repository_test.dart:
  - issue → `Issued`;
  - the renewal is scheduled at `renovar_en_segundos`, and each response replaces the current pass;
  - status is polled for the current id only;
  - `CONSUMIDA` → boarded, and renewal stops;
  - 429 and 503 honor Retry-After;
  - 403 `DOCUMENTO_VENCIDO` → `documentExpired`, with no retry;
  - nothing is persisted.
- [X] T065 [P] [US3] ⛔A1/A2 Update the ViewModel test in test/unit/pass_viewmodel_test.dart:
  - a failed renewal keeps the code until `expira_at` measured with the server offset, then `unavailable(expired)` with no code (SC-006);
  - background pauses renewal;
  - on resume past `renewAfter`, the code stays hidden until re-issue;
  - the stepper shows Embarque only (FR-024).
- [X] T066 [P] [US3] ⛔A1/A2 Update the widget test in test/widget/pass_view_test.dart: the lane copy on expiry, no security line, "Abordaje confirmado" on boarded, and no `QrCodeView` in any unavailable state

### Implementation

- [X] T067 [US3] ⛔A1/A2 Change lib/domain/entities/pass.dart and lib/domain/repositories/pass_repository.dart per data-model.md: `issue(FlightCode)`, token, issuedAt, renewAfter, permissions, and `PassState.boarded`. Remove `rotationSeconds`, `nextCheckpoint` and `tripId`
- [X] T068 [US3] ⛔A1/A2 Rewrite lib/data/services/pass_service.dart to `POST /v1/passes {codigo_vuelo}` and `GET /v1/passes/{id}`, and create lib/data/services/backend_pass_repository.dart (makes T064 pass)
- [X] T069 [P] [US3] ⛔A1/A2 Create lib/data/services/issued_token_pass_code_source.dart, which returns the current token. Delete lib/data/services/backend_pass_code_source.dart and lib/data/services/pass_repository_impl.dart
- [X] T070 [US3] ⛔A1/A2 Feed `serverOffset = issuedAt − receivedAt` to lib/app/clock_trust_monitor.dart on each issue. Update test/unit/clock_trust_monitor_test.dart
- [X] T071 [US3] ⛔A1/A2 Implement the renewal loop, the background pause, expiry at `expira_at`, and boarded, in lib/features/pass/pass_viewmodel.dart (makes T065 pass)
- [X] T072 [US3] ⛔A1/A2 Change the view for Embarque only, the lane copy and "Actualizando código…", in lib/features/pass/pass_view.dart and lib/features/pass/widgets/journey_stepper.dart. The ring tracks `renewAfter`, in lib/features/pass/widgets/rotation_ring.dart (makes T066 pass)
- [X] T073 [US3] ⛔A1/A2 Move lib/data/dev/dev_pass_repository.dart and `DevPassCodeSource` to the 40 s token model, keeping "Simular expirado" through the fake backend
- [X] T074 [US3] ⛔A1/A2 Wire `BackendPassRepository` and `IssuedTokenPassCodeSource` in lib/app/composition_root.dart. Mark phase B (T026–T031) cancelled under DEC-01 in specs/014-qr-pase/tasks.md, and add a note to specs/014-qr-pase/checklists/audit.md

**Checkpoint**: quickstart D-9 and D-10 pass. T064 to T066 are green.

---

## Phase 6: User Story 4 — Flight-code entry (P2)

**Goal**: in release, Mis viajes shows the credential strip and a flight-code field, and opens the
pass.

**Independent test**: quickstart D-8. `av 9201` becomes `AV9201`, and a malformed code is marked
with no request sent.

**Dependency**: T076 and T077 need only T075. T078 needs US3 (T067), because it calls
`issue(FlightCode)`.

- [X] T075 [P] [US4] Write the flight-code test in test/unit/flight_code_test.dart:
  - trims, upper-cases and removes internal spaces;
  - checks the regex `^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$`:
    - valid: `AV9201`, `LA123A`, and `av 9201` → `AV9201`;
    - invalid: `AV`, `AV92011` (five digits), `AV9201XY` and the empty string;
  - holds nothing in storage.
- [X] T076 [US4] Create the `FlightCode` entity in lib/domain/entities/flight_code.dart (makes T075 pass)
- [X] T077 [US4] Add a `FlightCodeEntry` state to lib/features/trips/trips_home_viewmodel.dart, used when `TripRepository` is null, with the in-memory code and "Mostrar mi pase". Render it in lib/features/trips/trips_home_view.dart. The field error reads "Revisa el código de vuelo (ej. AV9201)". Update test/unit/trips_home_viewmodel_test.dart and test/widget/trips_home_view_test.dart
- [X] T078 [US4] Route "Mostrar mi pase" to `/trip/pass`, carrying the `FlightCode` through an in-memory handoff rather than the route, so it stays out of navigation breadcrumbs. This touches lib/app/router.dart and lib/features/pass/pass_viewmodel.dart

**Checkpoint**: D-8 passes end to end.

---

## Phase 7: Polish and cross-cutting

- [X] T079 [P] Extend test/architecture/import_boundary_test.dart:
  - lib/data/auth/ and the new services have no `print` or `developer.log` that interpolates token, authorization, selfie, foto or numero;
  - views do not import lib/data/auth/.
- [X] T080 [P] Update README.md with the three flavors, running the local backend (quickstart prerequisites), the release blockers list, and the mock ribbon
- [X] T081 Run `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze --fatal-infos` and `flutter test`. All must be clean, with no generated-code diff
- [ ] T082 Walk quickstart D-1 to D-12 against the local backend, on an emulator. Record the results in specs/015-integracion-backend/quickstart.md. Ask the user before any device install
- [ ] T083 ⛔A3 Walk quickstart S-1 to S-3 against the deployed service with the staging flavor (SC-009), using synthetic markers only
- [X] T084 Update the front matter or notes of specs/002, 003, 004, 007, 008, 009, 010, 011, 012 and 014 with a one-line pointer to 015 for each requirement it superseded (the Gap table in spec.md)

---

## Dependencies and execution order

```text
Phase 0 Gates ──► Phase 1 Setup ──► Phase 2 Foundational ──► US1 ──► US2
                                            │                  │
                                            │                  └──► US4 (T075–T077)
                                            └── (⛔A1/A2) ──► US3 ──► US4 (T078)
                                                                   └──► Polish
```

- **US1** needs Foundational only. US1 is the MVP.
- **US2** needs US1's broker and repositories (T037, T041). Its tests T049–T053 can be written in
  parallel with US1.
- **US3** needs Foundational and the A1/A2 ratification. It is independent of US1 in code, and can
  be tested with the dev fake.
- **US4** needs US1 for the credential strip. T078 needs US3.
- **Within each story**: tests first (they must fail), then entities, then services and
  repositories, then ViewModels and views, then wiring.

## Parallel opportunities

- **Setup**: T006, T007, T008 and T009 together.
- **Foundational tests**: T010 to T014 together. Then T017, T018, T020 and T021 in parallel.
- **US1 tests**: T026 to T032 together. Then T033, T034, T039, T042 and T044 in parallel.
- **US2 tests**: T049 to T053 together. Then T056, T057, T060 and T061 in parallel.
- **US3 tests**: T064 to T066 together, once ratified.

Example, US1:

```text
Task: T026 contract test        Task: T027 registration form test
Task: T028 identity repo test   Task: T030 verification submission test
Task: T031 synthetic image test Task: T032 release wiring test
```

## Implementation strategy

1. **MVP (US1)**: registration, resume and verification against the local backend in dev, then
   staging once T024 is unblocked. This alone proves the contract.
2. **US2**: the honesty layer. Wording, the ribbon and the logs. Required before anyone outside the
   team sees a build.
3. **US3 and US4**: the pass, after ratification. US4's entity and form can land before US3.
4. **Polish**: the walk-throughs. Release stays blocked on the quickstart list regardless (R-01,
   F-03, DEC-02, withdrawal, sendDefaultPii).

---

## Implementation notes (2026-09-23)

**Status**: 79 of 84 tasks done.

**Open**:

| Task | Why it is open |
|---|---|
| T002 | Your decision: ratify or reject amendment 1.5.0 |
| T003 | Your action: confirm the Clerk instance configuration |
| T024 | ⛔A3: the Clerk session store is persisted state outside the allowlist, so it waits on A3. Until then, staging and prod wire `UnavailableSessionTokenProvider`, and every call fails honestly as `SessionUnavailable` |
| T082 | The emulator walk needs the local backend and an emulator, and it was not run |
| T083 | The staging walk needs T024 |

**Results**: `flutter analyze --fatal-infos` is clean, 832 tests pass, codegen is stable, and
`check_release_env env/prod.env` passes.

**Findings made while implementing**:

- **T006, pinning roots.** The deployed chains end in Google Trust Services (Vercel → GTS R1, Clerk →
  GTS R4), not ISRG. Pinning ISRG would have failed every connection. The anchors are GTS R1–R4.
  Pinning is proven with a real local TLS server (`pinned_dio_factory_test`).
- **T004, `clerk_auth` defaults.** It posts telemetry to clerk-telemetry.com every 29 s and polls
  every 9.7 s by default. Both must be off in T024. Its `SessionToken.toString` is informative, so a
  token object must never be logged.
- **006 selfie encoding.** The liveness camera produced raw luma bytes, which the backend rejects
  (415). 006 now takes one JPEG still with `takePicture()` and deletes the temp file at once, which
  is 003's accepted precedent.
- **Ribbon accessibility.** Placed above the page, the ribbon was dropped from the semantics tree by
  the route's BlockSemantics. It is now painted after the page and laid out on top.
- **005 during a resume.** Its constructor notified listeners during a build, which a resume from
  `/me` exposed. `EnrollmentSessionController.advanceTo` now notifies only on an actual change.
- **Second 401 on read paths.** `/me` and the pass status read did not map a second 401 to
  `SessionUnavailable`. The coverage test (T051) caught it, and both are fixed.
- **Credential layout at 200% text.** The longer "REGISTRADO" overflowed the credential card. The row
  now wraps.

**Deviations from the task text**:

| Task | Deviation |
|---|---|
| T018 | No `ErrorDto`. The mapper reads `codigo`, `detalles` and the Retry-After header directly, so `mensaje` is never read. Every DTO key is `@JsonKey(required: true)`, because Pydantic always sends nulls |
| T027, T033 | 004 keeps its field rows instead of a `RegistrationForm` type. Typed entry is detected from an all-empty capture. The backend's rules live in `RegistrationRules`, and refusals are a sealed `RegistrationRejection`. Nationality is not collected, because the backend never asks for it |
| T034 | `PassengerRepository` has `me()` only. Registration stays on `IdentityRecordRepository`, whose `confirm` gained the photo |
| T041 | `SubmissionBackedJobRepository` lives in `lib/app/`, beside the broker it reads, because the data layer must not import the app layer |
| T044 | The marker picker is on 006 only. The document photo has a single marker |
| T046, T055 | Issuance stays wired, as `PassengerIssuanceRepository`, which reads `/me`. That keeps 007's single hand-off point. 009 is unchanged: its selfie counter is `ServerBackedAttemptCounterRepository`, derived from `intentos_restantes`. 007 gained `VerificationOutcome.manualReview`, which routes to 010 |
| T032 | The release-wiring test is a source scan: every `/v1` literal must be a real endpoint, no invented host appears, and the backend wiring builds no dev fake. It is not a recorded run |
| T070 | The clock offset is taken in `BackendPassRepository.issue` from `emitida_at`, not in the monitor |
| T073 | `DevPassRepository` stays on 014's 30 s code model. It is used only by the offline demo |
| 011 `NO_CONCLUYENTE` | The retry countdown reads `reintentar_en_segundos` from the broker's last result. 004's 503 shows a "service busy" message on 004 itself, not 011 |

## Sign-in screen (2026-09-23, following the backend's authentication document)

The user replaced the silent session (Q2) with a visible sign-in. It is implemented and tested.

**Revised, 2026-09-23: Clerk's embedded widget.** A hand-built email-code flow came first. It
reported a correct code as wrong whenever the instance required more than the code. The user
chose Clerk's embedded `ClerkAuthentication` instead. What changed:

| File | Role |
|---|---|
| `lib/data/auth/clerk_setup.dart` | `aeroPassClerkConfig`: `MemoryPersistor`, `NoFileCache`, `PinnedClerkHttpService`, telemetry and polling off, Spanish |
| `lib/data/auth/clerk_localizations_es.dart` | The widget's Spanish strings |
| `lib/data/auth/clerk_session_token_provider.dart` | A token per call from `ClerkAuthState`; the session gate follows Clerk's signed-in state |
| `lib/main.dart` | Creates `ClerkAuthState` in the Clerk flavors |
| `lib/app/app.dart` | `ClerkAuth` and `ClerkErrorListener` above every route |
| `lib/features/auth/sign_in_view.dart` | Embeds `ClerkAuthentication`. The router leaves the screen once the gate opens |

The old port (`SignInRepository`, `SignInFailure`), `ClerkAuthRepository`, `SignInViewModel`, their
tests and 13 unused strings were removed. **Tests**: `clerk_session_token_provider_test` (8 cases)
and the router guard cases. The full suite passes and analyze is clean. The dependency review of
`clerk_flutter` is in research.md §2.

**Production diagnostics (2026-09-23).** A sign-in reported as failing had created a Clerk session
(`session.created` in Clerk's log), so the failure came after it. `lib/core/diagnostics.dart` now
writes to Sentry Logs, a Sentry breadcrumb and logcat (`[aeropass] …`). Every value is redacted.
Only codes, statuses, paths and durations are logged: never an email, code, token, header or body.
It is fed by:

- `ClerkDiagnostics`: SDK errors, with Clerk's server codes and messages, and each sign-in step;
- `PinnedClerkHttpService`: every Clerk call, and a connection warm-up before the SDK's 1 s start-up
  calls;
- `DiagnosticsInterceptor`: every backend call's status and `codigo`;
- `ClerkSessionTokenProvider`: token failures.

`main()` now starts Clerk after Sentry.

The original notes follow.

**Pieces**:

| File | Role |
|---|---|
| `lib/domain/repositories/sign_in_repository.dart`, `lib/domain/entities/sign_in_failure.dart` | The port and its failure kinds |
| `lib/data/auth/clerk_client.dart` | `clerk_auth` behind a small interface: email-code sign-in, falling back to sign-up; telemetry and polling off; pinned TLS through `PinnedClerkHttpService`; a memory-only `MemoryPersistor` |
| `lib/data/auth/clerk_auth_repository.dart` | Sign-in steps, a fresh token per call, the Clerk-code → app-kind mapping, and the session gate |
| `lib/app/session_gate.dart` | Re-runs the router's redirect when the session is lost |
| `lib/features/auth/` | The screen: email, then a 6-digit code, then on to `next` |
| `lib/app/router.dart` | `/sign-in`, and a guard on every route after consent. "Ya tengo cuenta" opens sign-in |

**Dependency**: `http` is now declared, because `PinnedClerkHttpService` uses `IOClient`. It was
already a transitive dependency of `clerk_auth`.

**Tests**: `clerk_auth_repository_test`, `sign_in_view_test`, and five router guard cases. 853 tests
pass, and analyze is clean.

**T024 status**: the Clerk provider is built. Storing its session still waits on A3, so for now a
restart means signing in again.

**Open**:

- In the Clerk dashboard, enable Email address with Email verification code (sign-in and sign-up)
  for instance `discrete-satyr-7298`.
- Set `CLERK_PUBLISHABLE_KEY` in `env/staging.env` and `env/prod.env`. The user does this.
- Rotate the secret key, which was shared in chat. It must never be in the app.
