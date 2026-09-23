import 'dart:typed_data';

import 'package:aeropass_app/data/dev/dev_liveness_camera_service.dart';
import 'package:aeropass_app/data/dev/dev_liveness_verification_repository.dart';
import 'package:aeropass_app/domain/entities/liveness_sample_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_liveness_camera_service.dart';

void main() {
  group('DevLivenessCameraService', () {
    test('uses the real camera frames when the camera starts', () async {
      final realCamera = FakeLivenessCameraService()
        ..scriptFrame(Uint8List.fromList([7, 7, 7]));
      final service = DevLivenessCameraService(realCamera: realCamera);

      await service.start();

      expect(realCamera.startCallCount, 1);
      expect(service.sampleFrame(), Uint8List.fromList([7, 7, 7]));

      await service.stop();
      expect(realCamera.stopCallCount, 1);
      expect(service.sampleFrame(), isNull);
    });

    test(
      'falls back to scripted frames when the camera cannot start',
      () async {
        final realCamera = FakeLivenessCameraService()
          ..failStartWith(StateError('no camera available on this device'));
        final service = DevLivenessCameraService(realCamera: realCamera);

        await service.start();

        expect(service.controller, isNull);
        expect(service.sampleFrame(), isNotNull);

        await service.stop();
        expect(realCamera.stopCallCount, 0);
        expect(service.sampleFrame(), isNull);
      },
    );
  });

  group('DevLivenessVerificationRepository', () {
    test('waits phaseDuration before reporting each phase', () async {
      const phaseDuration = Duration(milliseconds: 100);
      final repository = DevLivenessVerificationRepository(
        phaseDuration: phaseDuration,
      );
      final stopwatch = Stopwatch()..start();

      final result = await repository.submitSample(
        sessionId: 'dev',
        frameBytes: Uint8List(1),
      );

      expect(stopwatch.elapsed, greaterThanOrEqualTo(phaseDuration));
      expect(result.valueOrNull, isA<LivenessSampleOutcomeInProgress>());
    });

    test('completes with success on the fourth sample', () async {
      final repository = DevLivenessVerificationRepository(
        phaseDuration: Duration.zero,
      );
      await repository.startSession();

      LivenessSampleOutcome? outcome;
      for (var i = 0; i < 4; i++) {
        final result = await repository.submitSample(
          sessionId: 'dev',
          frameBytes: Uint8List(1),
        );
        outcome = result.valueOrNull;
      }

      expect(outcome, isA<LivenessSampleOutcomeCompleted>());
    });
  });
}
