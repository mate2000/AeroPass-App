// 015 T030 (research.md §7, FR-005, FR-008, FR-009): the in-memory broker
// between 006's one still and 007's polling screen; the job statuses 007
// reads from it; and the selfie counter derived from the server's budget.
import 'dart:async';
import 'dart:typed_data';

import 'package:aeropass_app/app/server_backed_attempt_counter_repository.dart';
import 'package:aeropass_app/app/submission_backed_job_repository.dart';
import 'package:aeropass_app/app/verification_submission.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/domain/entities/capture_attempt_counter.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:aeropass_app/domain/entities/verification_job_status.dart';
import 'package:aeropass_app/domain/entities/verification_outcome.dart';
import 'package:aeropass_app/domain/entities/verification_result.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:aeropass_app/domain/repositories/biometric_verification_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_capture_attempt_counter_repository.dart';
import '../fakes/fake_clock.dart';

class _Verifier implements BiometricVerificationRepository {
  final calls = <Uint8List>[];
  Completer<Result<VerificationResult>> pending = Completer();

  @override
  Future<Result<VerificationResult>> verify(Uint8List selfieJpeg) {
    calls.add(selfieJpeg);
    return pending.future;
  }

  void answer(Result<VerificationResult> result) {
    pending.complete(result);
    pending = Completer();
  }
}

final _selfie = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xD9]);

void main() {
  late _Verifier verifier;
  late VerificationSubmission submission;
  late SubmissionBackedJobRepository jobs;

  setUp(() {
    verifier = _Verifier();
    submission = VerificationSubmission(repository: verifier);
    jobs = SubmissionBackedJobRepository(submission);
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  Future<VerificationOutcome> outcomeAfter(VerificationResult result) async {
    submission.submit(_selfie);
    verifier.answer(Result.ok(result));
    await settle();
    final status = (await jobs.getStatus()).valueOrNull!;
    return (status as VerificationJobCompleted).outcome;
  }

  group('the broker', () {
    test('idle → in flight → done', () async {
      expect(submission.state, isA<SubmissionIdle>());
      expect(submission.submit(_selfie), isTrue);
      expect(submission.state, isA<SubmissionInFlight>());
      verifier.answer(const Result.ok(Verified()));
      await settle();
      expect(submission.state, isA<SubmissionDone>());
      expect(submission.lastResult, isA<Verified>());
    });

    test('a second submit while in flight is refused: one upload', () {
      submission.submit(_selfie);
      expect(submission.submit(_selfie), isFalse);
      expect(verifier.calls, hasLength(1));
    });

    test('an unanswered call ends failed, holding only the error', () async {
      submission.submit(_selfie);
      verifier.answer(const Result.error(TransportFailure.connectivity('x')));
      await settle();
      expect(submission.state, isA<SubmissionFailed>());
    });

    test('reset keeps the last result; clear forgets it', () async {
      await outcomeAfter(
        const Failed(reason: FailureReason.match, remaining: 2),
      );
      submission.reset();
      expect(submission.state, isA<SubmissionIdle>());
      expect(submission.lastResult, isA<Failed>());
      submission.clear();
      expect(submission.lastResult, isNull);
    });
  });

  group("007's job status", () {
    test('idle is an error: there is nothing to observe', () async {
      expect((await jobs.getStatus()).isError, isTrue);
    });

    test('in flight: document passed, face running', () async {
      submission.submit(_selfie);
      expect(
        (await jobs.getStatus()).valueOrNull,
        const VerificationJobStatus.inProgress(
          documentCheck: StageStatus.passed,
          faceComparison: StageStatus.running,
        ),
      );
    });

    test('each result maps to its routing outcome', () async {
      final cases = <VerificationResult, VerificationOutcome>{
        const Verified(): const VerificationOutcome.matched(),
        const Failed(reason: FailureReason.match, remaining: 2):
            const VerificationOutcome.faceMismatch(),
        const Failed(reason: FailureReason.generic, remaining: 2):
            const VerificationOutcome.livenessRejected(),
        const Inconclusive(): const VerificationOutcome.serviceFailure(),
        const NeedsReview(): const VerificationOutcome.manualReview(),
        const StateChanged(): const VerificationOutcome.matched(),
        const NotRegistered(): const VerificationOutcome.documentRejected(),
        const RecaptureSelfie(): const VerificationOutcome.faceMismatch(),
      };
      for (final MapEntry(key: result, value: outcome) in cases.entries) {
        submission.reset();
        expect(await outcomeAfter(result), outcome, reason: '$result');
      }
    });

    test(
      'a connectivity failure stays an error, for the timeout to class',
      () async {
        submission.submit(_selfie);
        verifier.answer(const Result.error(TransportFailure.connectivity('x')));
        await settle();
        expect(
          (await jobs.getStatus()).when(ok: (_) => null, error: (e, _) => e),
          isA<ConnectivityFailure>(),
        );
      },
    );

    test('any other failure is a service failure', () async {
      submission.submit(_selfie);
      verifier.answer(Result.error(StateError('backend')));
      await settle();
      final status =
          (await jobs.getStatus()).valueOrNull! as VerificationJobCompleted;
      expect(status.outcome, const VerificationOutcome.serviceFailure());
    });
  });

  group('the server-backed selfie counter (FR-008)', () {
    late FakeCaptureAttemptCounterRepository local;
    late ServerBackedAttemptCounterRepository counter;

    setUp(() {
      local = FakeCaptureAttemptCounterRepository();
      counter = ServerBackedAttemptCounterRepository(
        local: local,
        submission: submission,
        clock: FakeClock(),
      );
    });

    Future<int> selfieCount() async =>
        (await counter.read(AttemptCounterScope.selfieLiveness))
            .valueOrNull!
            .count;

    test('the count is limit minus intentos_restantes', () async {
      expect(await selfieCount(), 0);
      await outcomeAfter(
        const Failed(reason: FailureReason.match, remaining: 2),
      );
      expect(await selfieCount(), 1);
      submission.reset();
      await outcomeAfter(
        const Failed(reason: FailureReason.generic, remaining: 1),
      );
      expect(await selfieCount(), 2);
    });

    test('review is at the limit', () async {
      await outcomeAfter(const NeedsReview());
      expect(await selfieCount(), captureAttemptLimit);
    });

    test('increment and reset cannot move the server count', () async {
      await outcomeAfter(
        const Failed(reason: FailureReason.match, remaining: 2),
      );
      await counter.increment(AttemptCounterScope.selfieLiveness);
      await counter.increment(AttemptCounterScope.selfieLiveness);
      expect(await selfieCount(), 1);
      await counter.reset(AttemptCounterScope.selfieLiveness);
      expect(await selfieCount(), 1);
    });

    test('the document scope is still the local capture counter', () async {
      await counter.increment(AttemptCounterScope.documentCapture);
      expect(
        (await counter.read(AttemptCounterScope.documentCapture))
            .valueOrNull!
            .count,
        1,
      );
    });
  });
}
