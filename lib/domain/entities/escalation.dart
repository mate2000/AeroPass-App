import 'package:freezed_annotation/freezed_annotation.dart';

import 'capture_attempt_counter.dart';

part 'escalation.freezed.dart';

/// How the passenger reached the escalation screen (010-escalar-agente,
/// research.md §2), derived from the attempt counters.
enum EscalationArrival { byChoice, afterLimit }

/// One route to a person (010, data-model.md).
enum AgentChannelKind { module, chat }

/// A wait range, present only when the channel's source supplies it
/// (FR-006).
@freezed
sealed class WaitEstimate with _$WaitEstimate {
  const factory WaitEstimate({
    required int minMinutes,
    required int maxMinutes,
  }) = _WaitEstimate;
}

/// A channel and its state, from the backend (or the dev fake) — never copy
/// in the screen (FR-004).
@freezed
sealed class AgentChannel with _$AgentChannel {
  const factory AgentChannel({
    required AgentChannelKind kind,
    required bool available,

    /// Required when [available] is false (FR-005).
    DateTime? nextOpensAt,

    /// Chat only, and only when supplied (FR-006).
    WaitEstimate? estimatedWait,

    /// Operational data, e.g. "Lun–Vie 6:00am–10:00pm".
    required String hours,

    /// Module only: the airport (FR-007).
    String? locationName,

    /// Module only: where the module is inside the airport (FR-007).
    String? locationDetail,
  }) = _AgentChannel;
}

/// An open escalation. The 24-hour window runs from [openedAt] and is
/// enforced by the backend (FR-022).
@freezed
sealed class EscalationCase with _$EscalationCase {
  const factory EscalationCase({
    required DateTime openedAt,
    required EscalationArrival arrival,
  }) = _EscalationCase;
}

/// What a module agent decided (010, research.md §1). **`credentialIssued`
/// carries no credential**: the app obtains it through 008's issuance port,
/// the only path that can open 008 (FR-011).
@freezed
sealed class EscalationOutcome with _$EscalationOutcome {
  const factory EscalationOutcome.credentialIssued() =
      EscalationCredentialIssued;

  const factory EscalationOutcome.declined() = EscalationDeclined;

  /// The agent reset an exhausted limit for [scope] (009 FR-017, 010 FR-019).
  const factory EscalationOutcome.attemptsReset({
    required AttemptCounterScope scope,
  }) = EscalationAttemptsReset;
}

/// What one status read returns.
@freezed
sealed class EscalationStatus with _$EscalationStatus {
  const factory EscalationStatus.open({
    required EscalationCase escalation,
    required List<AgentChannel> channels,
  }) = EscalationOpen;

  const factory EscalationStatus.resolved({
    required EscalationOutcome outcome,
  }) = EscalationResolved;

  const factory EscalationStatus.expired() = EscalationExpired;
}

/// The bucket `AnalyticsEmitter.escalationOutcome` carries.
enum EscalationOutcomeKind {
  credentialIssued,
  declined,
  attemptsReset,
  expired,
}
