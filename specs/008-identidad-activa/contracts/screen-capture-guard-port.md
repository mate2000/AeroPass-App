# Contract: `ScreenCaptureGuard`

Per research.md §13. Blocks screenshots and screen recording while a credential is displayed
(FR-012; constitution, Security & Compliance Constraints).

## Interface

```text
abstract class ScreenCaptureGuard {
  Future<void> enable();
  Future<void> disable();
}
```

- Screen 08's view calls `enable()` when it is first shown and `disable()` when it is disposed.
  Later credential and pass surfaces reuse the same port.
- Calls are idempotent: `enable()` twice, or `disable()` without `enable()`, is harmless.
- Failure to enable is logged without personal data and never blocks the screen. The screen must
  still render, per the constitution's rule that the app is never the reason a passenger cannot
  proceed.

## Implementations

| Platform | Implementation | Status |
|---|---|---|
| Android | `setSecure` / `clearSecure` on the `aeropass/screen_capture` method channel in `MainActivity.kt`, toggling `WindowManager.LayoutParams.FLAG_SECURE` on the activity window | Built in this feature |
| iOS | No-op | **Deferred** under the spec's FR-012 deferral. Exit requires hiding credential content while `UIScreen.isCaptured` is true. |
| Tests | `FakeScreenCaptureGuard` recording `enable`/`disable` calls | Built in this feature |

## Contract test suite

1. Showing screen 08 calls `enable()` exactly once.
2. Leaving screen 08 by any route calls `disable()` exactly once.
3. `enable()` throwing does not prevent screen 08 from rendering.
