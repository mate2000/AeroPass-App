// 014-qr-pase T008 (contracts/release-gate.md): a release build can never
// carry "Simular expirado" or any other development flag.
import 'dart:io';

import 'package:aeropass_app/core/happy_path_flags.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_release_env.dart';

void main() {
  test('DEV_PASS_CONTROLS=true fails the release check', () {
    expect(releaseEnvViolations('API_BASE_URL=x\nDEV_PASS_CONTROLS=true\n'), [
      'DEV_PASS_CONTROLS=true',
    ]);
  });

  test('every forbidden flag is caught; false and comments are fine', () {
    const env = '''
# DEV_PASS_CONTROLS=true
USE_FAKE_CONSENT_BACKEND=true
USE_FAKE_VERIFICATION_BACKEND=1
DEV_PASS_CONTROLS=false
DEV_VERIFICATION_FAILURE=hang
SENTRY_ENVIRONMENT=prod
''';
    expect(releaseEnvViolations(env), [
      'USE_FAKE_CONSENT_BACKEND=true',
      'USE_FAKE_VERIFICATION_BACKEND=1',
      'DEV_VERIFICATION_FAILURE=hang',
    ]);
  });

  test('env/prod.env has no development flags', () {
    final contents = File('env/prod.env').readAsStringSync();
    expect(releaseEnvViolations(contents), isEmpty);
  });

  test('a release build refuses to start with DEV_PASS_CONTROLS on', () {
    expect(
      () => HappyPathFlags.assertReleaseSafe(
        releaseMode: true,
        enabledFlagNamesOverride: ['DEV_PASS_CONTROLS'],
      ),
      throwsStateError,
    );
  });

  test('the flag is off by default', () {
    expect(HappyPathFlags.devPassControls, isFalse);
  });
}
