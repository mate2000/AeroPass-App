/// Why the consent gate's blocking "unavailable" presentation is shown,
/// per contracts/analytics-events.md's `consent_gate_unavailable_shown`
/// payload (`offline` | `fetch_error`). Domain vocabulary, not view- or
/// analytics-specific — lives in `domain/entities/` so neither
/// `ConsentViewState` nor `AnalyticsEmitter` has to import the other's file
/// just for this type (Constitution Principle X: interface segregation),
/// the same pattern `WelcomeScreenVariant`/`DeviceUnsupportedReason` already
/// established for 001-bienvenida.
enum UnavailableReason { offline, fetchError }
