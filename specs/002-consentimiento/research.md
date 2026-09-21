# Phase 0 Research: Informed Consent Gate (02 Consentimiento)

## 1. Presenting the gate as a dimmed sheet over the welcome screen

**Decision**: Keep `AppRoutes.consent` as a normal `go_router` `GoRoute`, but give it a
`pageBuilder` returning a `CustomTransitionPage` with `opaque: false` and a semi-transparent
`barrierColor`, sliding up from the bottom. `ConsentView` itself renders the sheet's visual shape
(rounded top corners, decorative drag handle, box shadow) reusing the same technique
001-bienvenida's `_WelcomeShell` already established for its own hero/sheet composition.

**Rationale**: `opaque: false` keeps the previous route (`WelcomeView`) mounted and visible — not
just present in the Navigator stack — underneath the barrier, which is what actually produces the
reference's "dimmed welcome screen behind the sheet" effect, without reaching for
`showModalBottomSheet` (which isn't a declarative `go_router` page and would need separate,
harder-to-test plumbing). This stays inside `go_router`'s own supported extension points.

**Alternatives considered**: `showModalBottomSheet` triggered imperatively from `WelcomeView`
(rejected — bypasses `go_router`'s declarative routing, complicates the "back gesture / deep link
into consent" cases, and is harder to widget-test in isolation the way 001-bienvenida's tests
isolate `WelcomeView`); a fully opaque full-screen route with no dimmed background (rejected — loses
a confirmed visual fact from the UI reference for no benefit).

## 2. Dismissal parity (FR-010): back gesture, swipe, system navigation

**Decision**: Two mechanisms, both invoking the same `ConsentViewModel.decline` `Command` used by
the explicit "Ahora no" button: (a) `PopScope` around `ConsentView`'s content, whose
`onPopInvokedWithResult` fires decline handling whenever the pop was **not** already triggered by
that command (i.e., a system back gesture); (b) a `GestureDetector` on the barrier area (tapping
outside the sheet) also calls `decline`.

**Rationale**: Routing every dismissal vector through one `Command` is what makes FR-010's "dismissal
is never treated as acceptance" structurally true rather than something four different code paths
each have to remember. `PopScope` is the current (non-deprecated) Flutter API for intercepting a
pop, covering both the Android back gesture and the system-navigation case.

**Alternatives considered**: A real interactive vertical drag-to-dismiss gesture on the sheet itself
(rejected as scope beyond what FR-010 actually requires — the requirement is outcome parity across
back/swipe/dismiss, not a specific drag physics implementation; the decorative drag handle from the
reference is kept, but it's not wired to a custom drag gesture in this pass).

## 3. Enrollment attempt identifier generation

**Decision**: Reuse `lib/core/uuid.dart`'s existing `generateUuidV4()` (already used by
001-bienvenida's `AnalyticsSessionId`) inside `ConsentRepositoryImpl.recordConsent()`, generated
client-side immediately before submission, included in the request, and persisted as part of the
local `ConsentRecord` copy.

**Rationale**: No new dependency needed — the ID-generation utility this feature needs already
exists in the codebase for exactly this kind of anonymous identifier. Generating it client-side
(rather than asking the backend for one first) avoids an extra round trip before the passenger can
confirm.

**Alternatives considered**: Add the `uuid` package (rejected — `generateUuidV4()` already does
this; a second implementation of the same 20 lines is the kind of duplication Principle X's DRY
guidance rejects); have the backend mint the identifier (rejected — an unnecessary round trip for a
value that doesn't need server-side uniqueness guarantees beyond what a v4 UUID already provides).

## 4. Withdrawal delivery after connectivity returns (FR-016)

**Decision**: No connectivity-listening package. `ConsentRepository.retryPendingWithdrawal()` is
called opportunistically from the existing `go_router` `_redirect` function (fire-and-forget,
non-blocking) — the same function that already runs a network call (the credential-status check)
every time the app re-evaluates the splash/welcome routes, which happens on every cold launch and
every return to the foreground that re-enters those routes.

**Rationale**: The app already has a reliable "we're about to attempt a network call, so this is a
reasonable moment to also retry anything pending" checkpoint. Piggybacking there satisfies "delivered
once connectivity returns, without the passenger repeating it" without adding a dependency whose
only job is telling the app what it can already infer from its own network attempts succeeding or
failing.

**Alternatives considered**: `connectivity_plus` (rejected — a real-time connectivity listener is
more machinery than this requirement needs, and the constitution requires justifying any dependency
with network access; the opportunistic approach needs none); a background fetch/WorkManager-style
periodic job (rejected as disproportionate — SC-004's 24-hour delivery budget is comfortably met by
retrying on every app open, which happens far more often than once a day for an active passenger).

## 5. Consent text shape (fetched, not bundled)

**Decision**: The backend serves a versioned, structured document —
`{ id, points: [{icon, heading, body}], rightsStatement, optionalityStatement,
processorDisclosure, privacyPolicyUrl, termsUrl, publishedAt }` — fetched fresh each time the gate
is presented. A fetch failure (network or malformed response) always shows the blocking
"unavailable" state; a previously-successful fetch is never reused as a fallback for a failed one
(Edge Cases: "never fall back to a stale or embedded copy that would make the stored evidence
wrong").

**Rationale**: FR-014 requires re-presenting the gate when the recorded consent refers to a
superseded version, which is only possible if version currency is checked live against a
server-controlled value — bundling the text in the app (like the welcome screen's ARB-based copy)
would tie legal-text updates to app store releases, defeating the point of versioning it at all.
The structured shape matches the reference's fixed 3-point layout rather than free-form markdown,
which this screen's design doesn't call for.

**Alternatives considered**: Bundle default/fallback text in the app for offline resilience
(rejected — directly contradicts the edge case's explicit prohibition on stale/embedded fallback,
since stale text displayed as if current would make the resulting consent record's "exact text
version presented" claim false).
