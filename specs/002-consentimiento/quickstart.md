# Quickstart: Informed Consent Gate (02 Consentimiento)

Validation guide once implemented. Assumes 001-bienvenida's project setup (FVM, dependencies,
secure storage) is already in place — this feature adds no new setup steps.

## Automated validation (run first)

```bash
fvm flutter analyze                  # MUST be zero warnings
fvm flutter test test/unit           # ConsentViewModel state-transition tests
fvm flutter test test/widget         # ConsentView: unavailable/ready/confirming/declined states
fvm flutter test test/contract       # ConsentRepository: fake AND real, same suite
```

## Manual validation scenarios

Each maps to an Acceptance Scenario in spec.md.

1. **Informed consent and proceed (User Story 1)**
   - From the welcome screen, tap "Comenzar" → confirm the consent gate renders as a dimmed-overlay
     sheet over the (still-visible, dimmed) welcome screen, with the drag handle, title, subtitle,
     the fetched points, the unchecked checkbox, and both actions.
   - Confirm "Acepto y continúo" is visibly disabled (and, with a screen reader active, announced as
     disabled with a reason) until the checkbox is checked.
   - Check the box → confirm the primary action becomes enabled and, with a screen reader, its
     enabled state is announced.
   - Tap "Acepto y continúo" → confirm advancement to the document-capture placeholder only after a
     brief recording delay (not optimistically) and that `getLocalRecord()` now returns a record with
     `status = active`.
   - Turn on airplane mode, repeat from the welcome screen → confirm the primary action, once
     tapped, reports that enrollment can't start right now rather than advancing.

2. **Decline without penalty (User Story 2)**
   - Reach the gate, tap "Ahora no" → confirm return to the welcome screen, no `ConsentRecord`
     created, and messaging that the conventional airport process remains available.
   - Reach the gate again, use the Android back gesture → confirm the identical outcome.
   - Reach the gate again, tap the dimmed area outside the sheet → confirm the identical outcome.
   - Relaunch the app after declining → confirm the consent gate is not shown automatically; it only
     reappears when enrollment is started again from the welcome screen.

3. **Withdrawal and re-consent on change (User Story 3)**
   - With a `ConsentRecord` present, open the withdrawal placeholder route and confirm withdrawal →
     confirm the local record's status becomes non-active and any displayed credential/pass is
     invalidated within ~1 second, with airplane mode on (no network dependency for this local
     effect).
   - Turn airplane mode back off, relaunch (triggering `_redirect`'s opportunistic retry) → confirm
     the record's status becomes `withdrawn`.
   - With a `ConsentRecord` referencing an old `textVersionId`, simulate the backend serving a new
     `getCurrentText().id` → confirm the gate is presented again (`hasPriorRecord: true` in its
     analytics event) rather than silently treated as still covering the new terms.

## Accessibility pass (SC-008)

- Screen-reader traversal of the entire gate, including the disabled/enabled announcement of the
  primary action and the reason it's disabled.
- Maximum platform dynamic type: confirm the full text remains reachable by scrolling and neither
  action is ever pushed out of reach (FR-013).
