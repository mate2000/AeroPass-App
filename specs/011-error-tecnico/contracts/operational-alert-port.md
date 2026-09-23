# Contract: Operational alert port

`OperationalAlertReporter` in `lib/domain/repositories/operational_alert_reporter.dart` (FR-006,
FR-018, SC-003; research.md §7).

```text
abstract class OperationalAlertReporter {
  /// True only when a report actually becomes a notification to the team.
  bool get canClaimNotification;

  /// Fire and forget. Called once per recorded `service` failure.
  void reportServiceFailure({required VerificationStage stage});
}
```

## Implementations

| Implementation | `canClaimNotification` | `reportServiceFailure` |
|---|---|---|
| `SentryOperationalAlertReporter` | `SentryConfig.isEnabled && SentryConfig.alertRuleConfirmed` | One `Sentry.captureMessage('verification_service_failure', level: error)` in an isolated scope |
| `NoopOperationalAlertReporter` (no DSN) | `false` | Does nothing |
| `FakeOperationalAlertReporter` (tests) | Settable | Records each stage it received |

The composition root picks the Sentry implementation when `SentryConfig.isEnabled`, and the no-op
otherwise.

## The Sentry event

| Field | Value |
|---|---|
| message | `verification_service_failure` |
| level | `error` |
| tags | `failure_class: service`, `failure_stage: document_check`, `face_comparison` or `issuance` |
| fingerprint | `['verification-service-failure', <stage>]` |
| user, request, extras, contexts added by this code | **none** |

`SentryConfig.configure` gains a `beforeSend` that removes `user` and `request` from any event
carrying the `failure_class` tag. This holds even though the global `sendDefaultPii` is on.

## `SENTRY_ALERT_RULE_CONFIRMED`

This is a new boolean `--dart-define`, read as `SentryConfig.alertRuleConfirmed`, and false by
default. It is set to true in an env file only after an alert rule exists in the Sentry project that
notifies the team on `failure_class:service`. It is a statement of fact about the operations setup,
not a happy-path relaxation, so it is not listed in `HappyPathFlags`.

## Release gates

1. The alert rule exists before any env file sets the define to true.
2. **Personal data**: either `sendDefaultPii` is set to false, or the Sentry project's "Prevent
   storing of IP addresses" setting is enabled. Record which one in the release checklist. This is
   raised with the user in research.md §7.

## Tests

1. The ViewModel calls `reportServiceFailure` exactly once for a `service` record, even across
   rebuilds and repeated status reads.
2. The ViewModel never calls it for `connectivity`, for `undetermined`, or with nothing recorded.
3. The claim is shown only when the class is `service` and `canClaimNotification` is true. Cover all
   four combinations.
4. The `beforeSend` hook strips `user` and `request` from a tagged event and leaves untagged events
   alone. This is a unit test on the hook function, with no network.
