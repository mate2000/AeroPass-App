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
  // 015 contracts/flavor-wiring.md.
  'ALLOW_INSECURE_LOCAL_BACKEND',
  'SYNTHETIC_CAPTURE',
  // Fault injection (015 observability, telemetry-events.md §6).
  'CHAOS_TOOLS',
];

/// Keys that must not be set to any value in a release env file.
const releaseForbiddenKeys = [
  'DEV_VERIFICATION_FAILURE',
  'VERCEL_PROTECTION_BYPASS',
  'FAULT_INJECTION_KEY',
];

/// Returns the violations found in [envContents]; empty means release-safe.
List<String> releaseEnvViolations(String envContents) {
  final violations = <String>[];
  final values = <String, String>{};
  for (final raw in envContents.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final separator = line.indexOf('=');
    if (separator <= 0) continue;
    final key = line.substring(0, separator).trim();
    final value = line.substring(separator + 1).trim();
    values[key] = value;
    final lower = value.toLowerCase();
    if (releaseForbiddenBooleans.contains(key) &&
        lower != 'false' &&
        lower.isNotEmpty) {
      violations.add('$key=$lower');
    }
    if (releaseForbiddenKeys.contains(key) && lower.isNotEmpty) {
      violations.add('$key=$lower');
    }
  }
  violations.addAll(_backendViolations(values));
  return violations;
}

/// 015 contracts/flavor-wiring.md: a release talks to a real https backend
/// through Clerk, and the mock declaration comes off only when a real
/// provider is named (FR-020).
List<String> _backendViolations(Map<String, String> values) {
  final violations = <String>[];

  final baseUrl = values['API_BASE_URL'] ?? '';
  if (baseUrl.isEmpty) {
    violations.add('API_BASE_URL missing');
  } else if (!baseUrl.startsWith('https://') || baseUrl.contains('.example')) {
    violations.add('API_BASE_URL=$baseUrl');
  }

  final authMode = values['AUTH_MODE'] ?? '';
  if (authMode.isEmpty) {
    violations.add('AUTH_MODE missing');
  } else if (authMode != 'clerk') {
    violations.add('AUTH_MODE=$authMode');
  } else if ((values['CLERK_PUBLISHABLE_KEY'] ?? '').isEmpty) {
    violations.add('CLERK_PUBLISHABLE_KEY missing');
  }

  final mockOff = (values['BIOMETRIC_PROVIDER_MOCK'] ?? '').toLowerCase() ==
      'false';
  final provider = (values['BIOMETRIC_PROVIDER_NAME'] ?? '').toLowerCase();
  if (mockOff && (provider.isEmpty || provider == 'mock')) {
    violations.add('BIOMETRIC_PROVIDER_MOCK=false without a provider');
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
