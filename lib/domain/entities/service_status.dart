import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_status.freezed.dart';

/// The parts of the passenger's journey the status card names, in display
/// order (011-error-tecnico, FR-007). Never internal components.
enum JourneyStep { documentScan, selfie, issuance }

/// The live health of one journey step.
enum StepHealth { operational, degraded, unavailable }

/// One successful read of the live status source (data-model.md). A read
/// that cannot fill every step is an error, never a partial status.
@freezed
sealed class ServiceStatus with _$ServiceStatus {
  const ServiceStatus._();

  const factory ServiceStatus({
    required Map<JourneyStep, StepHealth> steps,

    /// When the source says a retry is worth trying; null when it does not
    /// say (FR-008).
    DateTime? retryAfter,
  }) = _ServiceStatus;

  /// The most severe health reported, for the card header's dot.
  StepHealth get worst => steps.values.fold(
    StepHealth.operational,
    (worst, health) => health.index > worst.index ? health : worst,
  );
}
