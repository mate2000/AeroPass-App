<!--
Sync Impact Report
- Version change: 1.3.0 → 1.4.0
- Modified principles: III. Every Flow Has a Failure Path — added a bounded, temporary
  "Happy-Path Development Mode" carve-out permitting specific, named relaxations (attempt
  limits/retry routing/escalation destinations, the full error taxonomy, offline/connectivity
  handling, device capability gating and permission-denied paths, timing/performance budget
  enforcement, analytics event completeness, and backend integrations served by fakes), each
  gated behind a build flag that cannot be enabled in a release build. The principle's existing
  obligation is otherwise untouched: a feature MUST still eventually implement every deferred
  requirement, tracked by identifier, before the airport pilot integration. No existing obligation
  was removed or redefined for any feature not invoking this mode.
- Added principles: none
- Added sections: none (new subsection added within Principle III, not a new top-level section)
- Removed sections: none
- Rationale: 005-instrucciones-selfie's spec.md declares a project-wide "Happy Path First"
  delivery mode — applying to it and every enrollment-flow spec that follows — that directly
  conflicts with this principle's existing text: "The retry, agent-escalation, and
  technical-error screens are part of the happy path's definition of done — a feature whose
  failure states are unimplemented is not complete, regardless of whether its success path
  ships." Surfaced during /speckit-plan's Constitution Check, the same category of conflict
  003-escanear-documento hit with Principle I (resolved via the 1.2.0→1.3.0 amendment above) —
  per Governance, "where a spec ... conflicts with it, this document wins and the conflicting
  artifact is amended," so the choice was amend-or-reject, not silently proceed. Principles II,
  IV, and V were checked and require no change: II and IV already permit and require fakes/tests
  against them, which this carve-out merely confirms rather than relaxes; V's no-network
  requirement is scoped to the issued credential/QR-pass surface specifically, which this
  carve-out does not touch (general offline-handling deferral elsewhere in the app is a distinct,
  unrelated concern).
- Templates requiring updates: none checked in this change — plan-template.md's Constitution
  Check section reads this file at runtime per the constitution command's scope guard.
- Follow-up TODOs: none — no placeholders deferred
-->

# AeroPass Mobile App Constitution

AeroPass is a B2B airport digital-identity product: the passenger enrolls once (identity document +
liveness selfie), receives a digital credential, and passes security and boarding with a dynamic QR
pass instead of physical documents. The mobile app is the passenger's entire surface of the product.
This constitution governs that app.

Scope of this constitution: the Flutter mobile application only. Backend services, the verification
provider, and the airport-side validation module are treated as external contracts the app consumes,
not as code this constitution governs.

## Core Principles

### I. Consent and Data Minimization

The app MUST NOT capture the camera, read a document, or transmit any biometric sample before the
user has given explicit, unbundled consent, and that consent gate MUST be blocking (no skip, no
default-checked box). Raw artifacts — document images, selfie frames, liveness video — MUST be
treated as in-transit only: held in memory for the duration of the verification call and discarded
on completion, cancellation, or error. They MUST NEVER be written to disk, the media gallery, a
cache directory, a crash report, or an analytics payload.

Persisted state is limited to: the credential token issued by the backend, its validity window, a
display-only subset of identity fields the user already saw on the confirmation screen, the user's
consent record with timestamp and version, and a per-step capture-attempt counter (an integer count
and a last-reset timestamp only — never an image, an extraction result, or any other capture
content) used solely to cap retries on a capture step and scoped to the specific step it protects.
Anything a feature wants to persist beyond that list requires an explicit amendment to this
document, not a code review waiver.

Consent is revocable from inside the app, without contacting support, and the revocation entry point
MUST be reachable from the account surface in no more than two taps. Revoking MUST immediately
invalidate the local credential and any displayed pass. The facial template retention limit the
product commits to — 30 days after the passenger's last flight — is enforced by the backend, but the
app MUST surface the retention terms at the consent gate and MUST NOT present a credential the
backend reports as expired.

Rationale: the product's entire value rests on passengers trusting it with a face and a government
document. Colombian habeas data obligations (Ley 1581) make this a legal boundary, not a preference
— and an app that stores nothing cannot leak what it does not have.

### II. The Verification Provider Is an Adapter

OCR, liveness, and face matching are delivered by an external SaaS provider, and that provider MUST
sit behind a domain-owned port. No provider SDK type, error enum, exception, or DTO may appear in
the domain or presentation layers. The app MUST build, run, and pass its full test suite against a
fake implementation of that port with no network and no provider SDK linked.

Any provider-specific behavior — retry semantics, confidence thresholds, error taxonomy — MUST be
normalized into domain vocabulary at the adapter boundary. Replacing the provider MUST be a change
confined to the adapter package and its tests.

Rationale: the provider is a per-validation variable cost and a commercial negotiation, so it will be
renegotiated or replaced. It is also the single largest source of vendor lock-in in the codebase.
Containing it is cheaper to do once, at the start, than to retrofit under commercial pressure.

### III. Every Flow Has a Failure Path

Failure is a designed state, not an exception handler. Every asynchronous operation MUST define four
states explicitly: loading, success, recoverable failure, and terminal failure. Recoverable failure
MUST name the recovery the user takes next (retry, retry with guidance, escalate to a human agent).
Terminal failure MUST name the human channel that resolves it.

No screen may leave the user with no forward action. A snackbar or toast is NEVER an acceptable
presentation for the failure of an identity, capture, or credential operation. The retry,
agent-escalation, and technical-error screens are part of the happy path's definition of done — a
feature whose failure states are unimplemented is not complete, regardless of whether its success
path ships.

**Happy-Path Development Mode.** A feature's spec may declare happy-path development mode, under
which the following MAY be deferred rather than shipped with the feature: attempt limits, retry
routing, and escalation destinations (a failure MAY log and return to the same screen instead of
routing); the full error taxonomy (a single generic failure state MAY stand in for the specific,
actionable messages this principle otherwise requires); offline and connectivity handling (the
network MAY be assumed present); device capability gating and permission-denied paths (permissions
MAY be assumed granted and the device assumed supported); the timing and performance budgets in
Principle V and the Product Budgets section (measured once the flow exists, not enforced while it
is being assembled); analytics event completeness (events MAY be incomplete, but any event that is
emitted MUST already satisfy Principle VII); and backend integrations (MAY be served by a fake,
provided the fake satisfies the same contract Principle II already requires of one).

This mode changes nothing else. It does NOT relax: real personal data in development or testing
(synthetic documents and test faces only, in every mode); persistence of images or biometric
samples (memory-only in every mode, exactly as this principle and Principle I already require);
personal data in logs, events, or crash reports, in any mode (Principle VII, unrelaxed);
Principle I's consent gate (a fake recorder MAY back it, but the flow MUST still pass through it
in order — the ordering is not something to add afterwards); or the Product Budgets absolute that
no path presents a valid credential or pass without backend affirmation.

Every relaxation MUST live behind a build flag that cannot be enabled in a release build, and the
release pipeline MUST fail if one is enabled once such a pipeline exists; until then, the app
itself MUST fail fast — refusing to run rather than silently shipping the relaxation — if a
release build is produced with one enabled. A relaxation is configuration, never a deleted code
path: the code this principle requires still gets written, later, behind the same flag flipped
off, not invented from scratch at exit.

A feature invoking this mode MUST enumerate its own deferred requirements, by requirement
identifier, in its spec — a deferral nobody wrote down is not a deferral, it is the exact defect
this principle exists to prevent. Before any build reaches a real passenger — concretely, before
the airport pilot integration, the first point a real passenger's document or face reaches the
app — every deferred requirement across every feature that invoked this mode MUST be either
implemented or accepted in writing as out of scope for that release. A working demo on synthetic
data does not end this mode; only that integration, or an explicit written acceptance per
deferral, does.

Rationale: biometric enrollment fails for ordinary reasons — bad light, a worn document, a face the
model rejects — and it fails in a queue, with a flight boarding. A dead end there is a passenger who
misses a flight and an airport that does not renew. Happy-path mode exists because the same
enrollment flow cannot be demonstrated end-to-end, feature by feature, if every feature must also
ship its full failure taxonomy first — but a relaxation that is not flagged, tracked, and closed
before a real passenger arrives is the dead end this principle forbids, arriving late instead of
early.

### IV. Test-First on the Trust Boundary

For code that decides identity state, credential validity, QR issuance or expiry, consent capture,
or the classification of a verification outcome, tests MUST be written and MUST fail before the
implementation is written. This is non-negotiable for that code and the commit history is expected
to show it.

Required coverage on those paths:

- Unit tests for every domain state transition, including each failure branch.
- Contract tests for the verification port, run against the fake and asserted to be the same suite
  the real adapter satisfies.
- Widget tests for each of the app's screens covering at minimum its empty, loading, error, and
  populated states.
- Golden tests for the credential and QR pass surfaces.

Outside that boundary — layout, copy, animation polish — tests are expected but the ordering is not
mandated.

Rationale: a bug in the trust boundary does not degrade the product, it invalidates it. Tests written
after the fact document what the code does; tests written first document what it must do.

### V. Airport-Grade Experience Constraints

The app is used one-handed, in a moving queue, on a mid-range Android phone, under either terminal
floodlight or a dim jetbridge. Therefore:

- The QR pass MUST render, count down, and remain usable with no network once issued. Loss of
  connectivity after issuance MUST NOT invalidate the displayed pass or block its expiry countdown.
- The credential and QR pass screens MUST raise screen brightness on entry and restore it on exit.
- All primary actions MUST be reachable within the bottom half of the screen.
- No animation may block input. Timed auto-advance transitions MUST be interruptible and MUST NOT be
  the only way to reach the next screen.
- Cold start to a usable QR pass for an already-enrolled user MUST stay under three seconds on the
  defined minimum-spec device; the app MUST hold 60fps on capture and credential screens on that
  device.
- Flight data shown on or beside the pass — gate, time, status — MUST NOT be presented as current
  when it is stale. The app MUST refresh on foreground and MUST visibly mark data it could not
  refresh rather than silently displaying an old gate.

Rationale: every second of friction in this app is a second in a security line, which is the exact
metric the product is sold on (OKR axis A1). Performance here is a commercial commitment, not an
engineering aspiration.

### VI. Accessibility Is a Gate, Not a Polish Pass

Text and meaningful UI MUST meet WCAG AA contrast in both the navy and light surfaces. Every
interactive element MUST carry a semantic label, and every capture instruction MUST be conveyed
through at least two channels — text plus haptics or audio — never through animation alone.

State MUST NEVER be signaled by color alone: the distinction between a recoverable retry and a
terminal error must survive being rendered in grayscale. Dynamic type up to the platform maximum
MUST NOT clip or overlap content. Screen-reader traversal of the enrollment flow is part of
acceptance for that flow.

Rationale: the product's premise is that any passenger can use it. A biometric identity flow that a
low-vision passenger cannot complete pushes that passenger into the manual lane the product exists to
empty — and an airport client's accessibility obligations become ours the moment we are the front
door.

### VII. Observability Without PII

The app MUST emit structured events for each step of enrollment, retry, escalation, and pass
issuance, keyed to an anonymous session identifier that is not derivable from the passenger's
identity.

Event payloads, log lines, crash reports, and breadcrumbs MUST NEVER contain document numbers,
names, dates of birth, face data, credential tokens, QR payloads, or raw provider responses. A
payload containing a field this constitution forbids persisting is a defect of the same severity as
leaking it.

Funnel completion and drop-off per step MUST be derivable from these events alone — the product's
friction targets are measured from them and cannot be measured retroactively. Specifically, the
events MUST be sufficient to compute enrollment duration at p90, enrollment abandonment rate, the
share of validations resolved without an agent, and repeat use across flights, without any additional
instrumentation added later.

Rationale: the business case commits to reducing friction; a claim about friction that cannot be
measured is a claim that cannot be sold or renewed. Instrumenting after launch means the baseline is
gone.

### VIII. Architecture Follows the Flutter App Architecture Guide

The app follows the layering published in Flutter's official architecture guidance. The layers and
their obligations:

- **View** — widget composition only. A view MAY contain layout, animation, routing, and simple
  display conditionals. It MUST NOT contain business logic, MUST NOT call a repository or service,
  and MUST NOT hold state that outlives a single frame's presentation concerns.
- **ViewModel** — one per view. Holds UI state, transforms domain models into what the view renders,
  and exposes the actions the view invokes. A ViewModel MUST NOT import `package:flutter/material.dart`
  or any widget, and MUST be testable without pumping a widget.
- **Repository** — the source of truth for a domain model. Owns caching, retry, refresh, and the
  translation of service responses into domain models. Repositories MUST NOT depend on one another;
  shared behavior moves down into a service or up into a use-case.
- **Service** — one per external data source, stateless, wrapping a REST API, a platform channel, the
  verification provider SDK, or secure storage. Services hold no state and expose Future/Stream.
- **Use-case** — optional, and introduced only when logic is genuinely shared across ViewModels or
  spans more than one repository. Creating one per repository call is over-engineering and is
  rejected in review.

Dependencies point one direction only: View → ViewModel → Use-case (when present) → Repository →
Service. No layer may import a layer above it, and no layer may skip a layer below it — a view that
reaches a repository directly is a defect regardless of how small the call is.

Code is organized feature-first, with the AeroPass features being enrollment, rejection-and-escalation,
and trips-and-pass. Shared UI primitives and design tokens live in a common module that no feature may
write to.

Rationale: Principle II requires a swappable provider and Principle IV requires ViewModels testable
without a device — both of which follow from this layering rather than from discipline. Picking the
framework's own published architecture also means new contributors and coding agents arrive already
knowing it, which matters when the plan is to replicate deployments across airports.

### IX. Mandated Code Patterns

These patterns are obligations, not suggestions. A deviation requires a Complexity Tracking entry in
the plan, not a code review comment.

- **Result objects at layer boundaries.** Repositories and use-cases MUST return a sealed `Result<T>`
  (Ok / Error) rather than throwing across a layer boundary. Exceptions are caught at the service
  boundary and converted. A bare try/catch in a ViewModel is a review blocker.
- **Command objects for view actions.** Every ViewModel action a view can invoke MUST be exposed as a
  Command that carries its own running, completed, and error state. This is the mechanism by which
  Principle III's four states are guaranteed structurally rather than remembered case by case.
- **Immutable state.** UI state and domain models MUST be immutable, with value equality and
  `copyWith`, generated rather than hand-written. Mutable public fields on a state or model class are
  forbidden.
- **Sealed types over boolean flags.** States with more than two meaningful variants — verification
  outcome, credential status, pass validity — MUST be modeled as sealed classes and switched over
  exhaustively. A trio of `isLoading` / `hasError` / `isEmpty` booleans on the same object is a
  defect, because it admits states the product does not have.
- **Constructor injection.** Dependencies are passed in through constructors. A widget or ViewModel
  that reaches into a global service locator or singleton to find a dependency is a review blocker;
  composition happens at the app's entry point and at route boundaries.
- **Offline-first for the issued pass.** The QR pass and credential surfaces MUST read from local
  state as the source of truth for display, with the network as a refresh path — satisfying
  Principle V's no-network requirement by design rather than by fallback.
- **No optimistic state on identity operations.** Optimistic UI is permitted for reversible,
  low-stakes interactions only. Enrollment, verification, credential issuance, and pass generation
  MUST show real state; the app MUST NEVER display a verified identity or a valid pass that the
  backend has not confirmed.

Rationale: these are the patterns that make Principles III and IV mechanical. A Command cannot
silently omit its error state, a sealed type cannot be switched incompletely without the analyzer
objecting, and a Result cannot be ignored the way an unchecked exception can. The point is to move
correctness out of reviewer attention and into the type system.

### X. Craft Standards Apply to Every Line

The following are obligations on all code in this repository, not aspirations posted on a wall. Each
is stated in the form that makes it reviewable — a standard that cannot be pointed at in a diff does
not belong in this document.

**The Boy Scout Rule.** Every PR MUST leave the files it touches cleaner than it found them: a bad
name renamed, a dead branch deleted, a missing test added. Cleanup is confined to files the PR
already modifies for its own reasons; unrelated refactors go in their own PR. Two hard rules make
this measurable — no PR may increase the analyzer warning count, and no PR may add a `// TODO`
without an owner and a linked issue.

**SOLID**, in the terms of this codebase:

- Single responsibility — a class that changes for two different reasons is split. A ViewModel
  serves exactly one view; a repository owns exactly one domain model; a service wraps exactly one
  data source.
- Open/closed — a new verification outcome, failure reason, or pass state is added as a new variant
  of its sealed type. Growing a chain of if/else on a string or an integer code is a review blocker.
- Liskov — the fake verification provider and the real one MUST satisfy the same contract test
  suite, unmodified. If the fake needs a special case to pass, the abstraction is wrong.
- Interface segregation — a consumer depends on the narrowest port that covers its need. A ViewModel
  that needs to read a credential MUST NOT receive an interface that can also issue or revoke one.
- Dependency inversion — every layer depends on abstractions it owns, never on a concrete
  implementation from the layer below. The provider SDK, the HTTP client, secure storage, and the
  clock are all injected behind interfaces; the clock in particular, because pass expiry is
  untestable otherwise.

**Repository pattern.** Defined structurally in Principle VIII; the craft rules on top of it are:
repositories return domain models and Result, never DTOs, HTTP responses, or provider types;
repositories are named for the domain model they own, not for the screen that consumes them; and a
repository that exists only to forward a single service call unchanged is deleted in favor of using
the service directly.

**KISS.** The simplest construction that satisfies the spec wins. An abstraction requires two real
call sites before it is introduced — not one call site and an anticipated second. Configuration
switches, plugin points, and generalizations for airports not yet under contract are speculative
generality and are rejected; replicability across airports is achieved by the integration contract,
which is a backend concern, not by parameterizing this app. A use-case that only forwards to a
repository is removed.

**DRY, applied to knowledge rather than to characters.** Each piece of knowledge — a validation rule,
a design token, a piece of user-facing copy, an event name, an error taxonomy — has exactly one
definition in the codebase. Two fragments that merely look alike today are not duplication; wait for
the third occurrence before extracting. Coupling two unrelated features because their code resembles
each other is the more expensive mistake, and this constitution prefers the duplication.

**Clean code**, with the limits this repository enforces:

- Names come from the product's domain vocabulary — credential, pass, liveness, escalation — and are
  used consistently across layers. No abbreviations, no `data`, `info`, `manager`, `helper`, or
  `utils` as a class name.
- Functions do one thing at one level of abstraction. Outside build, a function over 30 lines,
  nesting over 3 levels, or more than 4 positional parameters is a review blocker; guard clauses
  replace nested conditionals.
- Widgets are extracted into named widget classes, never into `_buildSomething()` methods returning a
  Widget — the private-method habit defeats const construction and rebuild isolation, so it is
  forbidden here specifically.
- No magic values. Durations, thresholds, retry counts, and expiry windows are named constants
  defined once.
- Comments explain why, never what. Commented-out code and dead code are deleted, not preserved —
  version control is the archive.
- A file over 400 lines is a signal that a responsibility is hiding inside it and MUST be justified
  or split.

Rationale: this app will be maintained by a small team, extended by coding agents, and replicated
across airport deployments under commercial deadline pressure. Every one of those conditions rewards
code that is obvious over code that is clever. These rules are written with thresholds because a
standard without a threshold is a preference, and preferences lose arguments to deadlines.

## Product Budgets the App Is Accountable For

The business case commits to measurable targets, and several of them are won or lost in this app.
These are treated as budgets: a change that regresses one is a defect, and a feature that cannot be
shown to respect one is not done.

- Enrollment completes in ≤3 minutes at p90, measured from the start of document capture to an
  active credential, with ≥90% of started enrollments completing. Anything added to the enrollment
  flow MUST be measured against this budget before merge.
- ≥85% of validations resolve without human intervention. Every design decision that pushes a
  passenger toward the agent-escalation path spends this budget, and MUST be justified as the safer
  outcome rather than the easier implementation.
- Escalation is fast to reach and fast to resolve: from any failure state, the agent path MUST be one
  tap away, and the app MUST carry enough context into that handoff that the agent does not restart
  the passenger's flow.
- Contingency degrades in ≤60 seconds. When the backend, the network, or the provider is unavailable,
  the app MUST reach a stable state that tells the passenger exactly what to do at the checkpoint
  instead. The app MUST NEVER be the reason a passenger cannot proceed by conventional means.
- Zero false accepts is an absolute. The app MUST NOT contain any path that displays a valid pass on
  the strength of local state alone. Where the backend has not affirmed validity, the app shows no
  pass. This budget is never traded against latency or convenience.

## Security & Compliance Constraints

- Credential tokens and consent records MUST be stored in platform-backed secure storage (Keystore /
  Keychain), never in shared preferences or a plain file.
- Screenshot and screen-recording capture MUST be blocked on the credential and QR pass screens.
- All backend communication MUST use TLS with certificate pinning. A pinning failure MUST fail
  closed.
- The app MUST detect a compromised device posture (root/jailbreak, emulator, hooking framework) and
  MUST refuse to issue or display a QR pass on one. Refusal MUST route the user to the
  agent-escalation path, not to a dead end.
- A QR pass MUST carry a short server-defined TTL and MUST NOT be regenerable offline. Expiry is
  enforced by the backend; the app's countdown is a courtesy display, never the authority.
- Third-party dependencies MUST be justified in the plan that introduces them. Any dependency with
  access to camera frames, storage, network, or device identifiers requires explicit review against
  Principles I and VII.

## Development Workflow & Quality Gates

- Stack: Flutter, mobile only. Layering, naming, and dependency direction are defined by Principle
  VIII; this section only states how they are enforced. A single state-management solution is chosen
  once, recorded in the plan, and used everywhere — mixing approaches across features is rejected in
  review.
- Static analysis: `flutter analyze` MUST be clean at zero warnings. `dynamic` is forbidden outside
  service-boundary deserialization. Lints are enforced in CI, not by convention, and MUST include:
  exhaustive switch enforcement, unused-result on Result returns, and an import-boundary rule that
  fails a view importing a repository or service.
- Generated code: immutable models and their `copyWith`/equality are generated. Generated files are
  committed and CI MUST fail if regenerating produces a diff.
- Design fidelity: colors, typography, spacing, radii, and motion durations come from a single
  generated token source derived from the AeroPass design file. Hard-coded design values in widget
  code are a review blocker.
- Flavors: the app ships dev, staging, and prod flavors with distinct backend endpoints and provider
  keys. Provider credentials MUST NOT be committed to the repository in any flavor.
- Every PR MUST reference the spec it implements, MUST state which principles it touches, and MUST
  leave the test suite green. A PR that changes a trust-boundary path without a preceding failing
  test is rejected on that basis alone.
- CI gates on merge: analyze clean, all tests pass, golden tests pass, no generated-code diff, and
  line coverage at or above 85% across ViewModels, repositories, and use-cases.

## Governance

This constitution supersedes conflicting practices, conventions, and prior decisions. Where a spec,
plan, or task list conflicts with it, this document wins and the conflicting artifact is amended.

**Constitution Check.** Every `/speckit.plan` MUST include a Constitution Check that walks Principles
I–X explicitly and states, per principle, either compliance or a justified deviation. Deviations MUST
be recorded in the plan's Complexity Tracking table with the simpler alternative that was rejected
and the reason it was insufficient. "It is faster" is not a reason.

**Amendment procedure.** An amendment requires a written proposal stating the principle affected, the
rationale, and the migration required of existing code. Amendments are applied to this file,
versioned, and accompanied by a Sync Impact Report comment. Any template or spec the amendment
invalidates MUST be updated in the same change.

**Versioning.** Semantic versioning applies to this document:

- MAJOR — a principle is removed, or redefined in a way that makes previously compliant code
  non-compliant.
- MINOR — a principle or a materially new section is added, or existing guidance is expanded in a
  way that adds obligations.
- PATCH — clarification, wording, or typo fixes that change no obligation.

**Compliance review.** Compliance is verified at three points: the Constitution Check during
planning, code review on every PR, and a review of this document at each release cut, where any
principle that was routinely waived is either enforced or amended — a principle that is waived
without amendment is a governance failure, not a pragmatic exception.

**Version**: 1.4.0 | **Ratified**: 2026-09-21 | **Last Amended**: 2026-09-21
