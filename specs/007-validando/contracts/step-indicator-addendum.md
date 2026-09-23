# Addendum: `StepIndicator` gains "current step not reached" and a light-surface style

Per research.md §8. A backward-compatible change to the shared widget in
`lib/core/design/step_indicator.dart`, used by 003–006.

## Change

```text
const StepIndicator({
  required EnrollmentProgressStep currentStep,
  bool currentStepReached = true,   // new
  bool onLightSurface = false,      // new
})
```

- `currentStepReached: false` renders the current step as upcoming instead of active. Screen 07
  passes `currentStep: done, currentStepReached: false`: Documento and Selfie complete, Listo
  pending (FR-006).
- `onLightSurface: true` uses a dark-grey upcoming colour, since `white54` disappears on a light
  background.
- The semantics label says the current step is pending when it is not reached.

## Tests

1. Defaults render exactly as today (regression, for 003–006).
2. `currentStepReached: false` renders the current segment in the upcoming colour, and earlier
   segments as complete.
3. `onLightSurface: true` changes only the upcoming colour.
