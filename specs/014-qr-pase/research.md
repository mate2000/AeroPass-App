# Research: Dynamic QR Pass (14 QR Pase)

Phase 0 of the plan. The spec's six clarifications leave no open product question. They do leave a
**governance question**. What follows are the technical decisions, each checked against the
constitution (v1.4.0) and the code as it stands after 001–012.

## §1 — The constitution conflicts with the chosen offline design

**Finding**: Clarification Q1 chose codes derived on the device from a stored, backend-issued
secret. Two clauses of constitution v1.4.0 forbid that today:

1. **Principle I, persisted-state allowlist**: the app may persist the credential token and its
   validity window, display-only identity fields, the consent record, and attempt counters. A pass
   secret is not on the list.
2. **Security & Compliance Constraints**: "A QR pass MUST carry a short server-defined TTL and MUST
   NOT be regenerable offline." Deriving a fresh code every 30 seconds without a network is
   regenerating it offline.

The constitution also pulls the other way:

- Principle V says "the QR pass MUST render, count down, and remain usable with no network once
  issued".
- Principle IX says the pass surfaces "MUST read from local state as the source of truth for
  display".

A pass that rotates every 30 seconds cannot satisfy Principle V without the regeneration the
Security clause forbids. The constitution is internally inconsistent for a rotating pass.

**Decision**: write the amendment proposal the Governance section requires
(contracts/constitution-amendment-proposal.md) and ask the user to ratify it. It does two things:

- It adds "a QR-pass secret issued by the backend, and its server-defined validity window" to the
  allowlist, in secure storage only, deleted at expiry, boarding, withdrawal and revocation.
- It rewrites the Security clause: *no new pass, secret or extended validity may be created
  offline*; *codes derived from a backend-issued secret inside its server-defined validity are
  permitted*.

It is proposed as **1.5.0 (MINOR)**, because it expands permitted behavior under new obligations and
makes no compliant code non-compliant.

**Until it is ratified, nothing may store the secret or derive codes offline.** The plan is split in
two:

- **Phase A**, buildable now: the whole screen, with each code fetched from the backend per
  rotation. This is allowed today, and is the spec's happy-path relaxation "Offline rotation;
  development may assume the network is present" (deferral FR-004, FR-005, SC-003).
- **Phase B**, blocked on ratification: the secret store and on-device derivation behind the same
  port, which switches the pass to offline.

## §2 — One port, two code sources

**Decision**: `PassCodeSource.codeAt(pass, instant)` returns the payload for the 30-second window
containing `instant`.

| Implementation | Phase | How |
|---|---|---|
| `BackendPassCodeSource` | A | `GET /v1/passes/{passId}/code`. Online only; a failure means no code, never a guessed one |
| `DerivedPassCodeSource` | B | Uses the stored secret. The window is `floor((instant + serverOffset) / 30 s)`. MAC = HMAC-SHA256(secret, `passId ‖ checkpoint ‖ window`), truncated to 16 bytes. Payload = `AP1.<passId>.<checkpoint>.<window>.<base64url(mac)>` |
| `DevPassCodeSource` | A (dev) | The fake backend: a synthetic payload per window, behind `USE_FAKE_VERIFICATION_BACKEND` |

The reader holds the secret server-side and validates the MAC and the window (±1) independently.
The device is never the authority (FR-002). `crypto` is already a dependency, used by 001's pinning,
so HMAC needs nothing new.

## §3 — Rendering the QR

**Decision**: add the **`qr` package**, a pure-Dart QR encoder (the one `qr_flutter` builds on), and
draw the matrix with a `CustomPainter`, with error correction level H so the centre mark does not
break decoding.

**Justification** (constitution Security, third-party dependencies): it is pure computation. It has
no access to the camera, storage, network or device identifiers, and no platform code.

**Alternatives considered**:

- `qr_flutter`: it brings image-embedding code this screen does not need.
- A hand-written encoder: Reed–Solomon and masking are not worth owning.

## §4 — The pass contract with the backend

| Call | Purpose |
|---|---|
| `POST /v1/passes` `{enrollmentAttemptId, tripId}` | Issues a pass: `passId`, `nextCheckpoint` (`security` or `boarding`), `validUntil` (≤ scheduled departure and ≤ 24 h), `rotationSeconds` (30), `serverTime`. Phase B adds `secret` |
| `GET /v1/passes/{passId}/code` | Phase A only: the current window's payload, with `windowEndsAt` and `serverTime` |
| `GET /v1/passes/{passId}/status` | `state` (`active`, `expired`, `revoked`, `boarded`), `validated` (the checkpoints done), `nextCheckpoint`, `flightStatus`, `serverTime` |

Status is polled every **5 s** while the screen is visible and online. It is the only thing that
advances the stepper (FR-009) or ends the pass. `serverTime` from any response refreshes the clock
offset (§5).

## §5 — Clock trust (FR-014, Clarifications: 30 s)

**Decision**:

- **Offset**: every response carries `serverTime`, and `offset = serverTime − deviceNow` at receipt.
  An `|offset|` over **30 s** makes the pass untrusted: no code is shown, and the screen asks the
  passenger to set the time automatically.
- **Jumps within the process**: a `Stopwatch` started at the last server contact runs on monotonic
  time. If `deviceNow − lastContactDevice` differs from `stopwatch.elapsed` by more than 30 s, the
  wall clock was changed, and the pass is untrusted until the next contact.
- **Across restarts (phase B)**: the stored secret carries `issuedAtServer`. A device clock before it
  (after applying the stored offset) is untrusted.

The derived window uses `deviceNow + offset`, so an honest drift inside the tolerance still
produces the reader's window.

## §6 — Brightness, keep-awake and capture blocking

**Decision**: add a `PassDisplayGuard` port backed by a new method channel, `aeropass/pass_display`,
in `MainActivity.kt`, the same pattern 008 used for screen capture. `enterPassMode` sets:

- `screenBrightness = 1f`,
- `FLAG_KEEP_SCREEN_ON`,
- `FLAG_SECURE`.

`exitPassMode` restores the previous brightness and clears both flags. It is called on dispose, on
pause and on "Atrás", and re-applied on resume.

**Low power**: timers may be suspended. On resume, the code and countdown are recomputed from the
clock (FR-006).

**iOS**: brightness and the idle timer are available, through `UIScreen.brightness` and
`isIdleTimerDisabled` in `AppDelegate.swift`. **iOS cannot block screenshots**; it can only detect
them. The plan records this as a platform limitation of FR-007, not a pass. The minimum-spec device
is Android.

## §7 — The "Simular expirado" release gate (FR-019, SC-006)

**Decision**:

1. **A flag**: a new `HappyPathFlags.devPassControls`, read from `DEV_PASS_CONTROLS`. It is added to
   `assertReleaseSafe`, so a release build with it on refuses to start, as with the existing fake
   backends.
2. **Compile-time absence**: the control is built only under `if (HappyPathFlags.devPassControls)`.
   The flag is a `const`, so a release build tree-shakes the widget and its callback.
3. **A pipeline check**: `tool/check_release_env.dart` fails if `env/prod.env` enables any
   happy-path flag. CI runs it as a new step, and a test runs it too.
4. **A widget test**: with the flag off, "Simular expirado" is not in the tree.

Forcing expiry goes through the fake backend, which marks the pass expired. It never goes through a
client-side flag, so even the dev control exercises the real expired path.

## §8 — Compromised devices (constitution Security; missing from the spec)

**Finding**: the constitution requires the app to "detect a compromised device posture
(root/jailbreak, emulator, hooking framework) and MUST refuse to issue or display a QR pass on one.
Refusal MUST route the user to the agent-escalation path." The spec does not mention it, and the app
has no such check.

**Decision**: add a `DevicePostureChecker` port.

- **Android**, on the `aeropass/pass_display` channel: `su` binaries, `test-keys`, emulator build
  properties, and known hooking frameworks (Frida and Xposed paths and ports).
- **iOS**: common jailbreak paths.

A compromised result shows "No podemos mostrar tu pase en este dispositivo", with "Hablar con un
agente" (010) and the checkpoint line. No pass is requested.

**Recorded limitation**: on-device heuristics can be bypassed. The robust answer is attestation,
Play Integrity or App Attest, verified by the backend before issuance, and that is a backend
dependency. This is added to the spec as FR-023.

## §9 — Getting to the pass, and back (Clarifications)

- **From 013's placeholder**: it gains "Continuar a tu pase", which opens `/trip/pass`. 013 is
  unspecified, so the placeholder asserts nothing. The backend's issuance is the authority.
- **"Ver pase" on Mis viajes (FR-022)**: a `PassRepository.activePassFor(tripId)` makes the card
  show "Ver pase". In phase A the pass lives in memory, so after the process dies the card falls
  back to "Iniciar viaje". Phase B reads the stored secret, so it survives offline reopens.
- **"Atrás"**: this pops to Mis viajes and exits pass mode (FR-020).

## §10 — After boarding

When status reports `boarded`:

- the code disappears;
- "Abordaje confirmado · Buen viaje" is shown;
- phase B deletes the secret at once;
- polling stops.

The backend moves the trip to history, and the Mis viajes card stops offering "Ver pase".

## §11 — Events (FR-017, FR-018)

| Event | Payload |
|---|---|
| `pass_displayed` | `checkpoint`, `offlineCapable`, a bool |
| `pass_rotated` | `checkpoint` |
| `pass_validated` | `checkpoint`, `secondsSinceOpened` |
| `pass_expired` | `reason`: `validity`, `revoked`, `flight`, `clock`, `device` |
| `pass_reissue_requested` | `succeeded` |
| `pass_help_opened` | none |

No payload, pass id, flight number or date appears (FR-015). `pass_validated.secondsSinceOpened` is
FR-018's measure.

## §12 — Notes from implementing phase A

- **No trip id in the route.** `/trip/pass` takes no parameter. The pass is always for the trip Mis
  viajes promotes as next, read from the in-session snapshot, so no itinerary id reaches Sentry's
  navigation breadcrumbs.
- **No secret field.** The issuance DTO has no `secret` field, so a secret sent early by the backend
  is dropped unread (FR-021).
- **The dev backend never validates on its own.** Advancing Seguridad on a timer would be exactly
  the elapsed-time advance FR-009 forbids. In development the stepper stays at Seguridad unless a
  test scripts a validation.
- **013 placeholder.** "Continuar a tu pase" replaces the placeholder with the pass, so "Atrás"
  returns to Mis viajes (FR-020).
- **Wall clock versus monotonic time.** The clock monitor compares them, using an in-process
  stopwatch. Phase B adds the before-issuance check across restarts.
- **A flaky 007 test was fixed.** "onAppResumed polls immediately" raced a 1 ms poll timer, and the
  ViewModel rightly skips a concurrent poll. The test now uses a slow interval. App behavior is
  unchanged.

