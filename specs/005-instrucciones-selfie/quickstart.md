# Quickstart: Selfie Instructions (05 Instrucciones selfie)

Validation guide once implemented. No camera, no network call, no repository of its own — this is
the lightest screen in the flow so far, and can be fully exercised headlessly.

## Automated validation (run first)

```bash
fvm flutter analyze
fvm flutter test test/unit/selfie_instructions_viewmodel_test.dart
fvm flutter test test/widget/selfie_instructions_view_test.dart
fvm flutter test test/unit/happy_path_flags_test.dart
```

Confirm no regression in 002/003/004's suites after relocating their flags (research.md §4):

```bash
fvm flutter test test/widget/consent_view_test.dart
fvm flutter test test/widget/document_confirmation_view_test.dart
fvm flutter test test/widget/router_test.dart
```

## Manual validation scenarios

Requires a prior confirmed identity record (004-confirmar-datos) — reachable via the
`USE_FAKE_CONSENT_BACKEND`/`USE_FAKE_VERIFICATION_BACKEND` dev flags with no real backend, per
002/004's precedent.

1. **Clean read-through (User Story 1)**
   - From data confirmation, confirm → this screen opens.
   - Confirm the step indicator shows "Documento" complete, "Selfie" active, "Listo" upcoming.
   - Confirm the title, subtitle, and all three conditions are visible without scrolling on a
     standard device size, each phrased as an action ("Buena iluminación...", never "Sin...").
   - Confirm no camera permission prompt appears and no camera preview renders at any point on
     this screen.
   - Tap "Tomar selfie" → confirm the liveness-capture placeholder route opens.

2. **Alternative routes (User Story 2)**
   - Tap "Ayuda" → confirm the existing help route opens and returns to this screen with the
     enrollment session intact.
   - Tap "Atrás" → confirm return to data confirmation with the previously confirmed fields still
     displayed (004's state, not re-fetched).

## Accessibility checks

- With a screen reader, confirm the title, subtitle, and all three conditions are announced; confirm
  the illustration is silent (not announced as a meaningful element).
- At the platform's maximum text size, confirm no condition text is clipped or overlapped (FR-011).

## Release-safety check (constitution v1.4.0)

- Run `fvm flutter test test/unit/happy_path_flags_test.dart` and confirm case 4 (release mode +
  a flag on) throws.
- Confirm a normal `flutter build apk --release` with no `--dart-define` flags succeeds unaffected.
