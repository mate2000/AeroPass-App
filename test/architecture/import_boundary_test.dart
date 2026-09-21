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
        RegExp(r'''['"]\.\./\.\./data/'''),
        RegExp(r'''['"]\.\./\.\./domain/repositories/'''),
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
}
