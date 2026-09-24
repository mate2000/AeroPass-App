import 'package:meta/meta.dart';

import '../../core/result.dart';
import '../entities/passenger_record.dart';

/// Reads the registered passenger (`GET /v1/identity/me`, 015 FR-023).
///
/// `Ok(null)` means not registered (404 `PASAJERO_NO_REGISTRADO`). An
/// `Error` carries a `TransportFailure`, a `SessionUnavailable` or a
/// `BackendError`. It never means "not registered".
abstract class PassengerRepository {
  @useResult
  Future<Result<PassengerRecord?>> me();
}
