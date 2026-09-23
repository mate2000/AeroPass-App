// Contract: LivenessVerificationRepository
// (contracts/liveness-verification-port.md).
//
// The same 8-case suite runs against BOTH the fake and the real
// implementation, unmodified — Constitution Principle X's Liskov
// requirement.
import 'dart:io';
import 'dart:typed_data';

import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/liveness_verification_repository_impl.dart';
import 'package:aeropass_app/data/services/liveness_verification_service.dart';
import 'package:aeropass_app/domain/entities/liveness_outcome.dart';
import 'package:aeropass_app/domain/entities/liveness_phase.dart';
import 'package:aeropass_app/domain/entities/liveness_sample_outcome.dart';
import 'package:aeropass_app/domain/repositories/liveness_verification_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_http_client_adapter.dart';
import '../fakes/fake_liveness_verification_repository.dart';

void main() {
  group('Fake implementation', () {
    _runContractTests(_FakeHarnessFactory());
  });

  group('Real implementation', () {
    _runContractTests(_RealHarnessFactory());
  });
}

Uint8List get _sampleFrame => Uint8List.fromList(List.filled(16, 1));

void _runContractTests(_HarnessFactory factory) {
  test(
    '1. startSession() succeeds -> Ok(sessionId), a non-empty string',
    () async {
      final harness = factory.create();
      harness.givenStartSessionSucceeds('session-abc');

      final result = await harness.repository.startSession();

      final sessionId = result.valueOrNull;
      expect(sessionId, isNotNull);
      expect(sessionId, isNotEmpty);
    },
  );

  test('2. startSession() transport failure -> Error', () async {
    final harness = factory.create();
    harness.givenStartSessionTransportFailure();

    final result = await harness.repository.startSession();

    expect(result.isError, isTrue);
  });

  test('3. submitSample() mid-attempt, processor reports phase 2 of 4 -> '
      'Ok(inProgress(phase: index 1, totalPhases 4))', () async {
    final harness = factory.create();
    harness.givenStartSessionSucceeds('session-abc');
    final sessionId = (await harness.repository.startSession()).valueOrNull!;
    harness.givenSampleInProgress(phaseIndex: 1, totalPhases: 4);

    final result = await harness.repository.submitSample(
      sessionId: sessionId,
      frameBytes: _sampleFrame,
    );

    final outcome = result.valueOrNull;
    expect(outcome, isA<LivenessSampleOutcomeInProgress>());
    final phase = (outcome as LivenessSampleOutcomeInProgress).phase;
    expect(phase.index, 1);
    expect(phase.totalPhases, 4);
  });

  test('4. submitSample() final sample, processor reports success -> '
      'Ok(completed(outcome: success))', () async {
    final harness = factory.create();
    harness.givenStartSessionSucceeds('session-abc');
    final sessionId = (await harness.repository.startSession()).valueOrNull!;
    harness.givenSampleSuccess();

    final result = await harness.repository.submitSample(
      sessionId: sessionId,
      frameBytes: _sampleFrame,
    );

    expect(
      result,
      const Result<LivenessSampleOutcome>.ok(
        LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()),
      ),
    );
  });

  test(
    '5. submitSample(), processor reports a known quality-failure code '
    '("too dark") -> Ok(completed(outcome: qualityFailure(tooDark)))',
    () async {
      final harness = factory.create();
      harness.givenStartSessionSucceeds('session-abc');
      final sessionId = (await harness.repository.startSession()).valueOrNull!;
      harness.givenSampleQualityFailure('too_dark');

      final result = await harness.repository.submitSample(
        sessionId: sessionId,
        frameBytes: _sampleFrame,
      );

      expect(
        result,
        const Result<LivenessSampleOutcome>.ok(
          LivenessSampleOutcome.completed(
            outcome: LivenessOutcome.qualityFailure(
              reason: LivenessQualityReason.tooDark,
            ),
          ),
        ),
      );
    },
  );

  test('6. submitSample(), processor reports an attack-detection code -> '
      'Ok(completed(outcome: attackDetected())), a distinct domain value from '
      'unclassifiedFailure()', () async {
    final harness = factory.create();
    harness.givenStartSessionSucceeds('session-abc');
    final sessionId = (await harness.repository.startSession()).valueOrNull!;
    harness.givenSampleAttackDetected();

    final result = await harness.repository.submitSample(
      sessionId: sessionId,
      frameBytes: _sampleFrame,
    );

    final outcome = result.valueOrNull;
    expect(outcome, isA<LivenessSampleOutcomeCompleted>());
    final terminal = (outcome as LivenessSampleOutcomeCompleted).outcome;
    expect(terminal, isA<LivenessOutcomeAttackDetected>());
    expect(terminal, isNot(isA<LivenessOutcomeUnclassifiedFailure>()));
  });

  test('7. submitSample(), processor reports a code the mapping does not '
      'recognize -> still resolves to Ok(completed(outcome: '
      'unclassifiedFailure())), never an unhandled exception', () async {
    final harness = factory.create();
    harness.givenStartSessionSucceeds('session-abc');
    final sessionId = (await harness.repository.startSession()).valueOrNull!;
    harness.givenSampleUnrecognizedOutcome();

    final result = await harness.repository.submitSample(
      sessionId: sessionId,
      frameBytes: _sampleFrame,
    );

    expect(
      result,
      const Result<LivenessSampleOutcome>.ok(
        LivenessSampleOutcome.completed(
          outcome: LivenessOutcome.unclassifiedFailure(),
        ),
      ),
    );
  });

  test('8. submitSample() transport failure -> Error', () async {
    final harness = factory.create();
    harness.givenStartSessionSucceeds('session-abc');
    final sessionId = (await harness.repository.startSession()).valueOrNull!;
    harness.givenSampleTransportFailure();

    final result = await harness.repository.submitSample(
      sessionId: sessionId,
      frameBytes: _sampleFrame,
    );

    expect(result.isError, isTrue);
  });
}

/// Stages a contract scenario's preconditions, independently of which
/// implementation backs [repository].
abstract class _Harness {
  LivenessVerificationRepository get repository;

  void givenStartSessionSucceeds(String sessionId);
  void givenStartSessionTransportFailure();
  void givenSampleInProgress({
    required int phaseIndex,
    required int totalPhases,
  });
  void givenSampleSuccess();
  void givenSampleQualityFailure(String reasonCode);
  void givenSampleAttackDetected();
  void givenSampleUnrecognizedOutcome();
  void givenSampleTransportFailure();
}

abstract class _HarnessFactory {
  _Harness create();
}

// --- Fake-backed harness -------------------------------------------------

class _FakeHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _FakeHarness();
}

class _FakeHarness implements _Harness {
  final _repo = FakeLivenessVerificationRepository();

  @override
  LivenessVerificationRepository get repository => _repo;

  @override
  void givenStartSessionSucceeds(String sessionId) {
    _repo.scriptStartSession(Result.ok(sessionId));
  }

  @override
  void givenStartSessionTransportFailure() {
    _repo.scriptStartSession(Result.error(const SocketException('offline')));
  }

  @override
  void givenSampleInProgress({
    required int phaseIndex,
    required int totalPhases,
  }) {
    _repo.scriptSubmitSample(
      Result.ok(
        LivenessSampleOutcome.inProgress(
          phase: LivenessPhase(
            index: phaseIndex,
            totalPhases: totalPhases,
            instruction: const LivenessInstruction.holdStill(),
          ),
        ),
      ),
    );
  }

  @override
  void givenSampleSuccess() {
    _repo.scriptSubmitSample(
      const Result.ok(
        LivenessSampleOutcome.completed(outcome: LivenessOutcome.success()),
      ),
    );
  }

  @override
  void givenSampleQualityFailure(String reasonCode) {
    final reason = switch (reasonCode) {
      'too_dark' => LivenessQualityReason.tooDark,
      'face_out_of_frame' => LivenessQualityReason.faceOutOfFrame,
      'movement_detected' => LivenessQualityReason.movementDetected,
      'multiple_faces_detected' => LivenessQualityReason.multipleFacesDetected,
      _ => LivenessQualityReason.faceObstructed,
    };
    _repo.scriptSubmitSample(
      Result.ok(
        LivenessSampleOutcome.completed(
          outcome: LivenessOutcome.qualityFailure(reason: reason),
        ),
      ),
    );
  }

  @override
  void givenSampleAttackDetected() {
    _repo.scriptSubmitSample(
      const Result.ok(
        LivenessSampleOutcome.completed(
          outcome: LivenessOutcome.attackDetected(),
        ),
      ),
    );
  }

  @override
  void givenSampleUnrecognizedOutcome() {
    _repo.scriptSubmitSample(
      const Result.ok(
        LivenessSampleOutcome.completed(
          outcome: LivenessOutcome.unclassifiedFailure(),
        ),
      ),
    );
  }

  @override
  void givenSampleTransportFailure() {
    _repo.scriptSubmitSample(Result.error(const SocketException('offline')));
  }
}

// --- Real-backed harness --------------------------------------------------

class _RealHarnessFactory implements _HarnessFactory {
  @override
  _Harness create() => _RealHarness();
}

class _RealHarness implements _Harness {
  _RealHarness() {
    _dio.httpClientAdapter = _adapter;
  }

  final _adapter = FakeHttpClientAdapter();
  final _dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));

  late final _service = LivenessVerificationService(dio: _dio);
  late final LivenessVerificationRepositoryImpl _repo =
      LivenessVerificationRepositoryImpl(_service);

  @override
  LivenessVerificationRepository get repository => _repo;

  @override
  void givenStartSessionSucceeds(String sessionId) {
    _adapter.respondWith({'sessionId': sessionId});
  }

  @override
  void givenStartSessionTransportFailure() {
    _adapter.failWith(const SocketException('unreachable'));
  }

  @override
  void givenSampleInProgress({
    required int phaseIndex,
    required int totalPhases,
  }) {
    _adapter.respondWith({
      'status': 'in_progress',
      'phaseIndex': phaseIndex,
      'totalPhases': totalPhases,
      'instruction': 'hold_still',
    });
  }

  @override
  void givenSampleSuccess() {
    _adapter.respondWith({'status': 'completed', 'outcome': 'success'});
  }

  @override
  void givenSampleQualityFailure(String reasonCode) {
    _adapter.respondWith({
      'status': 'completed',
      'outcome': 'quality_failure',
      'reason': reasonCode,
    });
  }

  @override
  void givenSampleAttackDetected() {
    _adapter.respondWith({'status': 'completed', 'outcome': 'attack_detected'});
  }

  @override
  void givenSampleUnrecognizedOutcome() {
    _adapter.respondWith({
      'status': 'completed',
      'outcome': 'some_new_unmapped_code',
    });
  }

  @override
  void givenSampleTransportFailure() {
    _adapter.failWith(const SocketException('unreachable'));
  }
}
