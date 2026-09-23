# Quickstart: Verification Retry (09 Reintento)

Validation guide once implemented. The dev fakes always succeed, so every retry and limit state is
exercised through tests and seeded counters rather than the offline demo.

## Automated validation (run first)

```bash
flutter analyze
flutter test test/unit/retry_guidance_viewmodel_test.dart     # the three states from counters
flutter test test/widget/retry_guidance_view_test.dart        # contracts/retry-guidance-screen.md, goldens
```

Confirm the retry-policy changes (contracts/retry-policy-addendum.md):

```bash
flutter test test/unit/capture_viewmodel_test.dart
flutter test test/unit/liveness_capture_viewmodel_test.dart
flutter test test/unit/verification_progress_viewmodel_test.dart
flutter test                                                  # full suite
```

## Manual validation scenarios

The fakes never fail, so these use a debug build with the counters seeded through a test harness
or by temporarily scripting the dev verification fake to return `face_mismatch`.

| # | Setup | Expected |
|---|---|---|
| 1 | One face mismatch | "No pudimos confirmar que eres tú", the generic body, three selfie tips, no attempt count, "Intentar de nuevo" and "Hablar con un agente" |
| 2 | Tap "Intentar de nuevo" | The selfie camera opens directly, without the instructions screen |
| 3 | Tap "Hablar con un agente", then back | The agent placeholder, then this screen again |
| 4 | Selfie counter at the limit | The selfie limit state: no retry, the agent route, and the checkpoint line |
| 5 | With the selfie counter at the limit, navigate to the selfie camera by any route | Redirected to the limit state; the camera does not open |
| 6 | TalkBack or VoiceOver on, open the screen | The title and body are announced without touching the screen |

## Review checks

- No string on this screen contains "coincide", "suficiente", or a number of attempts.
- Search 003, 006 and 007 for `reset(`: the only remaining call sites are 007's `matched` branch.
