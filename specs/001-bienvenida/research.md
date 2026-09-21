# Phase 0 Research: Welcome & Enrollment Entry Point (01 Bienvenida)

## 1. Flutter/Dart SDK version pinning

**Decision**: Pin the exact Flutter/Dart SDK version with FVM (`.fvmrc` at repo root), tracking the
current stable channel at scaffolding time, rather than hard-coding a version number in this plan.

**Rationale**: This is the first feature plan for the app; no `pubspec.yaml`/`.fvmrc` exists yet.
Naming an exact SDK version here would go stale immediately and isn't a decision this single-screen
feature needs to make unilaterally — it's an app-bootstrap decision. FVM gives every contributor and
CI the same pinned version without the plan needing to be amended each time Flutter ships a release.

**Alternatives considered**: Hard-code a specific version in this plan (rejected — becomes stale, and
picking one is arbitrary for a feature plan rather than an app-scaffolding step); no pinning, use
whatever's on the dev machine (rejected — violates reproducibility, risks CI/local drift).

## 2. Minimum-spec device baseline

**Decision**: Adopt an interim baseline — Android 8.0 (API 26) and iOS 15.0 — as the minimum
supported OS versions, pending the product team's formal minimum-spec device publication referenced
in the spec's Assumptions ("defined elsewhere").

**Rationale**: Constitution Principle V and this spec's SC-003/SC-004 both require performance
budgets measured "on the minimum supported device," but no such device has been formally published
yet. Android 8.0 covers the vast majority of active Android devices in the target market while
excluding versions old enough to lack modern security/Keystore APIs the constitution's Security &
Compliance Constraints depend on (platform-backed secure storage, TLS features). iOS 15.0 is a
similarly conservative, still-current baseline. This is a placeholder, not a final decision — it
unblocks planning and test-device selection now.

**Alternatives considered**: Block planning entirely until the product team names a device (rejected
— stalls the whole feature over a cross-cutting app decision this feature doesn't own); target the
newest OS versions only (rejected — contradicts the "mid-range Android phone" device profile the
constitution's rationale for Principle V explicitly names).

**Follow-up**: Confirm the real minimum-spec device with the product team before release; update this
value across all features' performance budgets in one pass, not per-feature.

## 3. State management / ViewModel wiring

**Decision**: `provider` package, with `ChangeNotifier`-based ViewModels exposing `Command` objects
for actions, matching the layering and sample pattern published in Flutter's official app-architecture
guide (which Constitution Principle VIII names as the source of the app's layering).

**Rationale**: Constitution Development Workflow requires the state-management solution to be "chosen
once, recorded in the plan, and used everywhere." Because this is the first feature plan, that choice
is made here. `provider` is the dependency-injection/listening mechanism Flutter's own architecture
guide demonstrates alongside `ChangeNotifier` ViewModels, which keeps the app's architecture aligned
with documentation new contributors and coding agents already know (Principle VIII's stated
rationale), rather than introducing a third-party state-management philosophy (Bloc, Riverpod) with
its own idioms layered on top of the constitution's own View/ViewModel/Repository/Service vocabulary.

**Alternatives considered**: `flutter_riverpod` (more compile-time safety, but a materially different
DI/composition model than the officially-documented one Principle VIII points to — rejected to avoid
mismatched vocabulary between the constitution's prose and the code); `flutter_bloc` (heavier
ceremony — events/states — than this app's Command-object pattern already provides; rejected as
redundant machinery on top of Principle IX's Command pattern).

## 4. Certificate pinning approach

**Decision**: `dio` as the HTTP client, with certificate pinning enforced via pinned SHA-256 public
key hashes checked in a custom `HttpClientAdapter`/interceptor; a pinning failure throws before the
request completes, which `CredentialService` maps to the `Unreachable` status (fail closed, per the
Security & Compliance Constraints).

**Rationale**: `dio` is the most widely adopted Flutter HTTP client with first-class interceptor
support, which is what certificate-pinning enforcement needs. Failing closed into the same
`Unreachable` status this feature already models (FR-007) means no new UI state is required for a
pinning failure specifically — it reads to the passenger exactly like "backend unreachable."

**Alternatives considered**: A dedicated pinning plugin (rejected for this feature — adds a
platform-channel dependency for a single interceptor's worth of logic that `dio` already supports
directly); `HttpClient.badCertificateCallback` on `dart:io` directly (rejected — lower-level, more
boilerplate, and bypasses `dio`'s interceptor composition used elsewhere).

## 5. Localization mechanism (FR-016)

**Decision**: Flutter's built-in `gen-l10n` (ARB files + `flutter_localizations`), with device-locale
detection via `Localizations.localeOf` / `MaterialApp.localeListResolutionCallback`, defaulting to
`es` (Colombian Spanish) when the device locale isn't a supported one.

**Rationale**: `gen-l10n` is the framework-native localization mechanism, generates type-safe accessor
classes (consistent with the constitution's "no magic values" and generated-code conventions), and
needs no extra dependency beyond the SDK's own `flutter_localizations` package. Supported locales
beyond Spanish (e.g. `en`) are a content/product decision for planning of individual copy, not an
architectural one — the localization layer supports any number from day one.

**Alternatives considered**: `easy_localization` or similar third-party packages (rejected — added
dependency for functionality `gen-l10n` already provides natively; the constitution's dependency
justification requirement in the Security & Compliance Constraints favors the smaller footprint).
