# Research: Extracted Data Confirmation (04 Confirmar datos)

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the product-level ambiguities were
already resolved in `/speckit-clarify` (see spec.md's Clarifications section). What follows are the
technical design decisions needed to implement this feature against the existing, already-shipped
003-escanear-documento codebase.

## §1 — Carrying the extraction result from capture (003) to confirmation (004)

**Decision**: `CaptureOutcome.accepted` (currently a zero-field variant in
`lib/domain/entities/capture_outcome.dart`) gains a required `extraction: ExtractionResult` field.
`CaptureViewModel._registerAccepted()` is changed to accept the just-captured frame's bytes and the
`ExtractionResult` from the outcome, and hands both to a new in-memory, app-singleton controller —
`PendingDocumentController` — before navigating to `AppRoutes.documentConfirmation`.
`DocumentConfirmationViewModel` reads (and, on confirm/re-scan/back-navigation, clears) that same
controller.

**Rationale**: 003's `DocumentVerificationRepository.submit()` contract, as shipped, has no way to
carry extracted fields — it was written before this feature existed and correctly scoped itself to
just the accept/reject decision (research.md's own words at the time: "no other layer needs a second
copy of it"). The extraction result is a natural payload of an *accepted* outcome (the processor only
returns fields once it has accepted the document as readable), so extending `accepted` is the smallest
change that keeps `CaptureOutcome` a single source of truth rather than inventing a parallel channel.
Handing the data forward through an in-memory singleton (rather than, say, a route "extra" parameter)
mirrors the existing `EnrollmentSessionController` pattern exactly and satisfies FR-011/data-model's
"held for session only" — nothing here is written to disk, and the same discard-on-every-exit-path
discipline 003 applies to the raw document bytes now applies identically to this controller.

**Consequence (cross-feature impact)**: this modifies already-shipped 003 code and its tests:
`CaptureOutcome`, `DocumentVerificationResponse`, `DocumentVerificationRepositoryImpl`'s mapping,
`FakeDocumentVerificationRepository`, and `document_verification_repository_contract_test.dart` all
need a matching update (every `CaptureOutcome.accepted()` construction site gains the new argument).
This is scoped and mechanical — no behavior 003 already ships changes — but every task that touches
these files must run 003's existing test suite (not just 004's new tests) before being considered
done. Documented here rather than silently done, per the Constitution's Boy Scout framing: this is a
required correction to a contract that was, in hindsight, one field short — not scope creep.

**Alternatives considered**:
- *A second, parallel "get last extraction" port fetched by 004 independently*: rejected — invents a
  second implicit hand-off channel alongside `CaptureOutcome`, with its own staleness/ordering
  questions ("what if 004 asks before 003 has stored it"), for no benefit over just widening the one
  outcome type that already carries this exact "the processor just looked at this document" moment.
- *Passing the extraction through `go_router`'s `extra` parameter*: rejected — `extra` does not
  survive a deep link or process death any better than an in-memory singleton, is not type-checked at
  the route table the way constructor injection is, and every other cross-screen, in-memory,
  session-scoped value in this app (`EnrollmentSession` itself) already uses the singleton-controller
  pattern; a second mechanism for materially the same problem would be an unforced inconsistency.

## §2 — Representing extracted fields, including the "gap" case (FR-009)

**Decision**: `ExtractedField` is a sealed type with two variants: `ExtractedField.present(key, value,
confidence)` and `ExtractedField.missing(key)`. `ExtractionResult` carries `fields:
List<ExtractedField>`, one entry per field the *processor* attempted to read for this document type —
never an entry silently omitted. A field value is always a plain string; for `FieldKey.expiryDate`
specifically, the string is the canonical `yyyy-MM-dd` form (see §3), not a pre-formatted display
string.

**Rationale**: FR-009 requires an extraction gap to be shown as an explicit gap, "rather than as an
empty value" — that only works if the domain model can distinguish "the processor tried and failed to
read this field" from "this field has an empty string." A sealed present/missing variant makes that
distinction structural (Constitution Principle IX) rather than a convention callers might forget (e.g.
checking `value.isEmpty`). It also sidesteps needing a second, app-side notion of "which fields does
this document type have" (the edge case: "the document is a type whose fields differ") — the confirm
screen renders exactly the `fields` list it's handed, in whatever order/count the processor returns,
rather than the app maintaining its own per-document-type field-set table that could drift from the
processor's.

**Alternatives considered**:
- *Omit the key entirely from `fields` when missing, and have the view infer "gap" from a fixed
  expected-field-set constant*: rejected — re-introduces exactly the drift risk above, and silently
  conflates "processor didn't return this key" with "processor doesn't have this key for this document
  type," which are different failure modes worth distinguishing at the contract level.
- *A nullable `value` on a single non-sealed `ExtractedField`*: rejected on Principle IX grounds — a
  nullable field with no accompanying "why is it null" is exactly the boolean-flag-shaped bug pattern
  the sealed-types rule exists to prevent; a future field for "confidence: 0.0" could easily collide
  with "missing" under a null-value convention.

## §3 — Expiry date representation and the validity check (FR-008)

**Decision**: the `expiryDate` field's value (when present) is a plain ISO-8601 date string
(`yyyy-MM-dd`), parsed once by `ExtractionResult.parsedExpiryDate` (a getter, not a separate persisted
field) using `DateTime.parse`. `DocumentConfirmationViewModel` compares this against `Clock.now()`
(the existing injected `Clock` abstraction, not `DateTime.now()` directly — same reasoning 003's
attempt-counter tests already rely on: an injectable clock is what makes expiry-boundary tests
possible without waiting for a real date). The *displayed* value ("14 mar 2031") is produced by the
view from the same ISO string via `intl`'s `DateFormat`, in the `es` locale already configured for
this app's localization — not a second domain-level field.

**Rationale**: keeping exactly one representation of the expiry value in the domain model (the ISO
string) avoids a redundant pair of fields that could disagree with each other; formatting for display
is presentation, not business logic, and belongs in the view layer per Principle VIII. `intl` ships
transitively with `flutter_localizations`, which this project already depends on for its generated
`AppLocalizations` — no new package.

**Alternatives considered**:
- *A `DateTime` field on `ExtractedField` used only for `expiryDate`, alongside the string `value` used
  for every other field*: rejected — makes `ExtractedField` field-type-dependent in a way that defeats
  the point of a uniform sealed variant, and still needs a display-formatting step regardless.
- *Have the processor return the value pre-formatted for Spanish display ("14 mar 2031") and parse
  *that* for the expiry check*: rejected — parsing a localized, abbreviated month name back into a
  `DateTime` is more fragile than parsing ISO-8601, and ties the validity check to whatever locale the
  processor happens to format in.

## §4 — The field re-verification port (FR-005)

**Decision**: a new, narrow port — `FieldReverificationRepository` — separate from
`DocumentVerificationRepository`, with one method:
`Future<Result<FieldReverificationOutcome>> reverify({required Uint8List documentImageBytes, required FieldKey field, required String candidateValue})`.
`FieldReverificationOutcome` is sealed: `.confirmed()` | `.disagreed()`. `Result.error` is reserved for
transport failure exactly as `DocumentVerificationRepository.submit` already does — and, per the
Clarifications' resolution, a transport failure here is treated identically to a `.disagreed()` outcome
by the ViewModel (both count as "the re-check could not confirm it").

**Rationale**: this is a genuinely different call shape from `submit()` — a single named field plus a
candidate value plus the already-retained image, versus a whole fresh document submission — and
Principle X's interface-segregation rule ("a consumer depends on the narrowest port that covers its
need") argues against bolting a second method onto `DocumentVerificationRepository` that most of its
existing callers (003) never use. Keeping it a separate port also means 003's contract and its already
-shipped test suite are untouched by this feature beyond the `CaptureOutcome.accepted` payload change
in §1 — no new method appears on the port 003 depends on.

**Alternatives considered**:
- *Add `reverifyField(...)` as a second method on `DocumentVerificationRepository`*: rejected per the
  interface-segregation reasoning above.
- *Re-run the exact same `submit()` call and diff the returned extraction against the candidate value*:
  rejected — wasteful (a whole-document re-read to check one field) and, more importantly, wrong
  shape: `submit()`'s contract is "accepted/rejected," not "does field X read as Y," so reusing it would
  require inventing a way to distinguish "still accepted, but field X now disagrees" from a fresh
  document-level rejection, which is exactly the ambiguity a purpose-built method avoids.

## §5 — Durable confirmation and the local display-only cache (FR-017, Constitution Principle I)

**Decision**: a new port, `IdentityRecordRepository`, with one method:
`Future<Result<IdentityRecord>> confirm(IdentityRecord record)`. The real implementation
(`IdentityRecordRepositoryImpl`) submits the full record — every field's final value, its source
(`machineRead` / `passengerCorrected`), and, for a corrected field, whether it was automatically
re-verified — to the backend (mirroring `ConsentRepositoryImpl.recordConsent()`'s "submit first, only
treat as durable if the backend confirms" shape). Only on a successful backend response does it also
write a **display-only subset** (the four field values, no source/original/audit data) to
`flutter_secure_storage`, under a new key. This is the exact persisted-state category the
constitution's Principle I allowlist already names: "a display-only subset of identity fields the user
already saw on the confirmation screen." No other new persisted state is introduced.

**Rationale**: FR-017 requires confirmation to be durable before the flow advances, and the existing
consent-recording precedent already establishes the pattern (submit to backend; local effects only
follow success). The audit-trail distinction SC-002 requires (machine-read vs. passenger-corrected,
with the original value retained) is exactly the kind of data Principle I does *not* license for local
storage — it stays backend-side, submitted once, never cached on-device. Writing only the
already-explicitly-allowed display subset locally keeps this feature inside the existing constitutional
allowlist with no amendment required (unlike 003, which needed one for its attempt counter).

**Alternatives considered**:
- *Persist the full `IdentityRecord`, including source markers and original values, locally*: rejected
  — squarely outside Principle I's allowlist; would require a constitution amendment this feature has
  no independent justification for (the display-only subset already covers every legitimate on-device
  need: showing the passenger their own data later).
- *Treat confirmation as backend-only with no local write at all*: rejected — the constitution's
  allowlist entry exists specifically because a later feature (the credential/pass surfaces) will need
  to *display* this data without a network round-trip; deferring the local write to that future feature
  would mean retrofitting this screen's confirm path later for no reason, when the write belongs
  naturally at the moment of confirmation.

## §6 — Session-scoped correction-attempt cap (FR-019) and its interaction with FR-005

**Decision**: `DocumentConfirmationViewModel` holds a plain in-memory `int` counter (no repository, no
persistence — unlike 003's durable, secure-storage-backed counter). It increments once per "unresolved"
correction attempt: an edit to a field whose original confidence was ≥0.95 (per Clarifications) where
`FieldReverificationRepository.reverify(...)` returns `.disagreed()`, returns `Error` (transport
failure), or where the automated re-check is still resolving and a second edit interrupts it. Reaching
3 routes to re-scan (discarding the extraction and all edits, per FR-010) exactly as 003's own
attempt-limit routes to retry guidance. Below the cap, confirmation is blocked (FR-007) *only* while a
field has an unresolved edit outstanding — the passenger may still retry editing (that field or another)
without being forced to re-scan on the first miss; reverting a field's edit back to its original
extracted value clears that field's unresolved state without counting as a resolved attempt.

**Rationale**: this reconciles FR-005 ("confirmation MUST be blocked... directed to re-scan" on an
unconfirmed high-confidence edit) with FR-019 and its own Acceptance Scenario 6 ("after the *third*
unresolved attempt... routed to re-scan rather than permitted to keep editing") — read together, FR-005
describes what happens to *that field* and to confirmation-eligibility immediately, while FR-019 is the
outer bound on how many separate unresolved attempts the whole session tolerates before forcing a
re-scan outright. Reading FR-005 as "the very first miss ends the session" would make FR-019's cap of 3
meaningless (there would never be a 2nd or 3rd attempt to count); reading FR-019 in isolation without
FR-005's per-field block would let a passenger confirm with a field still in dispute. The session-scoped
(not durable) choice matches the Clarifications' explicit answer: this cap was raised as a
loop/cost bound within one sitting, never as a cost-control concern requiring survival across an app
kill the way 003's capture-attempt counter was.

**Alternatives considered**:
- *Durable, secure-storage-backed counter mirroring 003's exactly*: rejected — the Clarifications
  answer explicitly scoped this to session-only; a durable counter here would be unrequested persisted
  state.
- *One miss immediately forces re-scan (no retry budget)*: rejected — contradicts FR-019/Acceptance
  Scenario 6's explicit "third unresolved attempt" language, and would make correcting an OCR error
  strictly harder than 003's own capture retries.

## §7 — Reusing the step indicator

**Decision**: `StepIndicator` (currently `lib/features/enrollment/capture/widgets/step_indicator.dart`)
moves, unchanged, to `lib/core/design/step_indicator.dart` — the shared module Principle VIII reserves
for cross-feature UI primitives. `capture_view.dart`'s import is updated to the new path;
`document_confirmation_view.dart` imports the same shared widget. No parameterization is added: per
spec.md's UI Reference, this screen's step indicator shows the identical state 003's does ("Documento"
active) — this screen is still within the document step, not the selfie step — so the widget's current
hardcoded content is correct for both call sites as-is.

**Rationale**: this is the second real call site for the exact same widget with the exact same
rendered output, which is what Principle X's KISS/DRY guidance treats as the point past which shared
UI belongs in the common module rather than being copied — copying it would be the actual duplication
the constitution warns against, not extracting it. Adding an `activeStep` parameter now, for a selfie
step (005) that doesn't exist yet, would be exactly the speculative generality Principle X rejects
("two real call sites... not one call site and an anticipated second" — the anticipated second call
site's *needs* aren't known yet, only that it will exist); that parameter is 005's problem to add when
it has a second concrete requirement to satisfy.

**Alternatives considered**:
- *Duplicate the widget as a second, confirmation-feature-private copy*: rejected — identical output,
  identical code; this is the duplication case DRY exists for, not a case for "wait for the third
  occurrence" (that guidance is about premature *abstraction*, not about copy-pasting an unchanged,
  already-shared-in-spirit widget a second time).
- *Add an `activeStep`/`EnrollmentStep` parameter now*: rejected per KISS reasoning above — deferred to
  005.

## §8 — The "Ayuda" affordance

**Decision**: the top-bar "Ayuda" control navigates to the existing `AppRoutes.help` route (already
built and wired in `router.dart` as `HelpPlaceholderView`, per 003), returning to this screen with the
in-memory pending extraction/image intact — i.e. treated as a lateral navigation, not an exit path that
discards state (unlike back navigation, which does discard per FR-013).

**Rationale**: spec.md's UI Reference lists "Ayuda" in the top bar identically to 003's screen, and
003 already established the pattern (help route, session preserved on return) this screen has no reason
to diverge from. This isn't a new requirement being invented at planning time — it's the same,
already-built affordance every other enrollment screen in this app exposes, wired the same way.
