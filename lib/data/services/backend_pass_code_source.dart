import '../../app/clock_trust_monitor.dart';
import '../../core/result.dart';
import '../../domain/entities/pass.dart';
import '../../domain/repositories/pass_code_source.dart';
import 'pass_service.dart';
import 'transport_error_mapper.dart';

/// Phase A's code source (014-qr-pase research.md §2): each rotation window's
/// code is fetched from the backend, which the constitution allows today.
/// Offline it is an error, never a stale or guessed payload; offline
/// rotation waits on phase B and the constitution amendment.
class BackendPassCodeSource implements PassCodeSource {
  BackendPassCodeSource(this._service, {required ClockTrustMonitor clockTrust})
    : _clockTrust = clockTrust;

  final PassService _service;
  final ClockTrustMonitor _clockTrust;

  @override
  Future<Result<PassCode>> codeAt(Pass pass, DateTime instant) async {
    try {
      final response = await _service.currentCode(pass.passId);
      final serverTime = DateTime.tryParse(response.serverTime ?? '');
      final start = DateTime.tryParse(response.windowStartsAt ?? '');
      final end = DateTime.tryParse(response.windowEndsAt ?? '');
      final payload = response.payload ?? '';
      if (serverTime == null ||
          start == null ||
          end == null ||
          payload.isEmpty) {
        return Result.error(const FormatException('pass code malformed'));
      }
      _clockTrust.observeServerTime(serverTime.toUtc());
      return Result.ok(
        PassCode(
          payload: payload,
          windowStartsAt: start.toUtc(),
          windowEndsAt: end.toUtc(),
        ),
      );
    } catch (e, st) {
      return Result.error(mapTransportError(e), st);
    }
  }
}
