# Trust-Boundary Audit: Service Failure (11 Error técnico)

**Task**: T046 | **Date**: 2026-09-23 | **Method**: repository search, backed by the tests named below

These are findings, not a reviewer checklist, so they use no checkboxes.

## Nothing is persisted, and no capture is kept (FR-005, SC-002)

- There is no file, cache, secure-storage or preferences write in:
  - `lib/features/enrollment/technical_error/`;
  - `lib/app/technical_error_controller.dart`;
  - the status service, repository and dev fake;
  - the transport mapper;
  - the alert reporter.

  The search covered `writeAsBytes`, `writeAsString`, `File(`, temporary and documents
  directories, `FlutterSecureStorage`, `SharedPreferences` and `.write(key`.
- The failure record and the retry pacing live in `TechnicalErrorController`, in memory only.
- The launch resume re-reads the job from the backend. It stores nothing
  (`resumeAfterVerification` builds an in-memory session).
- `test/architecture/import_boundary_test.dart` forbids screen 11's files from importing `lib/data/`,
  any camera package, or a capture service.

## No attempt is consumed (FR-002, SC-001)

- No 011 file references `AttemptCounter`. Screen 11's ViewModel does not receive the counter
  repository, and the boundary test forbids importing it.
- 007's new recording path, `_recordTechnicalError`, touches no counter. The 007 unit tests
  "011: what 007 records…" assert that both counters stay at 0 for every entry row.

## The notification claim is gated exactly once (FR-006, SC-003)

- The sentence is rendered in one place, the guidance in `technical_error_view.dart`, behind
  `showNotificationClaim`.
- `showNotificationClaim` is true only when the class is `service` and `canClaimNotification` is
  true.
- `canClaimNotification` is `SentryConfig.isEnabled && SentryConfig.alertRuleConfirmed` for Sentry,
  and `false` for the no-op reporter.
- `SENTRY_ALERT_RULE_CONFIRMED=false` is set in every env file.
- The report is sent once per recorded `service` failure (`takeReportable`), and never for the
  connectivity or undetermined classes. The ViewModel tests cover all four class and claim
  combinations.

## No status is rendered from copy (FR-007, SC-004)

- The health labels are used only in `service_status_card.dart`, and the card is built only from a
  successful `ServiceStatus` read.
- The dev source always fails, so in happy-path mode the card never renders.
- The real mapping fails the whole read on any missing, duplicate or unknown step or health. The
  contract suite has 6 cases for this.

## Personal data (FR-018, Principle VII)

- The five new events carry enum names, booleans and integers only
  (`technical_error_analytics_payload_test.dart`).
- The Sentry alert event is sent in a scope with the user cleared. `stripAlertEventPii` removes the
  user, request and breadcrumbs from any event carrying the `failure_class` tag
  (`sentry_before_send_test.dart`).
- **Open release gate**: `SentryConfig` still sets `sendDefaultPii = true` for every other event,
  including crash reports. The user asked for this setting. Either it becomes `false`, or the Sentry
  project's IP-address scrubbing is enabled and recorded, before a release build. This is research.md
  §7, left for the user to decide.
