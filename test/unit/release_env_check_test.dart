// 014-qr-pase T008 (contracts/release-gate.md): a release build can never
// carry "Simular expirado" or any other development flag.
import 'dart:io';

import 'package:aeropass_app/core/happy_path_flags.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_release_env.dart';

/// A release-valid base (015 rules), so each older test sees only the
/// violation it is about.
const _base = '''
API_BASE_URL=https://aeropass-lac.vercel.app
AUTH_MODE=clerk
CLERK_PUBLISHABLE_KEY=pk_test_x
''';

void main() {
  test('DEV_PASS_CONTROLS=true fails the release check', () {
    expect(releaseEnvViolations('${_base}DEV_PASS_CONTROLS=true\n'), [
      'DEV_PASS_CONTROLS=true',
    ]);
  });

  test('every forbidden flag is caught; false and comments are fine', () {
    const env =
        '''
$_base
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

  test('chaos tools and the Preview bypass secret fail the release check', () {
    const env =
        '''
$_base
CHAOS_TOOLS=true
VERCEL_PROTECTION_BYPASS=secret
FAULT_INJECTION_KEY=key
''';
    expect(releaseEnvViolations(env), [
      'CHAOS_TOOLS=true',
      'VERCEL_PROTECTION_BYPASS=secret',
      'FAULT_INJECTION_KEY=key',
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

  // 015 T010 (contracts/flavor-wiring.md): the release check also enforces
  // the backend-integration flags, auth mode, base URL and mock pairing.
  group('015 release rules', () {
    const valid = '''
API_BASE_URL=https://aeropass-lac.vercel.app
AUTH_MODE=clerk
CLERK_PUBLISHABLE_KEY=pk_test_x
BIOMETRIC_PROVIDER_MOCK=true
''';

    test('a valid prod env passes', () {
      expect(releaseEnvViolations(valid), isEmpty);
    });

    test('insecure local backend and synthetic capture are refused', () {
      expect(
        releaseEnvViolations(
          '${valid}ALLOW_INSECURE_LOCAL_BACKEND=true\nSYNTHETIC_CAPTURE=true\n',
        ),
        ['ALLOW_INSECURE_LOCAL_BACKEND=true', 'SYNTHETIC_CAPTURE=true'],
      );
    });

    test('test auth, or no auth mode, is refused', () {
      expect(
        releaseEnvViolations(
          valid.replaceFirst('AUTH_MODE=clerk', 'AUTH_MODE=test'),
        ),
        contains('AUTH_MODE=test'),
      );
      expect(
        releaseEnvViolations(valid.replaceFirst('AUTH_MODE=clerk\n', '')),
        contains('AUTH_MODE missing'),
      );
    });

    test('clerk auth needs a publishable key', () {
      expect(
        releaseEnvViolations(
          valid.replaceFirst('CLERK_PUBLISHABLE_KEY=pk_test_x\n', ''),
        ),
        contains('CLERK_PUBLISHABLE_KEY missing'),
      );
    });

    test('the base URL must be https and not a placeholder host', () {
      expect(
        releaseEnvViolations(
          valid.replaceFirst(
            'https://aeropass-lac.vercel.app',
            'http://10.0.2.2:8000',
          ),
        ),
        contains('API_BASE_URL=http://10.0.2.2:8000'),
      );
      expect(
        releaseEnvViolations(
          valid.replaceFirst(
            'https://aeropass-lac.vercel.app',
            'https://api.aeropass.example',
          ),
        ),
        contains('API_BASE_URL=https://api.aeropass.example'),
      );
      expect(
        releaseEnvViolations(
          valid.replaceFirst(RegExp(r'API_BASE_URL=.*\n'), ''),
        ),
        contains('API_BASE_URL missing'),
      );
    });

    test('the mock declaration turns off only with a real provider named', () {
      final off = valid.replaceFirst(
        'BIOMETRIC_PROVIDER_MOCK=true',
        'BIOMETRIC_PROVIDER_MOCK=false',
      );
      const violation = 'BIOMETRIC_PROVIDER_MOCK=false without a provider';
      expect(releaseEnvViolations(off), contains(violation));
      expect(
        releaseEnvViolations('${off}BIOMETRIC_PROVIDER_NAME=mock\n'),
        contains(violation),
      );
      expect(
        releaseEnvViolations('${off}BIOMETRIC_PROVIDER_NAME=acme\n'),
        isEmpty,
      );
    });
  });
}
