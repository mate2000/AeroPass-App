# Quickstart: Welcome & Enrollment Entry Point (01 Bienvenida)

Validation guide for this feature once implemented. Assumes the Flutter project is scaffolded per
plan.md's Project Structure and pinned via FVM (research.md §1).

## Prerequisites

- Flutter SDK pinned per `.fvmrc` installed (`fvm install && fvm use`).
- Android emulator or iOS simulator running at or above the interim minimum-spec baseline
  (Android 8.0 / iOS 15.0 — research.md §2).
- No backend required for the fake-backed validation scenarios below; a reachable (or intentionally
  unreachable) backend is only needed for the real-adapter scenarios.

## Automated validation (run first)

```bash
fvm flutter analyze                 # MUST be zero warnings (Development Workflow gate)
fvm flutter test test/unit          # WelcomeViewModel state-transition tests
fvm flutter test test/widget        # WelcomeView: empty/loading/error/populated states
fvm flutter test test/contract      # CredentialRepository: fake AND real, same suite
```

All of the above MUST pass before manual validation — they are the trust-boundary tests Principle IV
requires to exist and pass, not a substitute for them.

## Manual validation scenarios

Each maps to an Acceptance Scenario in spec.md.

1. **First-time passenger (User Story 1)**
   - Fresh install / cleared app data, no cached credential.
   - Launch → confirm splash appears briefly, then the welcome screen renders with benefit, the
     three steps, "free" messaging, and exactly one primary action — no scrolling required at the
     minimum supported screen size.
   - Confirm (via OS permission log / no permission dialog) no camera permission has been requested.
   - Tap the primary action → confirm navigation to the consent step and a `welcome_primary_action_tapped`
     event fires.

2. **Returning enrolled passenger (User Story 2)**
   - Seed a valid cached credential (test fixture / debug menu).
   - Launch → confirm the welcome screen is never shown; the app lands on the trips surface within
     3 seconds (SC-004).
   - Flip the seeded credential to `revoked` → relaunch → confirm the welcome screen shows the
     re-enrollment explanation variant, not the first-run variant.
   - From a device with no cached credential, tap the secondary action → confirm it opens the
     credential-recovery path, not fresh enrollment.

3. **Privacy-cautious passenger (User Story 3)**
   - From the welcome screen, locate and open the privacy/data-handling terms route.
   - Confirm plain-language coverage of what's collected, who verifies it, retention period, and
     revocation.
   - Navigate back → confirm return to the welcome screen with no enrollment session created and no
     state lost.

4. **Offline launch (Edge Case)**
   - Enable airplane mode → launch → confirm the welcome screen still renders and is fully readable;
     confirm the credential check resolves to `Unreachable` without an unhandled error state.

5. **Mid-enrollment resume, process-alive only (Edge Case, narrowed FR-008)**
   - Start enrollment, advance past consent, then background the app (do not force-close).
   - Return to the app → confirm the resume offer appears at the step reached.
   - Now force-close the app entirely and relaunch → confirm enrollment starts fresh (no resume
     offer) — this is the expected behavior after the Constitution Check narrowing, not a bug.

6. **Unsupported device (Edge Case)**
   - On a device/emulator below the minimum-spec baseline or with no usable camera, launch → confirm
     the screen states the device can't support enrollment and directs to the conventional airport
     process, with no action offered that would fail.

## Accessibility pass (SC-007)

- Run a screen reader (TalkBack / VoiceOver) through the entire welcome screen and confirm every
  interactive element is reachable with a meaningful label.
- Set the platform's maximum dynamic type size and confirm no clipping/overlap.
- View the screen in grayscale (accessibility simulation) and confirm the recoverable-vs-terminal
  distinction (re-enrollment explanation vs. generic first-run) does not depend on color.
