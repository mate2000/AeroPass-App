import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_capability.freezed.dart';

/// Whether this device can complete enrollment, evaluated at launch before
/// the passenger commits time (FR-012). Not persisted — recomputed each
/// launch, per data-model.md.
@freezed
sealed class DeviceCapability with _$DeviceCapability {
  const factory DeviceCapability({
    required bool hasUsableCamera,

    /// Checked against the interim minimum-spec baseline (Android 8.0 /
    /// iOS 15.0 — research.md §2), pending the product team's formal
    /// value.
    required bool osVersionSupported,
  }) = _DeviceCapability;

  const DeviceCapability._();

  /// True when the device can complete enrollment at all.
  bool get canEnroll => hasUsableCamera && osVersionSupported;
}
