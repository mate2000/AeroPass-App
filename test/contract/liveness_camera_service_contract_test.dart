// Contract: LivenessCameraService
// (contracts/liveness-camera-service-port.md).
//
// Run only against the fake — `FrontCameraLivenessService` wraps the
// `camera` plugin's platform channels, which have no real implementation
// available in a `flutter_test` environment (the same reason
// 003-escanear-documento's `CameraCaptureService` has no dual-implementation
// contract test either; hardware-lifecycle boundaries are exempted from
// Principle X's Liskov suite for exactly this reason, unlike
// network-backed ports which a scripted HTTP adapter can stand in for).
import 'dart:typed_data';

import 'package:aeropass_app/data/services/liveness_camera_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_liveness_camera_service.dart';

void main() {
  late LivenessCameraService service;

  setUp(() {
    service = FakeLivenessCameraService();
  });

  test('1. start() succeeds -> controller becomes non-null and initialized', () async {
    // The fake never exposes a real CameraController (contract note:
    // `controller` is nullable specifically so a fake never needs one), so
    // this case is proven instead by `started` — the fake's stand-in for
    // "the controller became usable" for tests that can't touch platform
    // channels at all.
    final fake = service as FakeLivenessCameraService;

    await service.start();

    expect(fake.started, isTrue);
  });

  test('2. start() fails (no front camera, permission denied) -> throws', () async {
    final fake = service as FakeLivenessCameraService;
    fake.failStartWith(StateError('no front camera available'));

    expect(() => service.start(), throwsA(isA<StateError>()));
  });

  test('3. sampleFrame() before start() completes -> null, never throws', () {
    expect(service.sampleFrame(), isNull);
  });

  test('4. sampleFrame() after start() -> non-null bytes', () async {
    final fake = service as FakeLivenessCameraService;
    final frame = Uint8List.fromList([1, 2, 3]);
    fake.scriptFrame(frame);

    await service.start();

    expect(service.sampleFrame(), frame);
  });

  test('5. stop() releases the controller; a subsequent sampleFrame() -> null', () async {
    final fake = service as FakeLivenessCameraService;
    fake.scriptFrame(Uint8List.fromList([1, 2, 3]));
    await service.start();

    await service.stop();

    expect(service.sampleFrame(), isNull);
  });

  test(
    '6. stop() is safe to call when never started, and safe to call twice '
    'in a row',
    () async {
      await service.stop();

      await service.start();
      await service.stop();
      await service.stop();
    },
  );
}
