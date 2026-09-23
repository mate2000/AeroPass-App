import 'dart:developer' as developer;

import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException, PlatformException;

import '../../domain/entities/pass.dart';
import '../../domain/repositories/device_posture_checker.dart';
import '../../domain/repositories/pass_display_guard.dart';

const _channel = MethodChannel('aeropass/pass_display');

/// Pass mode over `aeropass/pass_display` (014-qr-pase FR-006, FR-007,
/// contracts/pass-display-and-posture.md): full brightness, screen kept awake
/// and — on Android — screen capture blocked. A platform without the channel
/// is a no-op, so the pass still shows.
class PlatformPassDisplayGuard implements PassDisplayGuard {
  const PlatformPassDisplayGuard();

  @override
  Future<void> enterPassMode() => _invoke('enterPassMode');

  @override
  Future<void> exitPassMode() => _invoke('exitPassMode');

  Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on PlatformException catch (e) {
      // No data here: only the method name and platform error code.
      developer.log(
        'pass display $method failed: ${e.code}',
        name: 'aeropass.pass',
      );
    } on MissingPluginException {
      developer.log('pass display $method unavailable', name: 'aeropass.pass');
    }
  }
}

/// Device posture over the same channel (constitution Security; FR-023). The
/// platform returns fixed signal names; any signal means compromised. A
/// platform that cannot check reports nothing, recorded as a limitation.
class PlatformDevicePostureChecker implements DevicePostureChecker {
  const PlatformDevicePostureChecker();

  @override
  Future<DevicePosture> check() async {
    try {
      final signals = await _channel.invokeListMethod<String>('devicePosture');
      if (signals == null || signals.isEmpty) {
        return const DevicePosture.trusted();
      }
      return DevicePosture.compromised(signals);
    } on PlatformException catch (e) {
      developer.log('device posture failed: ${e.code}', name: 'aeropass.pass');
      return const DevicePosture.trusted();
    } on MissingPluginException {
      return const DevicePosture.trusted();
    }
  }
}
