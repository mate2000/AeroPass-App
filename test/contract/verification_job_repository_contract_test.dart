// 007-validando T011: Contract — VerificationJobRepository
// (contracts/verification-job-port.md). The real implementation runs all
// ten cases; the schedule-driven dev fake always ends `matched`
// (research.md §14), so it runs cases 1–3 in time order.

import 'package:aeropass_app/data/dev/dev_verification_job_repository.dart';
import 'package:aeropass_app/domain/entities/verification_job_status.dart';
import 'package:aeropass_app/domain/entities/verification_outcome.dart';
import 'package:aeropass_app/domain/entities/verification_stage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dev fake', () {
    test(
      '1–3. document, then face, then matched, on its own schedule',
      () async {
        var now = DateTime.utc(2026, 9, 23, 12);
        final dev = DevVerificationJobRepository(now: () => now);

        final first = (await dev.getStatus()).valueOrNull;
        expect(
          first,
          const VerificationJobStatus.inProgress(
            documentCheck: StageStatus.running,
            faceComparison: StageStatus.pending,
          ),
        );

        now = now.add(const Duration(milliseconds: 1600));
        expect(
          (await dev.getStatus()).valueOrNull,
          const VerificationJobStatus.inProgress(
            documentCheck: StageStatus.passed,
            faceComparison: StageStatus.running,
          ),
        );

        now = now.add(const Duration(milliseconds: 1600));
        expect(
          (await dev.getStatus()).valueOrNull,
          const VerificationJobStatus.completed(
            outcome: VerificationOutcome.matched(),
            documentCheck: StageStatus.passed,
            faceComparison: StageStatus.passed,
          ),
        );
      },
    );
  });

  // 011-error-tecnico T021/T037: contracts/transport-failure-addendum.md.
}
