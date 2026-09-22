# Data Model: Selfie Instructions (05 Instrucciones selfie)

## Capture condition (not modeled as a type)

Spec.md's Key Entities names this, but per Constitution Principle X (KISS) it is not represented as
a domain entity or a data list — it is static, passenger-independent copy with no runtime
variability, identical in kind to 001-bienvenida's three enrollment-step tiles
(`EnrollmentStepsList`, hardcoded rows pulling `l10n` strings, no backing model). The three
conditions are three hardcoded rows in `CaptureConditionsList` (see plan.md's Project Structure),
each an icon (decorative, `ExcludeSemantics`) plus an `l10n` string that is the entire accessible
content of that row.

If the verification processor's actual requirements ever change (spec.md's Assumptions: "they
change if the processor changes"), that is a copy change to the `l10n` strings, not a data-model
change — there is no processor-driven configuration to keep in sync here.

## EnrollmentProgressStep (new, shared)

The step-indicator's rendered position, per research.md §2.

```text
enum EnrollmentProgressStep { document, selfie, done }
```

Not a domain entity — a `core/design` presentation-only enum. `StepIndicator` derives each
segment's visual state from an ordinal comparison against the passed `currentStep`:

| Segment | complete when | active when | upcoming otherwise |
|---|---|---|---|
| Documento | `currentStep.index > document.index` | `currentStep == document` | — |
| Selfie | `currentStep.index > selfie.index` | `currentStep == selfie` | — |
| Listo | `currentStep == done` (never "complete" — it's the terminal segment) | `currentStep == done` | — |

003's `CaptureView` and 004's `DocumentConfirmationView` both pass `EnrollmentProgressStep.document`
explicitly (FR-009's predecessor requirement, unchanged); this screen passes
`EnrollmentProgressStep.selfie`.

## Relationships

```text
SelfieInstructionsViewModel
 ├─ on construction: EnrollmentSessionController.advanceTo(EnrollmentStep.selfieCapture())
 │    (mirrors 003-escanear-documento's CaptureViewModel._load() calling advanceTo(documentCapture())
 │    on entry — the step indicator's state and the session's tracked step change together)
 ├─ analyticsEmitter.selfieInstructionsStepEntered() (FR-010)
 ├─ advance: Command0<void> — no repository call, no data read or written (FR-004/FR-005)
 │    └─ on completion: analyticsEmitter.selfieInstructionsAdvanced(); view pushes to the
 │         liveness-capture placeholder route (research.md §5)
 ├─ onHelpOpened(): analyticsEmitter.selfieInstructionsHelpOpened() — called by the view
 │    immediately before it pushes the existing help route
 └─ onBackNavigation(): analyticsEmitter.selfieInstructionsStepAbandoned() unless already
      advanced — mirrors 003/004's onBackNavigation shape exactly
```

No entity here is written to disk, cached, or retained beyond the widget's lifetime — this screen
introduces no new persisted state of any kind (Constitution Principle I, unaffected).

## HappyPathFlags (new, cross-cutting infrastructure — research.md §4)

```text
HappyPathFlags
 ├─ useFakeConsentBackend: bool   (relocated from composition_root.dart, 002-consentimiento)
 ├─ useFakeVerificationBackend: bool   (relocated from composition_root.dart, 004-confirmar-datos)
 └─ assertReleaseSafe({bool releaseMode = kReleaseMode})
      throws if releaseMode && (useFakeConsentBackend || useFakeVerificationBackend)
```

Not a domain entity — build-time/startup configuration, called once from `main()` before `runApp`.
