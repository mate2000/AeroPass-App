# Research: Selfie Instructions (05 Instrucciones selfie)

No `NEEDS CLARIFICATION` markers remain in the Technical Context — the one open product question
(the happy-path exit milestone) was resolved in `/speckit-clarify`, and the resulting governance
conflict with Principle III was resolved via a constitution amendment (v1.3.0 → v1.4.0, "Happy-Path
Development Mode") before this plan was written. What follows are the technical design decisions
needed to implement this screen.

## §1 — No reachability guard for this screen

**Decision**: unlike 003's consent-currency guard and 004's `PendingDocumentController`-empty
guard, this screen adds **no** router-level or ViewModel-level guard against being reached out of
order.

**Rationale**: both prior guards exist because their screens need *data* that only a completed
prior step produces (a current consent record; a retained document image and extraction). This
screen displays only static, passenger-independent copy (FR-001–FR-003) — it reads nothing from
the confirmed identity record, per spec.md's own Assumptions ("this screen's job is preparation,
not instruction on how to operate a shutter"). Reaching it out of order has no data-integrity or
safety consequence: at worst, a passenger sees preparatory instructions slightly early. Adding a
guard here would be inventing a dependency the screen doesn't actually have, which Principle X's
KISS guidance rejects.

**Alternatives considered**:
- *Guard on `EnrollmentSessionController.current != null`*: rejected — that controller is
  documented as a resume-messaging convenience, not a security gate (its own doc comment: "Tracks
  progress ... for the resume behavior," never described as authoritative for reachability), and
  003/004's real guards both check durable/data-bearing state instead, not this ephemeral counter.
- *Guard on the confirmed identity record's presence*: rejected — 004's `IdentityRecordRepository`
  has no "read back what I just confirmed" method, and adding one solely to support a guard this
  screen doesn't otherwise need would be scope creep for a screen with no false-accept exposure.

## §2 — Parameterizing the shared `StepIndicator`

**Decision**: `StepIndicator` (moved to `lib/core/design/` in 004's research.md §7, at the time
still hardcoded to always show "Documento" active) gains a required `currentStep` parameter of a
new small enum, `EnrollmentProgressStep { document, selfie, done }`. Each segment's visual state —
complete / active / upcoming — is computed from ordinal comparison against `currentStep`, not
passed in per-segment. 003's `CaptureView` and 004's `DocumentConfirmationView` are both updated to
pass `currentStep: EnrollmentProgressStep.document` explicitly (no default value, so a future
caller can't silently render the wrong step by omission).

**Rationale**: 004's research.md deliberately deferred this exact parameterization "to 005 to add
when it has a second concrete requirement" — this is that requirement (FR-009: "document step
complete and the selfie step active," a genuinely different rendered state from 003/004's
"document active"). Two real call sites want different output now, which is precisely Principle
X's bar for introducing a parameter rather than duplicating the widget.

**Alternatives considered**:
- *A boolean-per-segment API (`documentComplete`, `selfieActive`, ...)*: rejected — re-admits the
  "trio of booleans" shape Constitution Principle IX rejects for exactly this reason (it can
  represent states the product doesn't have, like "selfie active" and "document active"
  simultaneously); an ordinal enum can't.
- *Duplicate the widget a second time for this screen*: rejected — this is now the third would-be
  copy of materially the same widget; 004 already flagged the second copy as the point past which
  sharing wins over duplication.

## §3 — The framing-preview illustration

**Decision**: a small `CustomPainter`-based dashed oval (no new package), with a centered face
glyph (`Icons.face` or equivalent), wrapped in `ExcludeSemantics` per FR-006/the accessibility edge
case ("the illustration carries none of [the content] and is not announced as meaningful").

**Rationale**: Flutter has no built-in dashed-border primitive; a `CustomPainter` drawing a dashed
`Path.combine`/`dashPath`-style oval is a well-understood, small (well under Principle X's
file-size concerns), self-contained implementation — adding a dependency (e.g. a dashed-border
package) for one decorative shape fails Principle X's KISS bar ("an abstraction requires two real
call sites... not one call site").

**Alternatives considered**:
- *A solid (non-dashed) oval border*: rejected — cheaper, but visibly diverges from the UI
  reference for no real savings once the painter is this small anyway.
- *A dashed-border package dependency*: rejected per KISS — one call site, and the shape is simple
  enough to own directly.

## §4 — Closing the happy-path release-safety gap (constitution v1.4.0)

**Decision**: a new `lib/core/happy_path_flags.dart` centralizes every happy-path relaxation flag
— today, `USE_FAKE_CONSENT_BACKEND` (002) and `USE_FAKE_VERIFICATION_BACKEND` (004), both currently
private constants duplicated inline in `composition_root.dart` — behind a single
`HappyPathFlags.assertReleaseSafe({bool releaseMode = kReleaseMode})` function, called once at the
very start of `main()`, before `runApp`. It throws (refusing to run) if `releaseMode` is true and
any flag is enabled. `composition_root.dart` is updated to read the flags from this module instead
of its own private constants, so there is exactly one place either flag is defined.

**Rationale**: the constitution's new Happy-Path Development Mode carve-out (v1.4.0) requires
"every relaxation lives behind a build flag that cannot be enabled in a release build, and the
release pipeline MUST fail if one is enabled once such a pipeline exists; until then, the app
itself MUST fail fast." This project has no CI/release pipeline yet (confirmed: no CI config exists
in the repository), so the interim, honest fulfillment of that obligation is the runtime guard
described here — not a silent gap, and not a claim of CI enforcement that doesn't exist.
`{bool releaseMode = kReleaseMode}` (rather than reading `kReleaseMode` directly inside the
function body) makes the check unit-testable — mirroring the Constitution's own stated reason for
injecting the `Clock`: "the clock in particular, because pass expiry is untestable otherwise,"
applied here to the exact same problem (`kReleaseMode` is otherwise a compile-time constant no test
can flip).

**Consequence (cross-feature impact)**: this touches 002's and 004's existing flag definitions
(moving them, not changing their names or behavior) — `composition_root.dart` is the only call
site, so this is a mechanical, low-risk relocation, not a behavior change to either prior feature.

**Alternatives considered**:
- *`assert(...)` instead of a runtime `if`/`throw`*: rejected — `assert` is stripped from release
  builds entirely, which is the exact opposite of what "fail fast in a release build" requires.
- *Leave the flags where they are, one per feature*: rejected — the constitution amendment frames
  this as a single, standing obligation ("every relaxation"), not a per-feature one; a future
  feature's flag added inline in `composition_root.dart` with no shared enforcement point would
  silently miss the guard.
- *A real CI/release-pipeline check (e.g., a script gating `flutter build --release`)*: the
  eventual correct home for this per the constitution's own wording ("once such a pipeline
  exists"), but there is no pipeline in this repository yet to add it to; out of scope for this
  feature, tracked as a deferred requirement (Assumptions) rather than invented here.

## §5 — Navigation pattern: Command-completion listener, not a navigation-target enum

**Decision**: `SelfieInstructionsViewModel` exposes exactly one forward `Command0<void> advance`.
`SelfieInstructionsView` listens to `advance`'s completion (mirroring `ConsentView`'s
`_onConfirmChanged` pattern) and pushes to the liveness-capture placeholder route when it
completes — rather than the `pendingNavigation` enum pattern 003/004 use.

**Rationale**: 003/004 needed a `pendingNavigation` enum because their single primary action can
resolve to *multiple* distinct destinations depending on an outcome only known at runtime (accepted
vs. rejected; confirmed vs. blocked). This screen's one action has exactly one destination — there
is no outcome to branch on (FR-004/FR-005: the screen transmits nothing and gates nothing). Using
the simpler, pre-existing Command-completion-listener pattern this codebase already has (001/002)
for the single-destination case is the correct level of mechanism for what this screen actually
does, per Principle X's KISS guidance against building for a branching future the requirements
don't describe.

**Alternatives considered**:
- *A `pendingNavigation` enum with one variant*: rejected — a sealed type (or enum) with exactly
  one meaningful value is the inverse of Principle IX's "sealed types over boolean flags" concern:
  it adds a mechanism to represent a choice that doesn't exist.

## §6 — Analytics: a new "help opened" event shape

**Decision**: `AnalyticsEmitter` gains four methods for this screen — entry, advance, help-opened,
and abandonment — per FR-010. `selfieInstructionsHelpOpened()` is a new *kind* of event: 003/004
never emitted one for tapping "Ayuda," since neither spec's FR list required it. 005's FR-010
explicitly lists "help" as one of the four required events, so this is the first screen to wire it.

**Rationale**: the spec requires it explicitly; there's no ambiguity to resolve, only a mechanical
gap versus precedent to note so it isn't mistaken for scope creep. `AnalyticsEmitter`'s existing
narrow-interface-segregation shape (one method per contract event, Principle X) is preserved.

## §7 — This feature's Happy-Path Development Mode deferrals

Per the constitution's new carve-out and spec.md's own Assumptions, this feature's deferrals are:

- Front-camera-absence gating (FR-related edge case): not implemented; assumed supported. No flag
  needed — this is an omission, not a stubbed relaxation, since the screen has no camera code of
  its own to gate.
- The help route remains the existing stub (`HelpPlaceholderView`), unchanged.
- Analytics are limited to the four FR-010 events; the "no personal data" half is not relaxed (no
  new flag needed — every event this screen emits already carries only the anonymous session id).
- No new `USE_FAKE_*` flag is introduced by this feature itself; §4 above closes the release-safety
  gap for the two flags 002 and 004 already introduced.
