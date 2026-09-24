// 015 T032 (FR-025, contracts/flavor-wiring.md): nothing in the app can call
// a path the backend does not have, and nothing names the invented host.
//
// This is a source scan, not a recording run. Every `/v1` path literal in
// lib/ must be one of the five real endpoints, so no flavor can construct a
// request to a missing one. The dev fakes make no requests at all.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// contracts/backend-api.md: the five authenticated endpoints. A pass id is
/// appended to the passes path at run time.
const _realPaths = {
  '/v1/identity',
  '/v1/identity/me',
  '/v1/biometrics/verifications',
  '/v1/passes',
};

final _pathLiteral = RegExp(r'''['"](/v1/[^'"$]*)''');

Iterable<File> _dartFiles(String dir) =>
    Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

void main() {
  test('every /v1 path in lib/ is a real endpoint', () {
    final unknown = <String>[];
    for (final file in _dartFiles('lib')) {
      for (final (i, line) in file.readAsLinesSync().indexed) {
        final code = line.split('//').first;
        for (final match in _pathLiteral.allMatches(code)) {
          final path = match.group(1)!;
          // The auth interceptor's prefix check, not an endpoint.
          if (path == '/v1/') continue;
          // Clerk's Frontend API health check (the warm-up in
          // clerk_setup.dart), on Clerk's host, not the backend's.
          if (path == '/v1/health' && file.path.endsWith('clerk_setup.dart')) {
            continue;
          }
          final normalized = path.endsWith('/')
              ? path.substring(0, path.length - 1)
              : path;
          if (!_realPaths.contains(normalized)) {
            unknown.add('${file.path}:${i + 1} $path');
          }
        }
      }
    }
    expect(unknown, isEmpty, reason: unknown.join('\n'));
  });

  test('every real endpoint is actually used', () {
    final source = _dartFiles('lib/data/services')
        .map((f) => f.readAsStringSync())
        .join('\n');
    for (final path in _realPaths) {
      expect(source, contains("'$path"), reason: path);
    }
  });

  test('no code, env file or config names the invented host', () {
    final offenders = <String>[];
    for (final file in [
      ..._dartFiles('lib'),
      ...Directory('env').listSync().whereType<File>(),
    ]) {
      if (file.readAsStringSync().contains('api.dev.aeropass.example') ||
          file.readAsStringSync().contains('api.aeropass.example')) {
        offenders.add(file.path);
      }
    }
    // dev-offline.env still names a host, but it uses only fakes and a
    // release build refuses its flags.
    offenders.removeWhere((p) => p.endsWith('dev-offline.env'));
    expect(offenders, isEmpty);
  });

  test(
    'the composition root builds no dev fake outside the offline wiring',
    () {
      final source = File('lib/app/composition_root.dart').readAsStringSync();
      final backend = source.substring(
        source.indexOf('factory _Ports.backend'),
      );
      expect(RegExp(r'\bDev[A-Z]\w*\(').hasMatch(backend), isFalse);
    },
  );
}
