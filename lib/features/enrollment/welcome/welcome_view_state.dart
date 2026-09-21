import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entities/credential_status.dart';
import '../../../domain/entities/welcome_content_variant.dart';

part 'welcome_view_state.freezed.dart';

/// `WelcomeViewModel`'s rendered state, per Constitution Principle IX
/// ("sealed types over boolean flags") — this is deliberately not an
/// `isLoading`/`hasError`/`isEmpty` trio, because the welcome screen only
/// ever has these variants:
///
/// - [WelcomeViewChecking]: the credential/device-capability check is in
///   flight, or it resolved to a status this screen must never render for
///   (e.g. a confirmed-valid credential, FR-005) — in both cases the view
///   shows the same brief loading presentation while navigation away
///   happens elsewhere (the app router).
/// - [WelcomeViewDeviceUnsupported]: FR-012 — the device can't complete
///   enrollment at all.
/// - [WelcomeViewContent]: the normal welcome content, parameterized by
///   which of the three copy variants applies and whether the shown
///   status could not be freshly confirmed (FR-007).
@freezed
sealed class WelcomeViewState with _$WelcomeViewState {
  const factory WelcomeViewState.checking() = WelcomeViewChecking;

  const factory WelcomeViewState.deviceUnsupported({
    required DeviceUnsupportedReason reason,
  }) = WelcomeViewDeviceUnsupported;

  const factory WelcomeViewState.content({
    required WelcomeScreenVariant variant,
    @Default(false) bool unrefreshed,

    /// Only set when [variant] is `reenrollmentRequired` — which distinct
    /// explanation to show (FR-006).
    ExpiryReason? expiryReason,
  }) = WelcomeViewContent;
}
