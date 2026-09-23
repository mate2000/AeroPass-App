// 014-qr-pase FR-019, SC-006 (contracts/release-gate.md): fails the release
// pipeline when a release env file enables any happy-path development flag,
// including the pass's "Simular expirado" control.
//
// Usage: dart run tool/check_release_env.dart env/prod.env
import 'dart:io';

/// Flags that must be absent or false in a release env file.
const releaseForbiddenBooleans = [
  'USE_FAKE_CONSENT_BACKEND',
  'USE_FAKE_VERIFICATION_BACKEND',
  'DEV_PASS_CONTROLS',
];

/// Keys that must not be set to any value in a release env file.
const releaseForbiddenKeys = ['DEV_VERIFICATION_FAILURE'];

/// Returns the violations found in [envContents]; empty means release-safe.
List<String> releaseEnvViolations(String envContents) {
  final violations = <String>[];
  for (final raw in envContents.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final separator = line.indexOf('=');
    if (separator <= 0) continue;
    final key = line.substring(0, separator).trim();
    final value = line.substring(separator + 1).trim().toLowerCase();
    if (releaseForbiddenBooleans.contains(key) &&
        value != 'false' &&
        value.isNotEmpty) {
      violations.add('$key=$value');
    }
    if (releaseForbiddenKeys.contains(key) && value.isNotEmpty) {
      violations.add('$key=$value');
    }
  }
  return violations;
}

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: dart run tool/check_release_env.dart <env-file>');
    exit(64);
  }
  final file = File(args.single);
  if (!file.existsSync()) {
    stderr.writeln('release env file not found: ${args.single}');
    exit(66);
  }
  final violations = releaseEnvViolations(file.readAsStringSync());
  if (violations.isNotEmpty) {
    stderr.writeln(
      'Release env ${args.single} enables development flags, which MUST NOT '
      'ship (constitution Principle III, 014 FR-019):\n  '
      '${violations.join('\n  ')}',
    );
    exit(1);
  }
  stdout.writeln('Release env ${args.single}: no development flags.');
}
