# Research: Backend Integration (015)

Phase 0 of the plan. Each decision was checked against constitution v1.4.0, the backend source
(`AirPass/Aeropass/src/aeropass`), and the app as it stands after 001–014.

## §1 — A new finding: the call-order script does not exist

**Finding (V-10)**: guide v2 says `src/aeropass/tools/e2e_flow.py` walks the whole flow against
production, and that the app should mirror its call order. The file is not in the backend
repository and is not referenced anywhere. The tools that do exist are:

- `bench_passes.py`
- `gen_signing_key.py`
- `make_mock_images.py`
- `setup_qstash_schedule.py`

**Decision**: the call order is derived from the routers and services and recorded in
[contracts/backend-api.md](./contracts/backend-api.md) §Call order. SC-009 is re-pointed at the
quickstart walk (quickstart.md, scenario I-1) instead of the script.

## §2 — A silent Clerk session (spec Q2, FR-001, FR-001a)

> **Superseded, 2026-09-23.** Sign-in is visible and uses Clerk's embedded `ClerkAuthentication`
> widget from `clerk_flutter` 0.0.18-beta. A hand-built email-code flow came first, and it failed
> when the instance asked for more than the code (a code the user typed correctly was reported
> wrong). The widget handles whatever the instance requires. What still holds below: tokens per
> call, the `SessionTokenProvider` port, telemetry and polling off, and the pinned HTTP service.
>
> **Dependency review (constitution, third-party dependencies)**. `clerk_flutter` adds these
> direct dependencies: `image_picker`, `passkeys`, `webview_flutter`, `url_launcher`,
> `path_provider`, `phone_input`, `flutter_svg`, `email_validator` and `http`.
>
> - **Storage**: the persistor is `MemoryPersistor`, and the file cache is `NoFileCache`, so the
>   SDK writes nothing to disk. `path_provider` is linked but unused by this configuration.
> - **Network**: every Clerk call goes through `PinnedClerkHttpService` (GTS roots). Telemetry,
>   client polling and token polling are off. Social or SSO buttons would open `webview_flutter` or
>   `url_launcher` to Clerk-hosted pages. Keep social providers disabled on the instance until
>   that is reviewed.
> - **Device**: `image_picker` is used only by `ClerkUserButton`'s avatar editing, which the app
>   does not use. `passkeys` is used only when the instance enables passkeys.
> - **Localization**: Spanish strings in `lib/data/auth/clerk_localizations_es.dart`. Errors never
>   echo a server argument.
>
> This review is recorded here for ratification with amendment 1.5.0. The session stays in memory
> until A3 is ratified.

**Facts**:

- The backend accepts any signed-in Clerk session with a `sub` claim
  (`adapters/auth/clerk.py:26`).
- Clerk has no anonymous-user concept.
- The Flutter SDK is `clerk_auth`, published by clerk.com. It is pure Dart, at 0.0.18-beta,
  community-maintained, and expects breaking changes before 1.0. It persists through a `Persistor`
  interface and exposes session tokens.

**Decision**:

1. **At first launch**, the app signs up a Clerk user with a random username (`ap_<22 base32
   chars>`) and a random 32-byte password. Both are generated on the device and neither is ever
   shown.
2. **Only Clerk's client session is kept.** The password is discarded after sign-up.
   - Losing the session loses the account. That is the same outcome as the spec's reinstall case,
     so keeping the password would buy nothing and would store a secret.
   - The session lives in `flutter_secure_storage`, through a custom `Persistor`. `clerk_auth`'s
     default persistor writes plain files, which the constitution's Security clause forbids.
3. **Tokens are fetched per call**, before each `/v1/*` request, and never cached by the app
   (FR-001).
4. **The code talks to a port**, `SessionTokenProvider`:
   - `ClerkSessionTokenProvider` serves staging and prod;
   - `TestSessionTokenProvider` serves dev, and returns `test:<stable random id>` (§5).

   Because of the port, a Clerk SDK breaking change touches one adapter.

**Instance configuration this requires** (a dependency to confirm before any staging build):

- username as an identifier, with password on;
- email and phone not required;
- bot protection that does not challenge native sign-ups.

**Confirmed at implementation, T004 (2026-09-23), against `clerk_auth` 0.0.18-beta**:

- **HTTP client**: `AuthConfig` takes an `HttpService`, so Clerk traffic can use the pinned trust
  store (§4).
- **Telemetry**: `AuthConfig.telemetryPeriod` defaults to sending telemetry to
  `clerk-telemetry.com` every 29 s. It MUST be set to `Duration.zero` (Principle VII).
- **Background polling**: `clientRefreshPeriod` polls Clerk every 9.7 s. It is set to `Duration.zero`,
  and `sessionTokenPolling` to false, because the app asks for a token per call.
- **Token cache**: `Auth.sessionToken()` reuses its own token until 10 s before expiry. The app
  keeps no copy, which satisfies FR-001's "never cached by the app".
- **Logging risk**: `SessionToken` has an informative `toString`. A token object MUST never be
  logged or interpolated, and T079 checks this.

The original note follows. A second thing had to be confirmed at implementation: that `clerk_auth` accepts an injected HTTP
client, so its traffic can use the pinned trust store (§4). If it does not, the Clerk connection is
chain-validated but unpinned, and that gap goes into Complexity Tracking.

If Clerk cannot be configured this way, the fallback is a backend endpoint that mints a sign-in
token. That is a backend change, and so out of this feature's scope.

**Justification for the dependency** (constitution Security, third-party dependencies):

- **Access**: network, to Clerk's Frontend API, and storage, only through the injected persistor.
  No camera frames or device identifiers.
- **Principle I**: it holds no personal data. The username is random, and no email or phone is
  collected.
- **Principle VII**: it must not log tokens. Its logging is off by default, and a test asserts that
  no token appears in captured logs (FR-017).

**Alternatives considered**:

- Calling Clerk's Frontend API by hand: this removes a beta dependency, but it means owning the
  client-JWT and session rotation protocol. Rejected for now. The port keeps it open.
- `clerk_flutter`, the widget package: it brings sign-in UI the flow does not use. Rejected.

## §3 — Flavor names: the spec's "integration" is the constitution's "staging"

The constitution requires dev, staging and prod flavors. The spec's `integration` flavor fills the
staging slot, so the files are named `env/dev.env`, `env/staging.env` and `env/prod.env`. The spec
keeps "integration" as a description of what staging is for.

| Flavor | `API_BASE_URL` | `AUTH_MODE` | `SYNTHETIC_CAPTURE` | `BIOMETRIC_PROVIDER_MOCK` |
|---|---|---|---|---|
| dev | `http://10.0.2.2:8000` (the local backend, as seen from the Android emulator) | `test` | true | true |
| staging | `https://aeropass-lac.vercel.app` | `clerk` | true | true |
| prod | `https://aeropass-lac.vercel.app` | `clerk` | false | true, until a real provider is declared |

- **The Clerk publishable key** (`pk_…`) is public by design, not a provider credential, so it may
  be committed.
- **dev's plain HTTP** is a happy-path relaxation behind `ALLOW_INSECURE_LOCAL_BACKEND`, which
  `assertReleaseSafe` and `tool/check_release_env.dart` both refuse.

## §4 — TLS pinning against Vercel (constitution Security)

**Finding**: the constitution requires certificate pinning and fail-closed. The deployed service is
on Vercel, which rotates leaf certificates every few months and controls the intermediates. Today's
`buildPinnedDio` only consults pins through `badCertificateCallback`, which runs for chains that
have **already failed** validation. With a valid Vercel certificate, no pin is checked at all. The
app is effectively unpinned today, and nothing noticed, because no backend existed.

**Chains, inspected on 2026-09-23 with `openssl s_client`** (T006). The plan's first draft assumed
Let's Encrypt. That was wrong, and pinning ISRG would have failed every connection.

| Host | Chain |
|---|---|
| `aeropass-lac.vercel.app` | `*.vercel.app` → Google Trust Services WR1 → GTS Root R1 (cross-signed by GlobalSign Root CA) |
| `api.clerk.com` | → GTS WE1 → GTS Root R4 |

**Decision**:

- Pin the four **Google Trust Services roots**, R1 to R4, by making them the **only trust
  anchors**:
  - build a `SecurityContext(withTrustedRoots: false)` and call `setTrustedCertificatesBytes` with
    the four bundled root certificates (public, in `assets/tls/`, with their fingerprints in
    `assets/tls/README.md`);
  - `badCertificateCallback` returns `false` unconditionally.

  A chain that does not end in a pinned root then fails the handshake: it fails closed, on every
  connection. dart:io exposes only the leaf certificate after a handshake, so a post-handshake
  chain check is not possible. The trust store is the mechanism that is.
- **Why all four roots**: they tolerate a switch between RSA and ECDSA issuance, which moves the
  root between R1–R2 and R3–R4.
- **GlobalSign is left out**: it is only a cross-signer, and it expires in 2028.
- **Clerk** uses the same anchor set. Its instance-specific Frontend API host is re-checked at T003.
- **Record this in Complexity Tracking**:
  - Root pinning protects against a misissuing CA other than Google Trust Services, **not**
    against a misissuance by GTS itself.
  - Leaf or intermediate pinning would break the app on Vercel's rotation schedule, with no way for
    the app team to see a rotation coming.
  - If Vercel moved `*.vercel.app` to another CA, the app would fail closed. That is the correct
    failure, but it is an outage, so the anchor set must be re-checked before each release.
  - A custom domain with a controlled certificate would allow stronger pinning, and it is
    recommended before an airport pilot.

**Alternative rejected**: no pinning. It violates the constitution outright.

## §5 — The dev backend and its test identities

- **Identity**: dev's `TestSessionTokenProvider` keeps one random id per install, in secure storage
  (dev only), so a dev run can exercise resume across restarts. `Bearer test:<id>` is refused by
  staging and prod configuration, both statically and in the release check.
- **What a developer runs**: the backend repository with `AEROPASS_ADAPTERS=fake` and a local
  Postgres. The quickstart lists the commands. That mode keeps images in memory, so dev runs add
  nothing to the deployed store (spec Q1).

## §6 — Synthetic capture for dev and staging (FR-018)

**Decision**: when `SYNTHETIC_CAPTURE` is true, the document and selfie steps skip the camera
handoff and take their bytes from a `SyntheticImageSource`. It reproduces the backend's
`make_image` in Dart:

- a JPEG made of SOI, a COM segment carrying `MOCK:<marker>`, and EOI;
- valid for the backend's magic-number check (V-02);
- a few dozen bytes long.

**Markers**:

| Marker | Backend result |
|---|---|
| `documento` | used for the document photo |
| `ok` | liveness 0.95, comparison 0.93 → `EXITOSO` |
| `spoof` | liveness 0.20 → `FALLIDO` / `LIVENESS` |
| `other` | comparison 0.30 → `FALLIDO` / `COMPARACION` |
| `timeout` | the breaker opens → `NO_CONCLUYENTE` |

A development-only picker on 006 chooses among them. The camera UI still runs, so the screens are
exercised, but its frames are discarded.

**Why code, not assets**:

- Bundled assets ship in every build, including prod.
- A `const` flag lets the compiler drop `SyntheticImageSource` and the picker from prod.
- A test asserts the prod env has `SYNTHETIC_CAPTURE` false, and the release check refuses it.

**Why this matters beyond privacy**: R-01 means real photos always pass. Only markers can drive the
failure paths (009, 010, 011) against a real backend.

## §7 — Verification is synchronous; 007 keeps its screen (FR-005, Q3)

**Facts**:

- `POST /v1/biometrics/verifications` returns the result in the same response.
- 007's ViewModel polls `VerificationJobRepository.getStatus()`.
- 006 streams samples to `LivenessVerificationRepository`.

**Decision**: keep both ports and add a small in-memory broker, `VerificationSubmission`, in
`lib/app/`:

- **006** runs its on-device liveness challenge as today. The challenge is guidance only; it has no
  server meaning. When the challenge completes, 006 takes **one still**, a JPEG, and hands it to
  `VerificationSubmission.submit(bytes)`, which starts the POST.
- **Release `LivenessVerificationRepository`** is replaced by `LocalLivenessRepository`, which
  accepts samples locally and sends nothing. The existing `…Impl` becomes dev-only.
- **Release `VerificationJobRepository`** is `SubmissionBackedJobRepository`:
  - it returns *processing* while the POST is in flight;
  - when the response arrives, it maps the result to 007's existing terminal outcomes, following
    the routing table in [contracts/outcome-mapping.md](./contracts/outcome-mapping.md);
  - 007's 1 s poll becomes a cheap in-memory read.

  007's routing, timeout and resume are unchanged.
- **Bytes**: dropped from memory when the response arrives, or on error or cancel (Principle I).

**Why this over rewriting 007**: 007 has 40+ tests on its routing and timeouts. An adapter keeps
them valid, and adds tests only for the mapping.

**The request timeout** is 35 s. The backend's breaker opens at its own timeout and answers
`NO_CONCLUYENTE`, so the app waits slightly longer than the backend. 007's hard timeout stays
longer still.

## §8 — Registration from typed fields (Q1, FR-002, FR-002a, FR-022)

**In release**:

- **003**: `DocumentVerificationRepository` is `LocalDocumentCaptureRepository`. It holds the JPEG
  in memory, keeps the capture-quality check (`HeuristicQualityAssessor`), and returns an
  *accepted* outcome with **empty** extraction.
- **004**: the form's fields start empty.
  - **Tipo de documento**: a three-way choice, CC, CE or Pasaporte.
  - **Nombre completo**: text.
  - **Número**: free text, normalized for display as the backend will: separators removed,
    upper-cased.
  - **Fecha de vencimiento**: a date picker.

  Local validation mirrors V-04, V-05 and FR-022. The screen carries the line "Revisa que los
  datos coincidan con tu documento".
- **On confirm**, the release `IdentityRecordRepository` is `BackendIdentityRecordRepository`. It
  sends the multipart request, with `foto_documento` declared `image/jpeg`. It stores only the
  response's display subset: the name and the masked number.
- **The full number** is dropped from the ViewModel on success. It is never persisted (FR-004).
- **Field re-verification** (`FieldReverificationRepository`) is not wired in release. Its entry
  point on 004 is hidden, because typed fields have nothing to re-verify against (FR-025).

**Size**: `camera` at `ResolutionPreset.high` produces JPEGs of roughly 0.5–2 MB. Before sending,
the repository checks the 4 MB limit. An oversize capture returns the existing "capture again"
outcome, not a 413 round trip.

## §9 — Resume and credential status from `GET /v1/identity/me` (FR-023)

The release `CredentialRepository` and `CredentialSummaryRepository` are adapters over one
`PassengerService.me()`:

| `/me` | `CredentialStatus` / route |
|---|---|
| 404 `PASAJERO_NO_REGISTRADO` | none; launch goes to Bienvenida (register) |
| `PENDIENTE_VERIFICACION` | the enrollment-in-progress state; launch resumes at 005/006 |
| `VERIFICADO` with `identidad_id` | `CredentialStatus.active`; launch goes to Mis viajes |
| `VERIFICADO` without `identidad_id` | treated as pending; re-read once, never shown active (edge case) |
| `REQUIERE_REVISION_MANUAL` | the escalation state; launch goes to 010 |
| a transport or 5xx error | the existing unreachable state (011 rules) |

`CredentialIssuanceRepository` (008's `POST /v1/credential/issuance`) has no counterpart. The
backend creates the identity inside the verification call. 008's release path re-reads `/me`, and
the issuance port becomes dev-only.

## §10 — The pass: token rotation replaces code rotation (FR-010 to FR-013, FR-015b)

014 phase A fetched a code per 30 s window with `GET /v1/passes/{id}/code`. The real service issues
a whole new pass every 40 s instead.

**Decision**:

- **`PassRepository.issue(tripId)`** becomes `issue(FlightCode)`:
  - it calls `POST /v1/passes`;
  - it holds `credencial_id`, the token and the timestamps in memory;
  - it schedules the next issue at `renovar_en_segundos`.

  Each response replaces the current pass, because the backend revokes the previous one.
- **`PassCodeSource`**: the release implementation, `IssuedTokenPassCodeSource`, returns the
  current token. Rotation is the renewal. The 30 s `rotationSeconds` of 014 becomes the pass's own
  `renovar_en_segundos`.
- **Status**: `GET /v1/passes/{current id}` every 5 s while visible. It is always polled for the
  **current** id, because an old id reads `REVOCADA` after a renewal. `CONSUMIDA` →
  `PassState.boarded`, and renewal stops. `EXPIRADA` or `REVOCADA` for the current id → unavailable.
- **Clock**: `offset = emitida_at − receiptTime`. The server issued the pass moments before, so this
  offset is honest to within round-trip time. 014's clock-trust monitor takes it.
- **Failure**: when a renewal fails, the current code stays displayed until `expira_at`, measured
  with the server offset. It then switches to "Este código ya no sirve · Pasa por el carril
  convencional". A 429 or 503 schedules the next attempt at `Retry-After`.
- **Background**: renewal pauses. On resume, a pass past `renovar_en_segundos` is re-issued at once,
  and the stale code stays hidden in the meantime (spec edge case).
- **Stepper**: `permisos` = `["embarque"]`. The stepper shows Embarque only, and the security line
  is removed (FR-024). It advances only on `CONSUMIDA`.
- **Rate budget**: 60/40 = 1.5 issues per minute against a limit of 30. A tight retry loop is the
  only way to hit it, and FR-014 forbids one.

**014 artifacts affected**: `BackendPassCodeSource` and `PassService.code()` become dead code in
release and are deleted. The dev fake is updated to the same 40 s model. Phase B (T026–T031) is
cancelled (DEC-01).

## §11 — Flight-code entry on Mis viajes (DEC-03, FR-010, Q3 of clarify)

In release, `TripRepository` is not wired. `TripsHomeViewModel` gains a `FlightCodeEntry` state:
the credential strip, then a "Código de vuelo" field and a "Mostrar mi pase" action.

- **Normalization**: trimmed and upper-cased. Internal spaces are removed only for comparison with
  the regex, so `av 9201` → `AV9201`.
- **Validation**: `^[A-Z0-9]{2}[0-9]{1,4}[A-Z]?$`.
- **Storage**: the code is held in memory only (clarify Q3).

The next-trip card, history and freshness chips from 012 stay as the dev-fake path.

## §12 — Errors (FR-003, FR-014 to FR-016, SC-004)

One `BackendError` type is produced at the service boundary:

- `codigo`, as an enum of the 14 known codes plus `unknown`;
- `status`;
- `retryAfter`, a `Duration?` read from the header;
- `campos`, a `List<String>`.

`mensaje` is **not parsed**, so it cannot reach a string. Each repository maps codes to its own
sealed outcomes, following [contracts/outcome-mapping.md](./contracts/outcome-mapping.md). An
`unknown` code reaches the existing generic path and is reported to Sentry by code only. SC-004 is
tested by iterating over the enum.

## §13 — Tokens and bodies never reach logs (FR-017)

- **The auth interceptor** writes the `Authorization` header on the request object only. Dio has no
  `LogInterceptor` in any flavor. A test asserts that `dio.interceptors` contains none.
- **Sentry**: the app does not use `sentry_dio`, so HTTP breadcrumbs come only from navigation.
  `beforeBreadcrumb` drops any `http` category, as a guard, and `beforeSend` strips `request`. These
  extend 011's `stripAlertEventPii` to every event.
- **Upstream constraint**: `sendDefaultPii = true` is still set. It is an open release gate from the
  Sentry setup, and it must be false before prod.
- **Errors**: they are logged by `codigo` and status only.

## §14 — Consent withdrawal has nowhere to go (Principle I; not in the spec)

**Finding**: Principle I says revocation "MUST immediately invalidate the local credential and any
displayed pass". The local half is possible. But the backend has no revoke or delete endpoint, so
the server-side identity stays `VERIFICADO` and its images stay in the blob store (F-03). A
withdrawal in the app cannot reach the data it concerns.

**Decision**:

- **Locally**, withdrawal clears everything and signs the Clerk session out. The registration then
  becomes unreachable from this device.
- **The screen says it plainly**: "Tus datos en el servidor no se eliminan todavía desde la app."
- **This is recorded as a release blocker**, alongside DEC-02 and F-03. It is not claimed as
  compliance.

**Alternative rejected**: presenting withdrawal as deletion. That is false, and it is the kind of
statement Ley 1581 makes consequential.

## §15 — The consent text is bundled (DEC-02)

The release `ConsentRepository` is `LocalConsentRepository`:

- `getCurrentText()` returns the version compiled into the app (`consent_text_es_v1`);
- `recordConsent` writes the version and timestamp to secure storage, which is already on the
  allowlist;
- `withdraw()` follows §14.

The **retention sentence** is kept as it is on screen 02 until F-03 names one figure. It is listed
in the quickstart's release checklist as un-shippable.

## §16 — The mock ribbon (FR-020)

- **Where**: a `DemoRibbon` in `MaterialApp.builder` wraps every route. It is a non-dismissible
  banner at the top safe area reading "DEMO · biometría simulada". Its `Semantics` label is read
  once per screen.
- **Colors**: from the design tokens (a new `AppColors.demoRibbon` token pair).
- **When**: shown when `BIOMETRIC_PROVIDER_MOCK` is true.
- **Wording**: `IdentityActiveViewModel` exposes the title "Registro completado" when the flag is
  on, and the strip on 012 says "REGISTRADO" instead of "ACTIVA". A widget test searches every
  screen's text for "verificad" and "identidad activa" while the flag is on.
- **Turning it off**: the flag cannot be false unless `BIOMETRIC_PROVIDER_NAME` is set to something
  other than `mock` in the same env file. `tool/check_release_env.dart` enforces that pairing.

## §17 — Budgets affected (constitution "Product Budgets")

- **Cold start to a usable pass under 3 s**: this can no longer be met for a relaunched app. The
  flight code is retyped (clarify Q3), and a pass needs one network round trip (DEC-01). It is
  measured from "Mostrar mi pase" instead, with a target of p90 under 2 s on 4G. That redefinition
  needs the same amendment as DEC-01.
- **Contingency degrades within 60 s**: met. A failed renewal reaches the lane message at
  `expira_at`, at most 45 s after the last successful issue.
- **Agent path one tap away, with context**: in release, 010 has no chat (Q3). "One tap" reaches a
  screen that tells the passenger to go to the conventional lane. No context is carried, because
  there is no one to carry it to. This is recorded as a budget shortfall.
