/// The variant of welcome-screen content shown, shared by
/// `WelcomeViewState`, `WelcomeViewModel`, and the
/// `welcome_screen_shown`/`welcome_primary_action_tapped` analytics
/// events (contracts/analytics-events.md). Domain vocabulary, not
/// analytics- or view-specific — lives in `domain/entities/` so neither
/// the view layer nor the analytics port has to import the other's file
/// just for this type (Constitution Principle X: interface segregation).
enum WelcomeScreenVariant { firstRun, reenrollmentRequired, resumeOffered }

/// Why the device-unsupported message was shown instead of the normal
/// welcome content (FR-012), for the `welcome_device_unsupported_shown`
/// event.
enum DeviceUnsupportedReason { noCamera, unsupportedOs }
