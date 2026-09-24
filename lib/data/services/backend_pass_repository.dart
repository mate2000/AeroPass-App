import '../../app/clock_trust_monitor.dart';
import '../../core/result.dart';
import '../../domain/entities/backend_error.dart';
import '../../domain/entities/pass.dart';
import '../../domain/entities/session_state.dart';
import '../../domain/repositories/pass_repository.dart';
import '../models/backend/backend_enums.dart';
import '../models/backend/pase_dto.dart';
import 'backend_error_mapper.dart';
import 'pass_service.dart';

/// The pass currently held, in memory only (015 research.md §10).
class IssuedPass {
  const IssuedPass({
    required this.pass,
    required this.token,
    required this.issuedAt,
    required this.renewAt,
  });

  final Pass pass;

  /// The signed JWS shown as the QR code. It is never logged or persisted.
  final String token;
  final DateTime issuedAt;

  /// `emitida_at + renovar_en_segundos`.
  final DateTime renewAt;

  @override
  String toString() => 'IssuedPass(${pass.passId})';
}

/// 014's [PassRepository] against the real backend (015 FR-010 to FR-013,
/// FR-015, FR-015b).
///
/// - [issue] takes the flight code, which is the trip for DEC-03. Each call
///   is a new credential, because the backend revokes or refreshes the
///   previous one. The newest is always the current pass.
/// - [status] reads the **current** credential, whatever id it is given.
///   After a renewal, the old id is `REVOCADA`, which would be a false
///   revocation.
/// - `CONSUMIDA` is boarded: success, not an error.
/// - The server clock comes from `emitida_at` at receipt (research.md §10).
/// - Nothing is persisted: no token, no flight code (Q3 of clarify).
class BackendPassRepository implements PassRepository {
  BackendPassRepository(
    this._service, {
    required ClockTrustMonitor clockTrustMonitor,
  }) : _clockTrust = clockTrustMonitor;

  final PassService _service;
  final ClockTrustMonitor _clockTrust;

  IssuedPass? _current;

  /// For the code source: the token and its renewal time.
  IssuedPass? get current => _current;

  @override
  Future<Result<Pass>> issue(String flightCode) async {
    try {
      final dto = await _service.issue(flightCode);
      _clockTrust.observeServerTime(dto.emitidaAt);
      final issued = _issuedFrom(dto);
      _current = issued;
      return Result.ok(issued.pass);
    } catch (e, st) {
      return Result.error(_refusalFor(mapBackendError(e)), st);
    }
  }

  @override
  Future<Result<PassState>> status(String passId) async {
    final current = _current;
    if (current == null) return Result.error(StateError('no pass held'));
    try {
      final dto = await _service.detail(current.pass.passId);
      if (_current?.pass.passId != dto.credencialId) {
        // A renewal replaced the pass while this read was in flight.
        return Result.ok(PassState.active(_current!.pass));
      }
      return Result.ok(switch (dto.estado) {
        EstadoCredencialWire.emitida ||
        EstadoCredencialWire.activa => PassState.active(current.pass),
        EstadoCredencialWire.consumida => const PassState.boarded(),
        EstadoCredencialWire.expirada => const PassState.expired(),
        EstadoCredencialWire.revocada => const PassState.revoked(),
      });
    } catch (e, st) {
      final mapped = mapBackendError(e);
      if (mapped is BackendError) {
        switch (mapped.code) {
          case BackendErrorCode.credencialNoEncontrada:
            return const Result.ok(PassState.expired());
          case BackendErrorCode.noAutenticado:
            return Result.error(const SessionUnavailable(), st);
          default:
            break;
        }
      }
      return Result.error(mapped, st);
    }
  }

  @override
  Pass? activePassFor(String tripId) {
    final current = _current;
    if (current == null || current.pass.tripId != tripId) return null;
    if (!_clockTrust.serverNow().isBefore(current.pass.validUntil)) {
      _current = null;
      return null;
    }
    return current.pass;
  }

  @override
  Future<void> forget(String passId) async {
    if (_current?.pass.passId == passId) _current = null;
  }

  IssuedPass _issuedFrom(PaseDto dto) {
    // 'seguridad' is not issued today; the mapping is ready for it.
    final checkpoints = {
      for (final permiso in dto.permisos)
        ?switch (permiso) {
          'embarque' => Checkpoint.boarding,
          'seguridad' => Checkpoint.security,
          _ => null,
        },
    };
    final renewAfter = Duration(seconds: dto.renovarEnSegundos);
    return IssuedPass(
      pass: Pass(
        passId: dto.credencialId,
        tripId: dto.codigoVuelo,
        nextCheckpoint: checkpoints.contains(Checkpoint.security)
            ? Checkpoint.security
            : Checkpoint.boarding,
        validUntil: dto.expiraAt.toUtc(),
        rotation: renewAfter,
        checkpoints: checkpoints,
      ),
      token: dto.token,
      issuedAt: dto.emitidaAt.toUtc(),
      renewAt: dto.emitidaAt.toUtc().add(renewAfter),
    );
  }

  static Object _refusalFor(Object mapped) {
    if (mapped is! BackendError) return mapped;
    return switch (mapped.code) {
      BackendErrorCode.documentoVencido => const PassIssueRefused(
        PassIssueRefusal.documentExpired,
      ),
      BackendErrorCode.identidadNoActiva => const PassIssueRefused(
        PassIssueRefusal.identityNotActive,
      ),
      BackendErrorCode.datosInvalidos => const PassIssueRefused(
        PassIssueRefusal.invalidFlightCode,
      ),
      BackendErrorCode.limiteEmisionExcedido ||
      BackendErrorCode.almacenamientoNoDisponible => PassIssueRefused(
        PassIssueRefusal.busy,
        retryAfter: mapped.retryAfter,
      ),
      BackendErrorCode.noAutenticado => const SessionUnavailable(),
      _ => mapped,
    };
  }
}
