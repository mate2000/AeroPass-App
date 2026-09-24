// Contract: HappyPathFlags.assertReleaseSafe
// (contracts/happy-path-flags-contract.md).
import 'package:aeropass_app/core/happy_path_flags.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('1. releaseMode: false, all flags off -> no throw', () {
    expect(
      () => HappyPathFlags.assertReleaseSafe(
        releaseMode: false,
        enabledFlagNamesOverride: const [],
      ),
      returnsNormally,
    );
  });

  test('2. releaseMode: false, a flag on -> no throw', () {
    expect(
      () => HappyPathFlags.assertReleaseSafe(
        releaseMode: false,
        enabledFlagNamesOverride: const ['USE_FAKE_CONSENT_BACKEND'],
      ),
      returnsNormally,
    );
  });

  test('3. releaseMode: true, all flags off -> no throw', () {
    expect(
      () => HappyPathFlags.assertReleaseSafe(
        releaseMode: true,
        enabledFlagNamesOverride: const [],
      ),
      returnsNormally,
    );
  });

  test('4. releaseMode: true, a flag on -> throws', () {
    expect(
      () => HappyPathFlags.assertReleaseSafe(
        releaseMode: true,
        enabledFlagNamesOverride: const ['USE_FAKE_VERIFICATION_BACKEND'],
      ),
      throwsStateError,
    );
  });

  test("5. the real flags, as compiled into this test binary, are both off "
      '(no --dart-define was passed to `flutter test`) -> the real, '
      'unoverridden call is release-safe', () {
    expect(HappyPathFlags.useFakeConsentBackend, isFalse);
    expect(HappyPathFlags.useFakeVerificationBackend, isFalse);
    expect(
      () => HappyPathFlags.assertReleaseSafe(releaseMode: true),
      returnsNormally,
    );
  });

  // 015 T011: the backend-integration relaxations are release-refused too.
  test('6. the 015 relaxations are off here and release-refused', () {
    expect(HappyPathFlags.allowInsecureLocalBackend, isFalse);
    expect(HappyPathFlags.syntheticCapture, isFalse);
    expect(HappyPathFlags.authMode, AuthMode.clerk);
    for (final flag in const [
      'ALLOW_INSECURE_LOCAL_BACKEND',
      'SYNTHETIC_CAPTURE',
      'AUTH_MODE=test',
    ]) {
      expect(
        () => HappyPathFlags.assertReleaseSafe(
          releaseMode: true,
          enabledFlagNamesOverride: [flag],
        ),
        throwsStateError,
        reason: flag,
      );
    }
  });

  test('7. the mock declaration defaults on', () {
    expect(HappyPathFlags.biometricProviderMock, isTrue);
  });
}
