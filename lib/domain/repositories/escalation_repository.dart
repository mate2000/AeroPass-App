import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/escalation.dart';

/// The port through which the app opens an escalation and learns its state
/// and outcome (010-escalar-agente, contracts/escalation-port.md).
///
/// It never carries a credential: an agent's approval reaches the app only
/// through 008's `CredentialIssuanceRepository` (FR-011). The case is keyed on
/// the backend by the enrollment attempt id already in the consent record, so
/// nothing new is persisted on the device (research.md §1).
abstract class EscalationRepository {
  /// Opens an escalation for this enrollment, or returns the one already open
  /// (FR-022).
  @useResult
  Future<Result<EscalationCase>> openOrResume({
    required EscalationArrival arrival,
  });

  /// The escalation's current state. A failed read is `Result.error`, never
  /// an outcome.
  @useResult
  Future<Result<EscalationStatus>> getStatus();
}
