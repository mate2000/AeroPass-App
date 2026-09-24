# Feature Specification: Backend Integration (015)

**Feature Branch**: `015-integracion-backend`

**Created**: 2026-09-23

**Status**: Draft

**Input**: User description: "Connect the Flutter app to the AeroPass backend. The frontend guide
dated Sep 23, 2026 describes the API; verify it before building against it." The full input, with
its verification note, discrepancy register (D-01 to D-20), risks (R-01 to R-08), decisions
(DEC-01 to DEC-04) and findings from guide v3 (F-01 to F-04), is preserved in
[`contracts/verification-record.md`](./contracts/verification-record.md). This specification
restates the parts that bind behavior and adds what a second check found.

**Note on scope**: this is not a screen. It replaces the contract every earlier specification
(001–014) was built against. Those specifications assumed a backend that was never written. Their
data layers call seventeen paths under `api.dev.aeropass.example`. The real service has five
authenticated endpoints, and only one path (`POST /v1/passes`) coincides, with a different body.
Section "Gap against the app as built" lists each one.

## Delivery Mode: Happy Path First

Same section as specifications 005 through 014 (constitution Principle III).

**Relaxable during happy-path mode**, each recorded as a deferred requirement:

- Retry and backoff policies beyond honoring `Retry-After`.
- Offline handling. Under DEC-01 the pass is online-only, so the only offline behavior is stating
  that the pass is unavailable.
- Token-refresh edge cases beyond requesting a fresh token before each call.
- Analytics completeness. Events that exist must already carry no personal data.

**Deferred requirements, by identifier**:

| Requirement | What is deferred | What still holds in happy-path mode |
|---|---|---|
| FR-014 | Backoff beyond `Retry-After` | `Retry-After` is honored; no immediate retry after a 429 or 503 |
| FR-001 | Refresh races, such as a session expiring between token fetch and request | A 401 routes to sign-in, never to a generic error |
| SC-005 | Measuring the renewal success rate in the field | Renewal happens at `renovar_en_segundos`, and a failed renewal is visible |

**Not relaxable, in any mode**:

- No real personal data in development. Synthetic identities only, including against production.
- No persistence of images or biometric samples on the device.
- No personal data, token or `Authorization` value in logs, events or crash reports (FR-017).
- **No credential or pass presented as valid without a backend response saying so.**
- Every relaxation lives behind a build flag absent from release builds.

**Specific to this feature**: while R-01 holds (the deployed biometric provider approves any
image), no build in any flavor may describe a verification result as a verified identity, and
every screen carries the "DEMO · biometría simulada" ribbon (FR-020).

## Verification Summary

The guide was checked on 2026-09-23 against the deployed service at
`https://aeropass-lac.vercel.app` (its OpenAPI document and JWKS) and against the backend source
(`AirPass/Aeropass/src/aeropass`).

- **Guide v1** matched the endpoint paths and almost nothing else. It is superseded, and its
  discrepancy register is kept for history in the verification record.
- **Guide v2** (17:04) matches the source, with one exception that errs in the dangerous direction.
  v2 says real camera photos "probablemente no las apruebe". In fact the mock approves any image
  that carries no `MOCK:` marker, scoring it 0.95 and 0.93 (`mock_adapter.py:32`). **Every real
  selfie passes.**
- **Guide v3** (17:18) adds where each piece of data lives (F-01 to F-04).

**Second check, made while writing this specification** (backend source, same day):

| Finding | Source | Consequence for the app |
|---|---|---|
| V-01: All five registration fields are required. A missing one returns 422 `DATOS_INVALIDOS` with `detalles.campos` naming it. This resolves the input's `[NEEDS VERIFICATION]` | `RegistrationService._validate` | FR-002 holds as written |
| V-02: The declared content type of an image part must match its bytes (JPEG, PNG or WebP magic numbers). A mismatch is 415 `FORMATO_NO_ADMITIDO` | `domain/images.py: validate_image` | An upload sent as `application/octet-stream`, a common client default, fails every time (FR-021) |
| V-03: "Identical resubmission" means the same document type and number. The name, expiry and photo are not compared, and the stored photo is **not replaced** | `DocumentoRegistrado.es_mismo` | A retried registration after a recapture keeps the first photo as the biometric reference |
| V-04: The document number is normalized: separators removed, upper-cased, 4–20 of `[A-Z0-9]`. The mask is `*` for every character except the last four | `domain/passenger.py` | The masked value on screen 004 is `******1234`, not the `•••• 1234` the app draws today |
| V-05: The name is 2–200 characters after collapsing whitespace | same | Validate on the device to avoid a round trip |
| V-06: The flight code must match `^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$` after trimming and upper-casing, for example `AV9201` | `domain/flight.py` | Screen 012's flight-code entry validates locally with the same rule. `AV 9201`, with a space, is rejected |
| V-07: The backend performs no document reading. There is no OCR, MRZ or extraction endpoint | router list | Screens 003 and 004 have no backend source for the name, number or expiry. Resolved by Q1: the passenger types them |
| V-08: There is no sign-in endpoint. Identity is a Clerk session. The app has no Clerk client, no sign-in screen and no designed sign-in step | app source, designs | Resolved by Q2 (revised): a sign-in screen with Clerk's embedded widget |
| V-09: The passenger record is keyed to the Clerk user (`get_by_clerk_user`) | `RegistrationService` | Signing in with the same email reaches the same user, so a reinstall keeps the registration (FR-001a) |
| V-10: `src/aeropass/tools/e2e_flow.py`, which guide v2 cites as the call-order reference, does not exist anywhere in the backend repository | tools directory | The call order is derived from the routers instead (plan research §1) |

## Decisions (2026-09-23)

The four decisions in the input are adopted as written. A consequence the input did not state is
added to each.

- **DEC-01 — The pass is online-only.** The TTL is 45 s, with renewal at 40 s. This supersedes
  specification 014 FR-004 and SC-003. It supersedes constitution Principle V ("the QR pass MUST
  render, count down, and remain usable with no network once issued") and the Principle IX clause
  that makes local state the pass's source of truth for display. *Added consequence*:
  - The 1.5.0 amendment proposal in `specs/014-qr-pase/contracts/constitution-amendment-proposal.md`
    exists only to allow offline derivation. It becomes moot, and 014's phase B (T026–T031) is
    cancelled rather than blocked.
  - What remains necessary is a **different** amendment, relaxing Principle V and IX for the pass.
    The Security clause ("MUST NOT be regenerable offline") is satisfied as it stands.
  - No pass data is persisted, so the persisted-state allowlist needs no change.
- **DEC-02 — Consent is local only, and the gap is documented.** *Added consequence*: the app today
  fetches the consent text from `/v1/consent/current-text` and posts the record to `/v1/consent`,
  and neither exists. The text and its version must be bundled with the app. The screen 02
  retention sentence must not be shipped to a real passenger while F-03 is open.
- **DEC-03 — The passenger supplies the flight code.** *Added consequence*: specification 012's
  next-trip card, gate, seat, history and the 90-day window are removed. So is 014's trip line
  ("AV 8841 · BOG → GRU · Hoy 14:35"), apart from the code the passenger typed.
- **DEC-04 — Contract and mapping first.** No client code is written until this specification and
  its plan are reviewed.

## Clarifications

### Session 2026-09-23

- Q1: The backend reads nothing from the document image, so where do the name, document number,
  type and expiry sent in `POST /v1/identity` come from? → A: **The passenger types them on screen
  004.** The photo from 003 is sent as captured. No on-device reading is added (FR-002a).
- Q2: Every `/v1/*` call needs a Clerk session, and no screen signs the passenger in. Where does
  sign-in happen? → A (revised 2026-09-23, replacing "a silent session at launch"): **A visible
  sign-in through Clerk's embedded `ClerkAuthentication` widget, following the backend's
  authentication document.** The widget asks for whatever the Clerk instance requires. It sits
  after consent and before document capture, so no data reaches the identity provider before
  consent. "Ya tengo cuenta" on Bienvenida opens it too. The same step signs in a returning
  passenger and signs up a new one, so a reinstall reaches the same account (V-09 resolved). A
  session that cannot be recovered sends the passenger back to sign-in (FR-001, FR-001a).
- Q3: Several app features call endpoints the backend does not have: agent escalation and chat
  (010), service status (011), field re-verification (004), and the async verification job (007).
  What happens to them? → A: **They are kept only as development fakes behind flags.** Release
  builds take the simpler path, and none of them calls a host that does not exist (FR-025).
- Q: Which backend should each build flavor talk to? → A: **`dev` uses a local backend in fake mode
  with `test:` tokens. `integration` uses the deployed service with Clerk and synthetic images only.
  `release` uses the deployed service** (FR-018).
- Q: While the provider approves every selfie, what does screen 008 show instead of "verified", and
  how is the mock visible? → A: **A permanent "DEMO · biometría simulada" ribbon on every screen,
  and "Registro completado" on 008, never "verificada" or "identidad activa"** (FR-020).
- Q: Should the flight code be saved on the phone across app restarts? → A: **No. It is kept in
  memory only, and the passenger retypes it after a relaunch. No amendment is needed** (FR-010).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - The app speaks the real contract (Priority: P1)

Every call the app makes matches the deployed service:

- multipart where multipart is required, with the right content type on each image part;
- the enum values the backend accepts;
- the field names it returns.

A change to the backend contract breaks a test rather than a passenger.

**Why this priority**: the guide would have produced an app that fails on its first call, and the
app as built fails on every call. The contract is the foundation every other story stands on.

**Independent Test**: run each request against the live service with a valid session and a
synthetic identity. Each endpoint returns a success status and parses without a missing-field
error.

**Acceptance Scenarios**:

1. **Given** a registration, **When** the app calls `POST /v1/identity`, **Then** it sends
   multipart with the five fields, a `tipo_documento` of `CC`, `CE` or `PASAPORTE`, a
   `fecha_vencimiento` as `YYYY-MM-DD`, and a `foto_documento` part whose declared type matches its
   bytes.
2. **Given** a `PasajeroResponse`, **When** the app parses it, **Then** it reads `id` and
   `numero_documento_enmascarado`, and never expects `pasajero_id` or an unmasked number.
3. **Given** any documented outcome, **When** it is returned, **Then** the app handles it
   explicitly, including `NO_CONCLUYENTE`, 429 and 503, rather than falling into a generic error.
4. **Given** a contract change in the backend, **When** the app's contract tests run, **Then** they
   fail and name the field that changed.
5. **Given** an app launch with a signed-in session, **When** the app calls `GET /v1/identity/me`,
   **Then** it routes as follows:
   - 404 → registration;
   - `PENDIENTE_VERIFICACION` → selfie;
   - `VERIFICADO` → the credential;
   - `REQUIERE_REVISION_MANUAL` → the agent path.

---

### User Story 2 - Outcomes are translated, never echoed (Priority: P1)

The backend returns scores, enum names and internal failure reasons. The passenger sees none of
them:

- `LIVENESS` becomes a generic retry;
- `COMPARACION` becomes actionable advice;
- scores never leave the data layer.

**Why this priority**: it shares P1 because this is where the no-disclosure rule of specifications
006 and 009 is enforced in code. A well-meaning error screen that prints `motivo_fallo` publishes
the attack-detection signal.

**Independent Test**: force each outcome and inspect every passenger-visible string. No enum name,
score or backend message reaches the screen.

**Acceptance Scenarios**:

1. **Given** `motivo_fallo = LIVENESS`, **When** screen 009 renders, **Then** the wording is generic
   and identical to other generic failures.
2. **Given** any response, **When** it is rendered, **Then** no score, enum identifier or backend
   `mensaje` appears in the UI.
3. **Given** any response, **When** it is logged, **Then** no token, `Authorization` value, image or
   personal field is written.
4. **Given** a successful verification while the provider is declared mock, **When** screen 008
   renders in any flavor, **Then** it reads "Registro completado" and never "verificada" or
   "identidad activa", and the "DEMO · biometría simulada" ribbon is visible.

---

### User Story 3 - The pass renews before it dies, and says so when it cannot (Priority: P1)

The pass lives 45 seconds, and the app renews it at 40. When renewal fails (no network, 429, 503),
the passenger is told the code is no longer usable and what to do at the lane. The app does not
show a code the reader will refuse.

**Why this priority**: under DEC-01 this is the most fragile part of the product, and the failure
happens in front of a queue.

**Independent Test**: display a pass and block the network. At expiry the pass stops presenting as
usable, with a stated fallback. Restore the network, and renewal resumes.

**Acceptance Scenarios**:

1. **Given** a displayed pass, **When** `renovar_en_segundos` elapses, **Then** the app requests a
   new pass and replaces the code without passenger action.
2. **Given** a renewal that fails, **When** `expira_at` passes, **Then** the code is visibly
   unusable and the conventional lane is stated as available.
3. **Given** a 429 with `Retry-After`, **When** the app retries, **Then** it honors the header
   rather than retrying immediately.
4. **Given** a device clock that differs from the server's, **When** validity is evaluated, **Then**
   the app trusts the server timestamps, not the device clock.
5. **Given** a pass whose detail reports `CONSUMIDA`, **When** the screen updates, **Then** it shows
   that the passenger went through, and no code.

---

### User Story 4 - The passenger enters the flight and gets a pass (Priority: P2)

With no airline integration (DEC-03), the passenger types the flight code on Mis viajes. The app
checks its format before sending it and asks for a pass for that flight.

**Why this priority**: it is the only way to reach the pass, but it depends on stories 1 and 3.

**Independent Test**: enter `av9201` and get a pass for `AV9201`. Enter `AV 92011X` and get a
field-level error without a request.

**Acceptance Scenarios**:

1. **Given** a verified passenger on Mis viajes, **When** they enter a valid flight code, **Then**
   the app issues a pass with it and opens screen 014.
2. **Given** a malformed code, **When** they submit, **Then** the field is marked and no request is
   sent.
3. **Given** a 403 `DOCUMENTO_VENCIDO` on issuance, **When** it returns, **Then** the passenger is
   told the document has expired and is offered the agent path, not a retry.

### Edge Cases

- The Clerk session expires mid-enrollment, and every `/v1/*` call turns 401 at once.
- `POST /v1/identity` returns 200 instead of 201 on resume. The app must not treat that as an error.
- A resubmission after a recapture returns 200 but keeps the **first** photo as the biometric
  reference (V-03).
- A 503 with `Retry-After` arrives during registration, after the passenger has already captured.
- `REQUIERE_REVISION_MANUAL` arrives with `intentos_restantes > 0`. The state wins over the counter.
- The passenger enters a flight code the format validator rejects.
- A pass is requested for a flight that already has a live credential. That is a renewal, not a
  second pass.
- The app is backgrounded across a renewal boundary. Renewal pauses in the background. On resume,
  a pass past `renovar_en_segundos` is reissued at once, and the stale code is not shown in the
  meantime.
- The app is killed in the queue. On relaunch, `/v1/identity/me` lands on Mis viajes, and the
  flight code must be retyped before the pass reappears (FR-010).
- `identidad_id` is null on a successful verification.
- The service is reachable, but every verification is approved (R-01).
- A 409 `ESTADO_NO_PERMITE_VERIFICACION` on a selfie, because the passenger is already verified or
  in review. Re-read `/v1/identity/me` and route by state.
- An image is over 4 MB after capture (413). The app must compress below the limit before sending,
  not after a failure.
- The app is reinstalled, so the silent session is lost and the passenger re-registers the same
  document. That is 409 `DOCUMENTO_YA_REGISTRADO`, which routes to the agent path (FR-001a).
- The passenger types a number that differs from the photographed document. The backend cannot
  tell, so the mismatch surfaces only as a `COMPARACION` failure or not at all. Screen 004 must ask
  the passenger to check the typed values against the document.
- The pass is `CONSUMIDA` while the renewal loop is still running. Renewal must stop, and it must
  not issue a fresh pass for a flight already boarded.

## Requirements *(mandatory)*

### Functional Requirements

Identifiers FR-001 to FR-020 follow the input, so that its reviewers can cross-reference them.

**Authentication and configuration**

- **FR-001**: All `/v1/*` calls MUST carry a Clerk session token requested fresh before each call
  and never cached by the app.
  - The passenger signs in on a sign-in screen that embeds Clerk's `ClerkAuthentication` widget,
    which asks for whatever the Clerk instance requires. The screen comes after
    consent and before any backend call, and "Ya tengo cuenta" opens it too.
  - A 401 first tries one fresh token and retries once. If there is none, the session is over, and
    every guarded route leads to the sign-in screen (the backend's authentication document).
  - The app never handles a password and never builds a token.
- **FR-001a**: The email is held only by the identity provider. The app never persists, logs or
  sends it in analytics.
  - Until amendment A3 allows storing the session, it lives in memory, and a restart means signing
    in again.
  - Because sign-in reaches the same account after a reinstall, a 409 `DOCUMENTO_YA_REGISTRADO`
    means another person's account, and still routes to the agent path.
- **FR-018**: The base URL and the Clerk publishable key MUST be flavor configuration, not
  constants. There are three flavors:

  | Flavor | Backend | Auth | Images |
  |---|---|---|---|
  | `dev` | A local backend in fake-adapter mode | `Bearer test:<id>`, with no Clerk | Synthetic only |
  | `integration` (the constitution's `staging` flavor, `env/staging.env`) | The deployed service | A silent Clerk session | Synthetic only, generated in code and never from the camera |
  | `release` | The deployed service | A silent Clerk session | Real capture |

  The `test:` token scheme MUST be absent from `integration` and `release`. The release-environment
  check MUST fail if `release` names any other backend. The `integration` flavor exists because the
  deployed store keeps every image with no deletion job (F-03). Routine development never adds to
  it.

**Registration (screens 003, 004)**

- **FR-002**: `POST /v1/identity` MUST be sent as multipart/form-data with `nombre_completo`,
  `tipo_documento` (`CC`|`CE`|`PASAPORTE`), `numero_documento`, `fecha_vencimiento` and
  `foto_documento`. All five are required (V-01).
- **FR-002a**: The name, document type, number and expiry MUST be typed by the passenger on screen
  004, from the document they just photographed. The app MUST NOT pre-fill them from any extraction
  in a release build. A development fake MAY pre-fill synthetic values behind its flag (FR-025).
- **FR-003**: The app MUST treat 200 from `POST /v1/identity` as success, because resubmission is
  idempotent. It MUST distinguish `CUENTA_YA_REGISTRADA` from `DOCUMENTO_YA_REGISTRADO`.
- **FR-004**: The app MUST display the masked document number returned by the backend. It MUST NOT
  retain or reconstruct the full number after submission.
- **FR-016**: On a 422, the `detalles.campos` array MUST be used to mark the offending field.
- **FR-021**: Every image part MUST declare a content type that matches its encoded bytes, and MUST
  be encoded at 4 MB or less before sending (V-02).
- **FR-022**: The app MUST validate locally, with the backend's rules, before sending:
  - the name is 2–200 characters;
  - the number is 4–20 of `[A-Z0-9]` after removing separators;
  - the expiry is today or later.

  The backend remains the authority (V-04, V-05).

**Verification (screens 006, 007, 009, 010, 011)**

- **FR-005**: The app MUST handle all three values of `resultado`, including `NO_CONCLUYENTE`, and
  MUST NOT count a `NO_CONCLUYENTE` as a passenger attempt.
- **FR-006**: `motivo_fallo = LIVENESS` MUST produce a generic passenger-facing message identical to
  other generic failures. `COMPARACION` MAY produce actionable guidance.
- **FR-007**: `score_liveness`, `score_comparacion`, `motivo_fallo`, enum identifiers and backend
  `mensaje` values MUST NOT appear in any passenger-visible string.
- **FR-008**: The retry budget shown to the passenger MUST come from `intentos_restantes`. The app
  MUST NOT maintain its own verification-attempt counter. Capture-quality counters (003) are a
  different thing and are unaffected.
- **FR-009**: `estado_pasajero = REQUIERE_REVISION_MANUAL` or `intentos_restantes = 0` MUST route to
  the agent path.
- **FR-023**: Resume after interruption MUST be decided by a single `GET /v1/identity/me`, routed as
  in User Story 1, scenario 5.

**Pass (screens 012, 014)**

- **FR-010**: `POST /v1/passes` MUST include `codigo_vuelo`, collected from the passenger (DEC-03),
  normalized and checked against the backend's format (V-06).
  - The code and the current `credencial_id` MUST be held in memory only, and MUST NOT be written
    to storage.
  - After the process ends, the passenger retypes the code. The backend has no endpoint that lists
    a passenger's passes, so nothing can be recovered without the id.
  - Re-issuing for the same flight renews in place, so retyping never creates a second live pass.
- **FR-011**: The app MUST render the `token` field as the QR and MUST NOT expect `qr_payload`.
- **FR-012**: The app MUST renew the pass at `renovar_en_segundos`. When renewal has not succeeded
  by `expira_at`, it MUST stop presenting the code as usable and state that the conventional lane is
  available.
- **FR-013**: Validity MUST be evaluated against server timestamps (`emitida_at`, `expira_at`),
  never against the device clock alone.
- **FR-015b**: `EstadoCredencial.CONSUMIDA` MUST be treated as a successful outcome, meaning the
  passenger passed the checkpoint. It MUST NOT be presented as an error or as an expired pass. A
  consumed pass MUST NOT be re-displayed as usable, and it MUST end the renewal loop (F-01).
- **FR-024**: The pass screen MUST NOT claim the pass opens a checkpoint its `permisos` do not
  include. Today `permisos` is `["embarque"]`, so the screen MUST NOT tell the passenger to present
  it at security until the permission set includes one (conflict with 014).

**Errors and service conditions**

- **FR-014**: 429 and 503 responses MUST honor `Retry-After`, and MUST be presented as service
  conditions rather than passenger rejections (screen 011).
- **FR-015**: 403 `IDENTIDAD_NO_ACTIVA` and 403 `DOCUMENTO_VENCIDO` MUST be distinguished and
  explained, not collapsed into a generic failure.

**Privacy, testing and honesty**

- **FR-017**: Tokens, `Authorization` headers, images and personal fields MUST NOT appear in logs,
  analytics or crash reports. This includes HTTP breadcrumbs and request bodies captured by the
  error-reporting service.
- **FR-019**: Contract tests MUST cover every endpoint and every documented status, and MUST fail
  when a field name or enum value changes.
- **FR-020**: While the biometric provider is mock (R-01), no build may present a verification
  result as a confirmed identity. The backend does not report its provider, so the mock status is a
  build-time declaration (`BIOMETRIC_PROVIDER_MOCK`). It is on by default in every flavor, and it
  stays on until someone removes it deliberately. While it is on:
  - **Ribbon**: every screen shows a permanent ribbon reading "DEMO · biometría simulada". The
    ribbon cannot be dismissed, is announced by screen readers, and appears in screenshots.
  - **Screen 008**: it says "Registro completado". It MUST NOT use "verificada", "identidad
    activa", "identidad verificada" or any equivalent. The same rule applies to the credential strip
    on 012 and to screen 014.
  - **Release check**: the release-environment check reports the flag's state. It does not fail on
    it, because shipping the demo is allowed, but it MUST NOT be possible to turn the flag off
    without also changing the declared provider in the same configuration.
- **FR-025**: Every earlier data-layer path with no counterpart in the backend MUST remain only as a
  development fake behind a happy-path flag, and MUST be absent from release wiring (Q3). Release
  builds MUST take these paths:
  - **010**: the escalation screen shows the checkpoint line and no chat. "Hablar con un agente"
    means going to the conventional lane.
  - **011**: no service-status card.
  - **004**: no field re-verification.
  - **007**: awaits the synchronous verification response instead of polling a job.
  - **002**: bundled consent text, and the record kept locally (DEC-02).
  - **012**: no trips list (DEC-03).

  No release build may resolve `api.dev.aeropass.example` or any other host that does not exist.

### Screen → endpoint map

| Screen | Call |
|---|---|
| 001 Bienvenida | `GET /v1/identity/me` on launch, for resume (FR-023) |
| 002 Consentimiento | none; local only (DEC-02) |
| 001 Bienvenida (launch) | silent Clerk session (FR-001) |
| 003 Escanear documento | captures `foto_documento`; no backend call (V-07) |
| 004 Confirmar datos | passenger types the four fields (FR-002a); `POST /v1/identity` on confirm; displays `PasajeroResponse` |
| 006 Selfie | `POST /v1/biometrics/verifications` with one `selfie` image |
| 007 Validando | awaits that response; routes by `resultado`, `motivo_fallo` and `estado_pasajero` |
| 008 Identidad activa | `GET /v1/identity/me` |
| 009 Reintento | `intentos_restantes`, `motivo_fallo` |
| 010 Escalar agente | `REQUIERE_REVISION_MANUAL`; no backend escalation API exists |
| 011 Error técnico | `NO_CONCLUYENTE`, 429, 503 |
| 012 Mis viajes | `GET /v1/identity/me` and a flight-code entry (DEC-03) |
| 014 QR Pase | `POST /v1/passes`, the renewal loop, `GET /v1/passes/{credencial_id}` |

### Gap against the app as built

| App path today (spec) | Real counterpart |
|---|---|
| `GET /v1/consent/current-text`, `POST /v1/consent`, `POST /v1/consent/withdraw` (002) | none (DEC-02) |
| `POST /v1/document-verification` (003) | none (V-07) |
| `POST /v1/field-reverification` (004) | none |
| `POST /v1/identity-record` (004) | `POST /v1/identity`, with a different body |
| `POST /v1/liveness-verification/sessions`, `…/samples` (006) | `POST /v1/biometrics/verifications`, one image, synchronous |
| `GET /v1/verification/jobs/current` (007) | none. The verification is synchronous |
| `POST /v1/credential/issuance`, `GET /v1/credential/status` (008) | `GET /v1/identity/me` (`estado`, `identidad_id`) |
| `POST /v1/escalations`, `GET /v1/escalations/current`, `/v1/escalations/chat` (010) | none |
| `GET /v1/service-status` (011) | none |
| `GET /v1/trips` (012) | none (DEC-03) |
| `POST /v1/passes`, `GET /v1/passes/{id}/code`, `GET /v1/passes/{id}/status` (014) | `POST /v1/passes` `{codigo_vuelo}`, and `GET /v1/passes/{id}` |

### Key Entities

- **Passenger (`PasajeroResponse`)**: the registered identity:
  - `id`, the name, the document type, the masked number and the expiry;
  - `estado`, one of `PENDIENTE_VERIFICACION`, `VERIFICADO` or `REQUIERE_REVISION_MANUAL`;
  - `intentos_fallidos`, from 0 to 3;
  - `identidad_id`, which may be null.

  The app keeps only the display fields the constitution allows.
- **Verification attempt (`ResultadoVerificacionResponse`)**: one selfie's result:
  - `resultado`, `motivo_fallo`, the resulting `estado_pasajero`, `intentos_restantes` and
    `reintentar_en_segundos`;
  - scores, which are read and discarded in the data layer.
- **Pass (`PaseResponse`)**:
  - `credencial_id`, `token` (the QR content), `codigo_vuelo`, `permisos`, `estado`, `emitida_at`,
    `expira_at` and `renovar_en_segundos`;
  - held in memory only, and replaced on each renewal.
- **Pass detail (`DetallePaseResponse`)**: `estado` and `historial`, with no token. It is used to
  detect `CONSUMIDA`, `EXPIRADA` and `REVOCADA`.
- **Backend error**: `codigo`, `mensaje` (never shown), an optional `detalles.campos`, and an
  optional `Retry-After`.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of endpoints have a contract test that fails on a field or enum change.
- **SC-002**: Zero passenger-visible strings contain a score, an enum identifier or a backend
  message.
- **SC-003**: Zero tokens, headers, images or personal fields appear in logs or crash reports.
- **SC-004**: 100% of documented error codes have an explicit app-side path. None reach a generic
  handler.
- **SC-005**: Pass renewal succeeds before expiry in at least 99% of foregrounded sessions with
  connectivity.
- **SC-006**: Zero passes are displayed as usable past `expira_at`.
- **SC-007**: The attempt budget shown matches `intentos_restantes` in 100% of cases.
- **SC-008**: Zero builds present a mock verification as a confirmed identity. While the mock
  declaration is on, 100% of screens show the demo ribbon.
- **SC-009**: A synthetic passenger can walk from welcome to a displayed pass against the deployed
  service, following the call order in contracts/backend-api.md (`e2e_flow.py` does not exist; V-10), with no step served by a
  development fake.

## Assumptions

- Guide v2, corrected for R-01, and the backend source are the contract. Where they disagree, the
  source wins.
- The `integration` and `release` flavors consume the deployed service, and `dev` consumes a local
  backend in fake-adapter mode (FR-018). A developer running `dev` needs the backend repository
  running locally, with Postgres.
- The server time basis is taken from `emitida_at` at receipt, because no response carries an
  explicit server time. 014's clock-trust monitor re-bases on it.
- Only the document photo and one selfie leave the device. The on-device liveness challenge from
  006 has no server-side meaning today, but it is kept, because it is the passenger's guidance for
  a usable selfie.
- The failed-attempt limit is 3 and is owned by the server. This closes 009 FR-009.

## Dependencies

- A Clerk client for Flutter and a token provider. The Clerk instance must be configured to allow a
  session created without passenger input (Q2). This is unconfirmed, and it blocks every real call.
- A constitution amendment adding the auth session to the persisted-state allowlist (FR-001a).
- A later account-upgrade flow, so a registration survives a reinstall. It is out of scope here.
- A constitution amendment to Principles V and IX for the online-only pass (DEC-01). It replaces the
  pending 1.5.0 proposal.
- A single agreed retention figure and a deletion job (F-03). Its owner is outside the mobile team,
  and it blocks shipping screen 02's text.
- A backend consent endpoint (absent; DEC-02), trips endpoint (absent; DEC-03), escalation endpoint
  (absent) and checkpoint validation feed (the proxy exists, but the app has no endpoint to read
  it).

## Out of Scope

- Checkpoint-side validation and the reader.
- The agent console.
- Any backend change. This specification describes the client against the backend as it is. Risks
  R-05 to R-08 and F-03 are reported to the backend owner, not fixed here.
