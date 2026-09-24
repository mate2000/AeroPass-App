// 015-observabilidad-sentry T018: the in-memory current enrollment attempt
// that tags funnel telemetry (research §10, data-model
// CurrentEnrollmentAttempt), and the consent decorator that keeps it current.
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/attempt_tracking_consent_repository.dart';
import 'package:aeropass_app/data/services/current_enrollment_attempt.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';

ConsentRecord _record(
  String attemptId, {
  ConsentRecordStatus status = ConsentRecordStatus.active,
}) => ConsentRecord(
  textVersionId: 'v1',
  enrollmentAttemptId: EnrollmentAttemptId(attemptId),
  scope: ProcessingScope.identityVerification,
  confirmedAt: DateTime.utc(2026, 9, 23),
  status: status,
);

void main() {
  late FakeConsentRepository consent;
  late CurrentEnrollmentAttempt attempt;
  late AttemptTrackingConsentRepository tracking;

  setUp(() {
    consent = FakeConsentRepository();
    attempt = CurrentEnrollmentAttempt(consentRepository: consent);
    tracking = AttemptTrackingConsentRepository(consent, attempt: attempt);
  });

  group('load', () {
    test('without a consent record there is no current attempt', () async {
      await attempt.load();

      expect(attempt.value, isNull);
    });

    test('takes the attempt id of an active local record', () async {
      consent.seedLocalRecord(_record('a-1'));

      await attempt.load();

      expect(attempt.value, EnrollmentAttemptId('a-1'));
    });

    test('a withdrawn or withdrawal-pending record gives no attempt', () async {
      for (final status in [
        ConsentRecordStatus.withdrawn,
        ConsentRecordStatus.withdrawalPending,
      ]) {
        consent.seedLocalRecord(_record('a-1', status: status));
        final fresh = CurrentEnrollmentAttempt(consentRepository: consent);

        await fresh.load();

        expect(fresh.value, isNull, reason: status.name);
      }
    });

    test('does not overwrite an attempt set while it was loading', () async {
      consent.seedLocalRecord(_record('old'));
      final loading = attempt.load();
      attempt.set(EnrollmentAttemptId('new'));

      await loading;

      expect(attempt.value, EnrollmentAttemptId('new'));
    });
  });

  group('AttemptTrackingConsentRepository', () {
    test('an Ok recordConsent sets the new attempt', () async {
      consent.scriptRecordConsent(Result.ok(_record('a-2')));

      final result = await tracking.recordConsent(textVersionId: 'v1');

      expect(result, isA<Ok<ConsentRecord>>());
      expect(attempt.value, EnrollmentAttemptId('a-2'));
    });

    test('an Error recordConsent leaves the attempt unchanged', () async {
      attempt.set(EnrollmentAttemptId('a-1'));
      consent.scriptRecordConsent(Result.error(StateError('offline')));

      final result = await tracking.recordConsent(textVersionId: 'v1');

      expect(result, isA<Error<ConsentRecord>>());
      expect(attempt.value, EnrollmentAttemptId('a-1'));
    });

    test('an Ok withdraw clears the attempt', () async {
      consent.seedLocalRecord(_record('a-1'));
      attempt.set(EnrollmentAttemptId('a-1'));

      await tracking.withdraw();

      expect(attempt.value, isNull);
    });

    test('an Error withdraw leaves the attempt unchanged', () async {
      attempt.set(EnrollmentAttemptId('a-1'));

      final result = await tracking.withdraw();

      expect(result, isA<Error<ConsentRecord>>());
      expect(attempt.value, EnrollmentAttemptId('a-1'));
    });

    test('reads and retries pass through to the wrapped repository', () async {
      consent.seedLocalRecord(_record('a-1'));

      final local = await tracking.getLocalRecord();
      await tracking.retryPendingWithdrawal();
      final text = await tracking.getCurrentText();

      expect(local, Result<ConsentRecord?>.ok(_record('a-1')));
      expect(consent.retryPendingWithdrawalCalled, isTrue);
      expect(consent.getCurrentTextCallCount, 1);
      expect(text, isA<Error<Object?>>());
    });
  });
}
