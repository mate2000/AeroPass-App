import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential.freezed.dart';

/// The subset of the issued credential this screen is allowed to read,
/// per Constitution Principle I's persisted-state allowlist and
/// data-model.md.
///
/// No document fields, no facial data, no name/date-of-birth — those are
/// out of this screen's read surface entirely.
@freezed
sealed class Credential with _$Credential {
  const factory Credential({
    /// Opaque credential token. Never logged, never included in an
    /// analytics event payload (FR-013, Constitution Principle VII).
    required String token,

    /// Drives Valid vs. ExpiredOrRevoked classification together with the
    /// backend's own status field.
    required DateTime validUntil,
  }) = _Credential;
}
