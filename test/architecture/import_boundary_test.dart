// Enforces Constitution Principle VIII's dependency direction (View ->
// ViewModel -> Repository -> Service) at the import-boundary level: a
// `*_view.dart` file under lib/features/ may not import lib/data/ or
// lib/domain/repositories/ directly. It must reach a repository only
// through its ViewModel.
//
// This is a stand-in for the "import-boundary rule" the Constitution's
// Development Workflow section calls for, implemented as an executable
// test (see analysis_options.yaml for why this isn't a custom analyzer
// lint) rather than an analyzer plugin.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'view files do not import lib/data/ or lib/domain/repositories/ directly',
    () {
      final featuresDir = Directory('lib/features');
      if (!featuresDir.existsSync()) {
        return;
      }

      final forbiddenImportPatterns = <RegExp>[
        RegExp(r'''package:aeropass_app/data/'''),
        RegExp(r'''package:aeropass_app/domain/repositories/'''),
        // Any relative depth: views under lib/features/<area>/<screen>/
        // import with three `../` segments.
        RegExp(r'''['"](\.\./)+data/'''),
        RegExp(r'''['"](\.\./)+domain/repositories/'''),
      ];

      final violations = <String>[];

      for (final entity in featuresDir.listSync(recursive: true)) {
        if (entity is! File) continue;
        if (!entity.path.endsWith('_view.dart')) continue;

        final content = entity.readAsStringSync();
        final importLines = content
            .split('\n')
            .where((line) => line.trim().startsWith('import '));

        for (final line in importLines) {
          for (final pattern in forbiddenImportPatterns) {
            if (pattern.hasMatch(line)) {
              violations.add('${entity.path}: ${line.trim()}');
            }
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason:
            'View files must not import lib/data/ or '
            'lib/domain/repositories/ directly; go through a ViewModel '
            'instead:\n${violations.join('\n')}',
      );
    },
  );

  // 014-qr-pase T038: the pass screen never reaches the data layer or
  // storage, and no log call in the pass code can carry a payload, a secret
  // or a pass id (FR-015).
  test('the pass feature imports no data layer and logs no pass data', () {
    final featureDir = Directory('lib/features/pass');
    expect(featureDir.existsSync(), isTrue);
    final forbiddenImports = <RegExp>[
      RegExp(r'''package:aeropass_app/data/'''),
      RegExp(r'''['"](\.\./)+data/'''),
      RegExp(r'''package:flutter_secure_storage'''),
      RegExp(r'''package:shared_preferences'''),
      RegExp(r'''^import 'dart:io';'''),
    ];
    final violations = <String>[];
    for (final entity in featureDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      for (final line in entity.readAsStringSync().split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('import ') &&
            forbiddenImports.any((p) => p.hasMatch(trimmed))) {
          violations.add('${entity.path}: $trimmed');
        }
      }
    }

    // Any log or print in pass code must not interpolate pass data.
    final passFiles = [
      ...featureDir.listSync(recursive: true),
      File('lib/data/services/pass_repository_impl.dart'),
      File('lib/data/services/backend_pass_code_source.dart'),
      File('lib/data/services/pass_service.dart'),
      File('lib/data/services/platform_pass_display.dart'),
      File('lib/data/dev/dev_pass_repository.dart'),
    ];
    final leakyLog = RegExp(
      // `e.code` is a platform error code, not a pass code.
      r'''(developer\.log|print|debugPrint)\(.*(payload|secret|passId|(?<!e\.)code\b)''',
    );
    for (final entity in passFiles) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      for (final line in entity.readAsStringSync().split('\n')) {
        if (leakyLog.hasMatch(line)) {
          violations.add('${entity.path}: ${line.trim()}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  // 012-mis-viajes T040: Mis viajes and Perfil never touch the data layer,
  // files or preferences, so no itinerary can be written to the device
  // (FR-013, CONFLICT-005).
  test('Mis viajes and Perfil import no data layer and no storage', () {
    final forbidden = <RegExp>[
      RegExp(r'''package:aeropass_app/data/'''),
      RegExp(r'''['"](\.\./)+data/'''),
      RegExp(r'''package:flutter_secure_storage'''),
      RegExp(r'''package:shared_preferences'''),
      RegExp(r'''package:path_provider'''),
      RegExp(r'''^import 'dart:io';'''),
    ];
    final violations = <String>[];
    for (final path in ['lib/features/trips', 'lib/features/profile']) {
      final dir = Directory(path);
      expect(dir.existsSync(), isTrue, reason: path);
      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final imports = entity
            .readAsStringSync()
            .split('\n')
            .where((line) => line.trim().startsWith('import '));
        for (final line in imports) {
          if (forbidden.any((p) => p.hasMatch(line.trim()))) {
            violations.add('${entity.path}: ${line.trim()}');
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  // 011-error-tecnico T045: screen 11 never reaches a capture or an attempt
  // counter (FR-002, FR-005), and none of its files touch the data layer.
  test('screen 11 imports no data layer, camera or attempt counter', () {
    final dir = Directory('lib/features/enrollment/technical_error');
    expect(dir.existsSync(), isTrue);

    final forbidden = <RegExp>[
      RegExp(r'''package:aeropass_app/data/'''),
      RegExp(r'''['"](\.\./)+data/'''),
      RegExp(r'''package:camera'''),
      RegExp(r'''capture_attempt_counter'''),
      RegExp(r'''liveness_camera'''),
      RegExp(r'''camera_capture'''),
    ];
    final violations = <String>[];
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final imports = entity
          .readAsStringSync()
          .split('\n')
          .where((line) => line.trim().startsWith('import '));
      for (final line in imports) {
        if (forbidden.any((p) => p.hasMatch(line))) {
          violations.add('${entity.path}: ${line.trim()}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
