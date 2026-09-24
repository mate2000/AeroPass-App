import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/repositories/device_posture_checker.dart';
import 'package:aeropass_app/domain/repositories/pass_code_source.dart';
import 'package:aeropass_app/domain/repositories/pass_display_guard.dart';

/// A code per rotation window, `TEST.<window>`; or an error while [failing].
class FakePassCodeSource implements PassCodeSource {
  bool failing = false;
  int callCount = 0;

  /// 015: marks every code as a still-valid code whose renewal failed.
  bool renewalPending = false;

  @override
  Future<Result<PassCode>> codeAt(Pass pass, DateTime instant) async {
    callCount++;
    if (failing) return Result.error(StateError('offline'));
    final seconds = pass.rotation.inSeconds;
    final window = instant.toUtc().millisecondsSinceEpoch ~/ 1000 ~/ seconds;
    final start = DateTime.fromMillisecondsSinceEpoch(
      window * seconds * 1000,
      isUtc: true,
    );
    return Result.ok(
      PassCode(
        payload: 'TEST.$window',
        windowStartsAt: start,
        windowEndsAt: start.add(pass.rotation),
        renewalPending: renewalPending,
      ),
    );
  }
}

/// Counts pass-mode transitions and remembers whether it is on.
class FakePassDisplayGuard implements PassDisplayGuard {
  int enterCount = 0;
  int exitCount = 0;
  bool on = false;

  @override
  Future<void> enterPassMode() async {
    enterCount++;
    on = true;
  }

  @override
  Future<void> exitPassMode() async {
    exitCount++;
    on = false;
  }
}

class FakeDevicePostureChecker implements DevicePostureChecker {
  FakeDevicePostureChecker([this.posture = const DevicePosture.trusted()]);

  DevicePosture posture;
  int callCount = 0;

  @override
  Future<DevicePosture> check() async {
    callCount++;
    return posture;
  }
}
