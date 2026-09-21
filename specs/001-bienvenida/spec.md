# Feature Specification: Welcome & Enrollment Entry Point (01 Bienvenida)

**Feature Branch**: `001-bienvenida`

**Created**: 2026-09-21

**Status**: Draft

**Input**: User description: "Screen 01 Bienvenida — the app's entry point: explains what AeroPass does, states the three enrollment steps, and routes the passenger either into enrollment or to an existing credential."

## Clarifications

### Session 2026-09-21

- Q: What should the welcome screen show while it's checking the passenger's credential status at launch, before it decides whether to show the welcome content or route straight to trips? → A: A brief branded splash/loading screen shown while the check runs, then the app routes to welcome or trips
- Q: Does a resumable enrollment session (FR-008) live only on the same device install, or is it tied to the passenger's identity so it could still be resumed after a reinstall or on a new device? → A: Device-local only — the session lives on the device that started it; a reinstall or new device always starts fresh
- Q (raised during `/speckit-plan`, Constitution Check): FR-008 and FR-013 as originally written required persisting enrollment-step progress and an analytics session identifier to disk, which Principle I's persisted-state allowlist does not permit and does not allow waiving by plan-level justification. → A: Narrow the spec — resume becomes in-memory/process-lifetime only (lost on app termination), and the analytics session identifier is generated fresh per launch and held in memory only. FR-008, FR-013, SC-008, and the Enrollment session entity are revised below accordingly.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - A first-time passenger decides to enroll (Priority: P1)

A passenger has installed AeroPass — after seeing it at the airport, in an airline email, or on a
recommendation — and opens it for the first time. They do not yet know what the app asks of them.
Within a few seconds they need to understand three things: what they get (pass security without
presenting documents again), what it costs them (nothing), and what it will ask for (an identity
document and a selfie). If those three land, they start enrollment. If any is unclear, they close
the app and the product never gets a second chance with that passenger.

**Why this priority**: this is the only screen every passenger sees, and it is the first point at
which the enrollment funnel can lose them. No other screen in the product can be reached without
passing through this decision, so it is the minimum viable slice — a build containing only this
screen and its exit into enrollment is still demonstrable to an airport client.

**Independent Test**: install the app on a device with no prior state, open it, and confirm that the
value proposition, the required inputs, and the primary action are all present and comprehensible
without scrolling past the fold on the minimum supported screen size, and that the primary action
advances to the consent step.

**Acceptance Scenarios**:

1. **Given** a passenger opening the app for the first time, **When** the welcome screen appears,
   **Then** it states the benefit, the three enrollment steps, and the fact that the service is free
   to the passenger, with a single primary action to begin.
2. **Given** the welcome screen is displayed, **When** the passenger activates the primary action,
   **Then** the app advances to the consent step and records that enrollment was started.
3. **Given** the welcome screen is displayed, **When** the passenger has not yet acted, **Then** the
   app has requested no camera permission, captured no image, and transmitted no personal data.
4. **Given** a passenger reading the screen, **When** they look for what the app will ask of them,
   **Then** the required inputs are stated on this screen and not deferred to a later step.

---

### User Story 2 - An enrolled passenger returns for their next flight (Priority: P2)

A passenger who enrolled on a previous trip opens the app at the airport, in a queue, with minutes
to spare. They do not need to be sold the product again — they need their pass. The welcome screen
must not stand between them and it.

**Why this priority**: it protects the recurrence target the business case depends on, and a
returning passenger stuck behind a marketing screen is the most visible possible failure of the
product's core promise. It is second only because it has no value until User Story 1 has produced
enrolled passengers.

**Independent Test**: with a valid credential present on the device, launch the app and confirm the
passenger arrives at their trips surface without the welcome screen appearing at all; then
invalidate the credential and confirm the welcome screen returns.

**Acceptance Scenarios**:

1. **Given** a device holding a valid credential, **When** the app launches, **Then** the welcome
   screen is not shown and the passenger arrives directly at their trips surface.
2. **Given** a device holding a credential the backend reports as revoked or expired, **When** the
   app launches, **Then** the welcome screen is shown with an explanation of why re-enrollment is
   needed, not a generic first-run screen.
3. **Given** a passenger who has an account but is on a new device, **When** they activate the
   secondary action on the welcome screen, **Then** they are taken to the path that restores their
   credential rather than into a fresh enrollment.

---

### User Story 3 - A privacy-cautious passenger evaluates before committing (Priority: P3)

A passenger is interested but wary of handing a biometric and a government document to an app they
just installed. Before starting, they want to know who processes their face, how long it is kept,
and whether they can withdraw later.

**Why this priority**: it addresses a named adoption risk in the business case rather than a
mechanical gap, and it is additive — enrollment works without it, but the passengers it converts are
exactly the frequent travellers the entry niche is built on.

**Independent Test**: from the welcome screen, confirm a passenger can reach a plain-language
statement of what is collected, who verifies it, how long it is retained, and how to revoke, and
return to the welcome screen without losing their place.

**Acceptance Scenarios**:

1. **Given** the welcome screen, **When** the passenger looks for privacy information, **Then** a
   route to the full data-handling terms is available before any capture begins.
2. **Given** the passenger has opened the terms, **When** they navigate back, **Then** they return
   to the welcome screen with no state lost and no enrollment started.

---

### Edge Cases

- The device cannot support enrollment — no usable camera, or an operating system below the
  supported minimum. The passenger must be told this here, before investing time, and told what to
  do at the airport instead.
- The app is opened with no connectivity. The welcome screen is static content and must render and
  be readable offline; the failure surfaces at the first step that genuinely needs the network, not
  as a blank launch.
- The passenger abandoned enrollment earlier — for example after the document scan but before the
  selfie — and backgrounds the app (a call, another app) rather than terminating it. On returning
  while the app process is still alive, the app must offer to resume rather than silently
  restarting, and must not present the same first-run framing to someone already partway through.
  If the app process was terminated in the meantime, no progress marker survives and the passenger
  starts a fresh enrollment — the app does not persist enrollment-step progress to disk.
- The passenger taps the primary action repeatedly or double-taps during the transition. Exactly one
  enrollment session may be created.
- A credential exists but cannot be validated because the backend is unreachable at launch. The
  passenger must not be dropped into first-run onboarding on the strength of a network failure.
- The passenger arrives from a deep link — an airline email or an airport QR code. They should land
  in the flow the link intends, with the welcome screen shown only if they are not enrolled.
- The passenger uses a screen reader, large dynamic type, or both. Every element remains reachable
  and the layout does not clip; the illustration is not the carrier of any information.
- The passenger does not read Spanish. The app defaults to Spanish (es-CO) but detects the device's
  system language and displays content in that language when it is a supported locale, so this
  screen (and the app generally) MUST be built on a localization layer rather than hard-coded
  Spanish strings.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The welcome screen MUST state the passenger-facing benefit, the fact that the service
  is free to the passenger, and the three enrollment steps (identity document, selfie, travel)
  before any enrollment action is offered.
- **FR-002**: The screen MUST present exactly one primary action to begin enrollment and exactly one
  secondary action for passengers who already have an account.
- **FR-003**: The screen MUST NOT request camera permission, capture any image, or transmit any
  personal data. Permission is requested at the step that uses it, after consent.
- **FR-004**: Activating the primary action MUST advance to the consent step and MUST create exactly
  one enrollment session, regardless of repeated or concurrent activation.
- **FR-005**: On launch, the app MUST route a passenger holding a valid credential past this screen
  to their trips surface without displaying it.
- **FR-017**: While the launch-time credential-status check is in progress, the app MUST show a
  brief branded splash/loading state — neither the welcome content nor the trips surface — and only
  render one of the two once the check resolves (valid, revoked/expired, or unreachable).
- **FR-006**: When a credential exists but is revoked or expired, the screen MUST be shown with an
  explanation of why enrollment is required again, distinct from the first-run presentation.
- **FR-007**: When credential validity cannot be determined because the backend is unreachable, the
  app MUST NOT treat the passenger as unenrolled; it MUST present the last known state and indicate
  that it could not be refreshed.
- **FR-008**: While the app process remains alive — the passenger backgrounded the app mid-flow (a
  call, another app) and returned, rather than terminating it — the screen MUST offer to resume the
  incomplete enrollment session at the step it reached, rather than restarting. This progress marker
  MUST be held in memory only, scoped to the current app process, and MUST NOT be written to disk;
  once the app process terminates, the marker is gone and the next launch always starts a fresh
  enrollment.
- **FR-009**: The screen MUST render and remain readable with no network connectivity.
- **FR-010**: The screen MUST provide a route, before enrollment begins, to a plain-language
  statement of what data is collected, who performs the verification, how long the facial template
  is retained, and how consent can be withdrawn.
- **FR-011**: The screen MUST link to the full privacy terms and the terms of service. These
  documents are not yet published; until legal delivers final URLs, the screen ships against a
  placeholder/internal-review link, tracked as a blocking dependency below.
- **FR-016**: The app MUST be built on a localization layer from this screen onward (no hard-coded
  Spanish strings). On launch, it MUST detect the device's system language and render content in
  that language when supported, defaulting to Spanish (es-CO) otherwise.
- **FR-012**: When the device cannot support enrollment — no usable camera or an unsupported
  operating system version — the screen MUST say so and MUST direct the passenger to the
  conventional airport process instead of offering an action that will fail.
- **FR-013**: The screen MUST emit the funnel events required to measure enrollment starts,
  first-run-to-start time, and abandonment at this step, keyed to an anonymous session identifier
  and containing no personal data. This identifier is generated fresh on each app launch and held
  in memory only (not persisted to disk); it is sufficient to correlate this screen's own funnel
  events within a single launch. Cross-launch measures such as repeat use across flights are
  computed from backend, credential-linked events emitted once a passenger is enrolled — out of
  scope for this pre-enrollment screen.
- **FR-014**: All content MUST be reachable by screen reader with meaningful labels, MUST remain
  legible and unclipped at the platform's maximum text size, and MUST NOT convey any information
  through the illustration or through color alone.
- **FR-015**: The primary action MUST remain within reach of a one-handed grip on the minimum
  supported screen size without scrolling.

### Key Entities *(include if feature involves data)*

- **Prospective passenger**: someone with the app installed and no credential. Has no identity in
  the system beyond an anonymous session identifier until consent is given.
- **Enrollment session**: the unit created when enrollment begins. Tracks which step was reached and
  whether it was completed or abandoned. Carries no biometric or document content. Held in memory
  only for the lifetime of the current app process — never written to disk — so it does not survive
  the app process being terminated, a reinstall, or a different device.
- **Credential**: the issued digital identity, if one exists on the device. Only its existence,
  validity window, and status are relevant to this screen.
- **Device capability**: whether this device can complete enrollment — camera availability and
  operating system version — evaluated before the passenger commits time.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: ≥70% of passengers who see the welcome screen for the first time begin enrollment in
  the same session.
- **SC-002**: The median passenger spends ≤15 seconds on this screen before acting, keeping the
  screen's share of the ≤3-minute p90 enrollment budget under 10%.
- **SC-003**: The screen is displayed and interactive within 2 seconds of a cold launch at p90 on
  the minimum supported device.
- **SC-004**: An enrolled passenger reaches their trips surface within 3 seconds of launch and never
  sees this screen.
- **SC-005**: In moderated testing with at least 12 frequent travellers, ≥90% can correctly state
  what the app will ask them for after viewing this screen alone.
- **SC-006**: Zero camera permission prompts and zero outbound personal data occur while this screen
  is displayed, verified by audit.
- **SC-007**: 100% of interactive elements carry accessible labels and meet AA contrast, verified in
  an accessibility audit before release.
- **SC-008**: Of passengers who background the app mid-enrollment and return before the app process
  is terminated, ≥60% resume rather than restarting. (This does not apply across a full app
  termination and relaunch — progress is not persisted, so that case always starts fresh.)

## Assumptions

- The passenger is a domestic traveller at a contracted airport; international and immigration flows
  are out of scope for this release.
- Enrollment is free to the passenger, since the commercial model bills the airport, and the screen
  states this as a conversion argument rather than as fine print.
- No account or password exists at this point in the journey — identity is established by the
  document and the selfie in later steps, so the secondary action is credential recovery on a new
  device, not a login.
- The app defaults to Spanish (es-CO) and detects the device's system language to switch content
  when a supported locale is detected; the set of languages supported at launch beyond Spanish is a
  product/content decision to be made in planning, not this specification.
- The illustration is decorative. Every fact it suggests is also stated in text.
- The app's minimum supported device and operating system version have been defined elsewhere and
  are available to this screen as a capability check.

## Dependencies

- A credential-status check the app can call at launch, which distinguishes valid, expired or
  revoked, and unknown because unreachable — FR-005 through FR-007 cannot be satisfied by a check
  that collapses the last two.
- **Blocking**: Published privacy terms and terms of service (final URLs) and a stated
  facial-template retention period, for FR-010 and FR-011. The screen ships against a placeholder
  link until these are delivered.
- An analytics event schema that accepts anonymous-session-keyed funnel events, for FR-013.
- The consent step (screen 02) as the destination of the primary action.

## Out of Scope

- The consent gate itself, its wording, and its blocking behavior — specified with screen 02.
- Account recovery on a new device beyond the entry point offered here.
- Any capture, verification, or credential issuance.
- Marketing acquisition surfaces outside the app, including airline emails and airport signage.
