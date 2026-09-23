# Trust-Boundary Audit: Dynamic QR Pass (14 QR Pase), phase A

**Task**: T039 | **Date**: 2026-09-23 | **Method**: repository search, backed by the tests named below

These are findings, not a reviewer checklist, so they use no checkboxes.

## No code is shown unless the backend says it is usable (FR-002, SC-004)

- `QrCodeView` is built in exactly one place, `_Showing` in `pass_view.dart`. That is rendered only
  for `PassShowing`.
- `PassShowing` is reached only after all of these:
  - a trusted device posture;
  - an active pass, backend-issued or backend-reported;
  - a trusted clock, within 30 s;
  - `serverNow < validUntil`;
  - a code from the code source.

  Every other outcome is `PassUnavailable` or `PassBoardedView`, with no code.
- `pass_view_test.dart` asserts there is no `QrCodeView` in every unavailable state, the boarded
  state, an untrusted clock and a compromised device.
- A device-side "expired" flag does not exist. The only expiry switch is `DevPassRepository`'s
  backend-side set. The dev control calls it, then reads the backend's status like any other
  expiry.

## "Simular expirado" cannot ship (FR-019, SC-006)

- The control is rendered only under `HappyPathFlags.devPassControls && viewModel.canDevExpire`.
- Its hook is wired only when the flag is on and the repository is the dev fake.
- `assertReleaseSafe` lists `DEV_PASS_CONTROLS`, so a release build with it on refuses to start.
- `tool/check_release_env.dart env/prod.env` runs in CI and fails on any development flag.
- These tests cover it: `release_env_check_test.dart`, and "is absent without its flag" in
  `pass_view_test.dart`.

## Nothing is stored; no secret is read (FR-005, FR-021, Principle I)

- There is no secure storage, file or preferences use in `lib/features/pass/`, the pass data
  services, the dev pass repository or the clock monitor.
- `PassIssueResponse` has **no `secret` field**, so a secret the backend sent would be dropped
  unread. The contract test sends one and still passes.
- The active pass lives in `PassRepositoryImpl`'s memory only.

## No pass data in logs or events (FR-015, SC-007)

- `pass_analytics_payload_test.dart` asserts every pass event value is an enum name, a bool or an
  int, and never `AP1…`, a flight number or a date.
- `import_boundary_test.dart` fails on any log or print call in the pass code that mentions a
  payload, secret, pass id or code.
- The trip id is not in the pass route: the route reads the next trip from the in-session
  snapshot, so no id reaches Sentry navigation breadcrumbs.

## Device posture (FR-023)

- A compromised posture never calls `issue` (ViewModel test), and the screen offers "Hablar con un
  agente".
- The checks are heuristic: su binaries, test-keys, emulator properties and Frida or Xposed traces
  on Android, and jailbreak paths on iOS. Backend attestation remains a recommended release item.

## Open items

- **Phase B** (T026–T031) is blocked on ratifying contracts/constitution-amendment-proposal.md.
  Until then the pass does not work offline, and says so.
- **iOS** cannot block screenshots. The Swift channel code was not compiled here, because there is
  no Xcode toolchain.
- **CI** reads `env/prod.env`, so that file must be committed.
