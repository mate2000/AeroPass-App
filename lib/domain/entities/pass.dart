import 'package:freezed_annotation/freezed_annotation.dart';

part 'pass.freezed.dart';

/// 014-qr-pase FR-003: the code rotates on this interval.
const passRotation = Duration(seconds: 30);

/// How often pass status is read while the pass is shown and online.
const passStatusPollInterval = Duration(seconds: 5);

/// Clarifications: a pass never outlives its scheduled departure, and never
/// more than this from issuance.
const passMaxOfflineValidity = Duration(hours: 24);

/// Clarifications (FR-014): a device clock further than this from the
/// backend's is not trusted; it equals one rotation interval.
const clockTolerance = Duration(seconds: 30);

/// The journey's checkpoints, in order (Clarifications: no "Sala").
enum Checkpoint { security, boarding }

/// A pass the backend issued for one started trip (data-model.md). It
/// authorizes nothing by itself: readers validate each code independently
/// (FR-002).
@freezed
sealed class Pass with _$Pass {
  const factory Pass({
    /// Opaque. Never logged or sent in an event (FR-015).
    required String passId,
    required String tripId,

    /// The reader the current code is for (FR-008).
    required Checkpoint nextCheckpoint,

    /// Only ever from the backend's status (FR-009).
    @Default(<Checkpoint>{}) Set<Checkpoint> validated,

    /// Server-defined: at most scheduled departure and 24 h from issuance.
    required DateTime validUntil,
    @Default(passRotation) Duration rotation,

    /// 015 FR-024: the checkpoints this pass opens, from the backend's
    /// `permisos`. Today that is boarding only, so the screen must not
    /// promise security.
    @Default({Checkpoint.security, Checkpoint.boarding})
    Set<Checkpoint> checkpoints,
  }) = _Pass;
}

/// One rotation window's code. [payload] is rendered as the QR and nothing
/// else: it never reaches a log, event or report (FR-015).
@freezed
sealed class PassCode with _$PassCode {
  const factory PassCode({
    required String payload,
    required DateTime windowStartsAt,
    required DateTime windowEndsAt,

    /// 015 FR-012: renewal failed, and this still-valid code stays on screen
    /// while it is retried. The view says "Actualizando código…".
    @Default(false) bool renewalPending,
  }) = _PassCode;
}

/// The backend's word on a pass (contracts/pass-port.md).
@freezed
sealed class PassState with _$PassState {
  const factory PassState.active(Pass pass) = PassActive;
  const factory PassState.expired() = PassExpired;
  const factory PassState.revoked() = PassRevoked;
  const factory PassState.boarded() = PassBoarded;
  const factory PassState.flightChanged({required bool cancelled}) =
      PassFlightChanged;
}

/// Why the device clock is not trusted (research.md §5).
enum ClockDistrustReason {
  /// No backend time has been observed in this process yet.
  noContact,

  /// The device clock differs from the backend's by more than 30 s.
  drift,

  /// The wall clock moved against monotonic time since the last contact.
  jump,
}

/// Whether codes derived from the device clock may be presented.
@freezed
sealed class ClockTrust with _$ClockTrust {
  const factory ClockTrust.trusted({required Duration offset}) = ClockTrusted;
  const factory ClockTrust.untrusted(ClockDistrustReason reason) =
      ClockUntrusted;
}

/// The device's security posture (constitution Security; FR-023).
@freezed
sealed class DevicePosture with _$DevicePosture {
  const factory DevicePosture.trusted() = DeviceTrusted;

  /// [signals] are fixed names such as `su_binary`, never device data.
  const factory DevicePosture.compromised(List<String> signals) =
      DeviceCompromised;
}

/// Why no code is shown (contracts/pass-ui.md).
enum PassUnavailableReason {
  expired,
  revoked,
  flightCancelled,
  flightChanged,
  untrustedClock,
  compromisedDevice,
  issuanceFailed,
  offlineWithoutPass,

  /// 015 FR-015: 403 `DOCUMENTO_VENCIDO`. No retry. It goes to the agent.
  documentExpired,

  /// 015 FR-015: 403 `IDENTIDAD_NO_ACTIVA`. Launch re-reads `/me` and routes.
  identityNotActive,
}

/// Why the backend refused to issue a pass (015 contracts/outcome-mapping.md
/// "Pass"). It is returned as the `Result.error` payload of
/// `PassRepository.issue`. A transport failure stays a `TransportFailure`.
enum PassIssueRefusal {
  documentExpired,
  identityNotActive,
  invalidFlightCode,

  /// 429 `LIMITE_EMISION_EXCEDIDO` or 503 `ALMACENAMIENTO_NO_DISPONIBLE`: a
  /// service condition. The caller waits for `retryAfter` (FR-014).
  busy,
}

/// The error object for a refused issuance.
final class PassIssueRefused {
  const PassIssueRefused(this.refusal, {this.retryAfter});

  final PassIssueRefusal refusal;
  final Duration? retryAfter;

  @override
  String toString() => 'PassIssueRefused(${refusal.name})';
}
