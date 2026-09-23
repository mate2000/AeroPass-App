# Research: Credential Activated (08 Identidad activa)

No `NEEDS CLARIFICATION` markers remain. The specification's three were resolved in
`/speckit-specify` and five more decisions in `/speckit-clarify` (see spec.md, Clarifications).
What follows are the technical design decisions needed to implement this feature. Several touch
already-shipped code from 001, 002 and 006; each is called out individually, per this project's
established practice.

## §1 — A new, issue-only port: `CredentialIssuanceRepository`

**Decision**: add `CredentialIssuanceRepository` under `domain/repositories/`, with one method,
`requestIssuance()`, returning `Result<IssuanceOutcome>`. It is called by a new
`VerificationProgressViewModel` that backs the existing verification-progress placeholder route
(Clarifications: "the existing verification-progress placeholder obtains issuance"). The existing,
read-only `CredentialRepository` (001) is left untouched.

**Rationale**: Constitution Principle X's interface-segregation rule is explicit: "a ViewModel that
needs to read a credential MUST NOT receive an interface that can also issue or revoke one."
`WelcomeViewModel` and the router's redirect read status through `CredentialRepository`; adding an
`issue()` method to it would hand issuing power to every reader. A separate port also keeps
Principle II's adapter boundary intact: the issuance DTO, endpoint and error codes stay inside
`data/services/`.

**Alternatives considered**:
- *Add `issue()` to `CredentialRepository`*: rejected, per the segregation rule above.
- *Have screen 08's own ViewModel call issuance on open*: rejected in Clarifications (option B).
  It would give this screen a waiting state it must not own, and would make "the screen opened"
  and "the backend affirmed" happen in the wrong order for FR-001.

## §2 — `IssuanceOutcome` is sealed, and "complete and active" is decided at the data boundary

**Decision**: `IssuanceOutcome` has three variants: `activated(ActivatedCredential)`,
`notActive(CredentialLifecycleStatus status)`, and `incomplete()`. The real repository maps the
response as follows, in order:

1. Transport failure (offline, timeout, non-2xx, pinning) → `Result.error`.
2. Status field missing or unrecognized → `Ok(incomplete())`.
3. Status is anything other than `active` → `Ok(notActive(status))`.
4. Any display field missing or malformed → `Ok(incomplete())`. Malformed means: empty holder
   name; `documentLast4` not exactly four digits; issuing country not a three-letter code;
   `validUntil` missing, unparseable, or not after `issuedAt`; token empty.
5. Otherwise → `Ok(activated(...))`.

`VerificationProgressViewModel` opens screen 08 only on `activated`. `notActive` and `incomplete`
go to the new outcome placeholder (§11). `Result.error` stays on the placeholder with a retry,
the technical-error path for this step until screen 07 designs it.

**Rationale**: FR-010 (clarified) says screen 08 never opens for a non-active or incomplete
credential. Deciding completeness where the DTO is parsed means no widget or ViewModel can ever
hold a half-valid `ActivatedCredential`; the type itself is the guarantee (Principle IX, "sealed
types over boolean flags"). It also makes FR-004 structural: there is no code path that renders a
card without a backend validity date.

**Alternatives considered**:
- *Return the raw credential and let screen 08 check it*: rejected. It makes FR-010 a runtime check
  in the view layer rather than a property of the type.
- *Treat `incomplete` as a transport error*: rejected. A well-formed response with a missing
  field is a backend defect, not a network problem, and retrying it would loop.

## §3 — What is persisted, and where

**Decision**: on `activated`, `CredentialIssuanceRepositoryImpl` writes exactly two values to
secure storage, using the keys `CredentialService` (001) already reads:
`aeropass.credential.token` and `aeropass.credential.valid_until`. The write happens before the
outcome is returned; if the write fails, the result is `Result.error` and screen 08 does not open.
The display fields (holder name, last four digits, country, issue date) are never persisted by
this feature. They live in memory only, in the hand-off of §4.

**Rationale**: Constitution Principle I's allowlist names "the credential token issued by the
backend, its validity window". 001's `CredentialService.readCachedCredential()` already documents
itself as reading "the credential cached by the credential-issuance feature" — this is that
feature. Writing before returning mirrors 002's and 004's "only durable on backend success" shape
in reverse: the passenger is never shown an active credential that a relaunch cannot find. The
issue date is the start of the validity window, so it is also within the allowlist should a later
surface need it, but nothing here requires persisting it. FR-013 is satisfied because
`ActivatedCredential` carries only displayed fields plus nothing else — the token goes to storage
and is not a field of the display entity at all.

**Alternatives considered**:
- *Persist the display fields too, for the credential surface*: rejected for now. That surface is
  not specified, and 004 already caches a display subset (including the full document number the
  passenger saw at confirmation). Adding a second copy is a decision for the credential surface's
  own spec.
- *Derive holder name and last four digits from 004's cached display subset*: rejected. FR-001
  requires the card to show what the backend issued, not what the app remembers from an earlier
  step.

## §4 — One-time display with no new persisted state: an in-memory hand-off

**Decision**: add `ActivatedCredentialHandoff` in `lib/app/`, mirroring `PendingDocumentController`
(004) exactly: an app-process-scoped `ChangeNotifier` holding at most one `ActivatedCredential`,
never persisted, never logged. `VerificationProgressViewModel` sets it on `activated`, then
navigates. Screen 08's ViewModel reads it once on creation and calls `consume()`, which clears it.
The router guard (§5) lets the route build only while the hand-off holds a credential.

**Rationale**: this answers the plan-time question the spec left open ("tracked without adding to
the persisted state the constitution allows"). "Shown once" falls out of the lifecycle: a relaunch
starts with an empty hand-off, so it can never re-show; a link or restored navigation in the same
process finds it already consumed. No flag, timestamp or counter is written anywhere.

**Alternatives considered**:
- *A persisted "activation screen shown" flag*: rejected. It is not on Principle I's allowlist and
  would require an amendment for no benefit.
- *Pass the credential as a `go_router` `extra`*: rejected. `extra` survives restored navigation on
  some platforms, which would re-show the screen and break FR-009.

## §5 — Router guard for screen 08, and every re-entry path

**Decision**: new route `AppRoutes.credentialActivated = '/enrollment/credential-activated'`,
guarded in `_redirect`:

| Situation | Destination |
|---|---|
| Hand-off holds a credential, and the local consent record is `active` | Screen 08 (no redirect) |
| Hand-off empty, `CredentialRepository.getStatus()` is `Valid`, or `Unreachable` with last known `Valid` | `AppRoutes.credentialDetail` (new placeholder, §11) |
| Hand-off empty, any other status | `AppRoutes.splash`, which applies 001's launch rule |
| Hand-off holds a credential but consent is not `active` | `AppRoutes.splash`, and the hand-off is cleared |

Relaunch never reaches this guard with a full hand-off, so it always follows 001's existing
splash/welcome rule (Clarifications: "a relaunch follows specification 001").

**Rationale**: covers spec US2 scenarios 1, 2, 4 and 5 with one guard, in the same place and style
as 004's and 006's guards. The consent check at entry is the structural half of FR-011 (§6).

**Alternatives considered**:
- *Redirect every empty-hand-off entry to the credential surface*: rejected. With no credential at
  all, US2 scenario 2 requires going back into the flow, not to a credential screen.

## §6 — FR-011 and a cross-feature fix to 002: withdrawal must delete the cached credential

**Decision**: `ConsentRepositoryImpl.withdraw()` (002) deletes the two credential keys of §3 in the
same local-effect step that writes the `withdrawalPending` record, before attempting backend
delivery. `CredentialService` gains a `clearCachedCredential()` method for this, and
`ConsentRepositoryImpl` receives `CredentialService` by constructor injection. The hand-off is also
cleared by the withdrawal ViewModel, although screen 08 has no path to the withdrawal surface.

**Rationale**: Principle I requires that "revoking MUST immediately invalidate the local
credential". Until now no feature wrote a credential, so 002's withdrawal had nothing to delete.
This feature introduces the writer (§3); without this fix, a passenger who withdraws consent and
relaunches would still be routed to trips by 001's rule on the strength of a cached token. That is
a direct violation this feature would create, so it is fixed here, not deferred. Within screen 08
itself, FR-011 holds structurally: the screen offers no route to the withdrawal surface, is shown
once, and re-checks consent at entry (§5).

**Alternatives considered**:
- *Have `CredentialRepository.getStatus()` consult the consent record*: rejected. It couples the
  credential port to consent and leaves the token on the device after withdrawal.
- *Leave it to a future credential-surface spec*: rejected, for the reason above.

## §7 — Entry, back gesture, and the end of the enrollment session

**Decision**: `VerificationProgressViewModel` navigates with `context.go(credentialActivated)`,
which replaces the navigation stack, so no capture or verification route remains behind screen 08.
Screen 08 renders no back button and wraps its body in `PopScope(canPop: false)`; on a pop attempt
it emits the back-gesture route event and calls `context.go(AppRoutes.trips)`. On `activated`,
`VerificationProgressViewModel` also calls `EnrollmentSessionController.clear()`, so a stale link
into any capture route is redirected by the existing 003/006 guards.

**Rationale**: FR-017 (clarified) is satisfied twice over: the stack holds nothing to go back to,
and the gesture itself is redirected forward. Clearing the session makes "enrollment is complete"
true in state as well as in the UI.

**Alternatives considered**:
- *`push` plus `popUntil`*: rejected. More moving parts than `go` for the same result.

## §8 — Masking, country names, and what assistive technology hears

**Decision**: the card renders the document as `•••• {last4} · {countryCode}`, for example
`•••• 7890 · COL`. The whole line has one `Semantics` label from localized copy: "Documento
terminado en 7890, Colombia" (FR-014). The country name comes from a small map in the feature
(`COL` → "Colombia"), falling back to spelling out the code for any code not in the map. The
holder name is a `Text` with `maxLines: 2` and `TextOverflow.ellipsis`, wrapped in `Semantics`
whose label is always the full name (Clarifications, long names).

**Rationale**: the masked form is built by the app from `documentLast4` only; the full number is
never in memory on this screen, so SC-005 holds by construction. A map beats a new
country-name dependency (Principle X's dependency justification rule) for a product that launches
in one country.

**Alternatives considered**:
- *A country-names package*: rejected until more than a handful of countries are supported.

## §9 — Dates

**Decision**: both dates use `intl`'s `DateFormat('d MMM y', 'es')`, already a dependency: "Creada
el 16 sep 2026" and "Válida hasta 16 sep 2031". Dates come from the backend's `issuedAt` and
`validUntil`, converted to local time for display. The screen never computes either one.

**Rationale**: FR-004 and FR-006. One format for both avoids two renderings of related facts.

## §10 — Copy, including the qualified subtitle

**Decision**: all strings go in `lib/l10n/app_es.arb`. Title as in the reference: "Tu identidad
digital está activa". Subtitle, qualified per FR-002 and CONFLICT-004: "A partir de ahora, pasa los
filtros de seguridad donde AeroPass está disponible sin mostrar documentos físicos." Actions: "Ir a
mis viajes" and "Ver mi identidad". No stat tiles, and no copy that names airport or airline
counts (FR-005).

**Rationale**: keeps the reference's promise while removing the universal claim. The final
wording remains a product decision; the ARB file is the single place to change it.

## §11 — Placeholder destinations this feature must add or change

**Decision**:
- **New** `CredentialDetailPlaceholderView` at `AppRoutes.credentialDetail = '/credential'`: the
  "Ver mi identidad" destination and the landing point for re-entry (§5).
- **New** `CredentialNotActivePlaceholderView` at
  `AppRoutes.credentialNotActive = '/enrollment/credential-not-active'`: the FR-010 destination
  until its own spec arrives (Clarifications).
- **Changed** `VerificationProgressPlaceholderView`: keeps placeholder visuals, gains
  `VerificationProgressViewModel` (§1) with a loading state and a retry on `Result.error`.
- **Changed** `TripsPlaceholderView`: replaces its developer-facing text with passenger-facing copy
  explaining how a trip becomes associated with the credential, because FR-008 is not relaxable.
  Proposed: "Aún no tienes viajes. Cuando tu aerolínea asocie un vuelo a tu identidad digital, lo
  verás aquí."

**Rationale**: every onward route in the spec must resolve to something real. These follow the
existing placeholder pattern (trips, withdrawal, help).

## §12 — Analytics

**Decision**: four new `AnalyticsEmitter` methods, specified in contracts/analytics-events.md:
`credentialIssuanceRequested()`, `credentialIssuanceOutcome({kind})`,
`credentialActivatedShown()`, and `credentialActivatedRouteTaken({route})`, where `route` is
`trips`, `credentialDetail`, or `backGestureToTrips`. No field carries a name, document digits,
country, date, or token.

`enrollmentCompleted` for FR-016 (p90 duration and abandonment) is **deferred** per the spec's
deferral table: computing a duration that spans app launches needs a durable correlation that the
per-launch `AnalyticsSessionId` does not provide, and choosing one is a Principle VII decision
better made once, with 007. `credentialActivatedShown` already marks the funnel's end within a
launch.

**Rationale**: FR-015's no-personal-data rule is not relaxable, so the events that exist are
complete in that respect even while the set is not.

## §13 — Screen-capture blocking (FR-012): a port now, Android now, iOS deferred

**Decision**: add a `ScreenCaptureGuard` port with `enable()` and `disable()`. Screen 08's view calls
`enable()` on entry and `disable()` on exit. The Android implementation sets and clears
`WindowManager.LayoutParams.FLAG_SECURE` through a new method on a platform channel in
`MainActivity.kt`, following the existing `aeropass/system_settings` channel's precedent. The iOS
implementation is a no-op for now; iOS cannot block screenshots, and hiding content while the
screen is being recorded is the part deferred under the spec's FR-012 deferral.

**Rationale**: the constitution says a relaxation is "configuration, never a deleted code path".
Building the port and its call sites now means exit from happy-path mode is an iOS implementation,
not new wiring. The Android half is a few lines with no new dependency, so there is no reason to
defer it.

**Alternatives considered**:
- *A screen-protection package*: rejected. Principle X requires justifying a dependency, and the
  Android half is trivial natively.
- *Defer FR-012 entirely*: rejected in favour of the above; see Complexity Tracking in plan.md for
  the remaining iOS gap.

## §14 — Dev fake for issuance

**Decision**: `DevCredentialIssuanceRepository`, selected by the existing
`USE_FAKE_VERIFICATION_BACKEND` flag, returns `activated` with the same synthetic identity as
`DevDocumentVerificationRepository`: holder "Mateo González Restrepo", last four "7890", country
"COL", issued now, valid for five years. It never reads local identity data.

**Rationale**: the spec's "direction of the assertion" rule: the fake is the backend, and it is
the fake that says "active". The long synthetic name also exercises the two-line wrap. No new
happy-path flag is needed, so `HappyPathFlags.assertReleaseSafe` already covers it.
