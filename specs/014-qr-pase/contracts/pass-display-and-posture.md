# Contract: pass display mode and device posture

This covers the new method channel `aeropass/pass_display` (FR-006, FR-007, FR-023; research.md §6,
§8).

## Methods

| Method | Android (`MainActivity.kt`) | iOS (`AppDelegate.swift`) |
|---|---|---|
| `enterPassMode` | Saves the current `screenBrightness`, sets it to `1f`, adds `FLAG_KEEP_SCREEN_ON` and `FLAG_SECURE` | Saves `UIScreen.main.brightness`, sets it to 1, sets `isIdleTimerDisabled = true`. **Screenshots cannot be blocked on iOS** |
| `exitPassMode` | Restores the saved brightness, and clears both flags | Restores brightness and the idle timer |
| `devicePosture` | Returns a list of signals: `su_binary`, `test_keys`, `emulator`, `hooking_framework` | Returns `jailbreak_paths` when found |

A missing implementation (`notImplemented`) is logged, without data, and treated as follows:

- **Pass mode**: a no-op, so the pass still shows.
- **Posture**: `trusted`, because a platform that cannot check has nothing to report. This is
  recorded as a limitation, not a pass.

## Dart ports

- `PassDisplayGuard`: `PlatformPassDisplayGuard` and `FakePassDisplayGuard`, which counts its calls.
- `DevicePostureChecker`: `PlatformDevicePostureChecker`, `DevDevicePostureChecker` (always trusted,
  behind the fake flag) and `FakeDevicePostureChecker`.

## Lifecycle rules (ViewModel tests)

1. Pass mode is entered only when a code is shown. It is never entered for `loading`, `boarded` or
   `unavailable`.
2. Pass mode is exited on dispose, on `AppLifecycleState.paused`, and on "Atrás". It is re-entered
   on resume.
3. A compromised posture never calls `issue`, and the screen offers "Hablar con un agente".
