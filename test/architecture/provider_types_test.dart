// provider's debug check throws when a plain `Provider` exposes a Listenable
// or a Stream. It runs only in debug builds, so a release build hides it
// and the first debug run with that port wired crashes (ClerkAuthState and
// VerificationSubmission, 2026-09-24). This scans the composition root the
// way the check would.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _listenableRoots = {
  'ChangeNotifier',
  'Listenable',
  'ValueNotifier',
  'ValueListenable',
  'Stream',
  // From packages, so their declarations are not under lib/.
  'ClerkAuthState',
};

void main() {
  test('no plain Provider exposes a Listenable or Stream', () {
    final declaration = RegExp(r'class\s+(\w+)(?:<[^>]*>)?\s+([^{]*)\{');
    final parents = <String, Set<String>>{};
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      for (final match in declaration.allMatches(file.readAsStringSync())) {
        parents[match.group(1)!] = RegExp(r'\w+')
            .allMatches(match.group(2)!)
            .map((m) => m.group(0)!)
            .toSet();
      }
    }

    // Classes that are Listenable directly or through what they extend,
    // mix in or implement.
    final listenable = <String>{};
    var changed = true;
    while (changed) {
      changed = false;
      for (final MapEntry(key: name, value: supers) in parents.entries) {
        if (listenable.contains(name)) continue;
        if (supers.any(
          (s) => _listenableRoots.contains(s) || listenable.contains(s),
        )) {
          listenable.add(name);
          changed = true;
        }
      }
    }

    final root = File('lib/app/composition_root.dart').readAsStringSync();
    final offenders = RegExp(r'(?<![A-Za-z])Provider<(\w+)\??>\.value')
        .allMatches(root)
        .map((m) => m.group(1)!)
        .where((t) => listenable.contains(t) || _listenableRoots.contains(t))
        .toSet();
    expect(
      offenders,
      isEmpty,
      reason:
          'Use ListenableProvider (or ChangeNotifierProvider) for: '
          '${offenders.join(', ')}',
    );
  });
}
