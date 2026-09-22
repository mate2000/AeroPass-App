import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/composition_root.dart';
import 'core/happy_path_flags.dart';

void main() {
  // Constitution v1.4.0: a release build produced with a happy-path
  // relaxation flag enabled refuses to run rather than silently shipping
  // it (005-instrucciones-selfie, research.md §4).
  HappyPathFlags.assertReleaseSafe();
  runApp(const CompositionRoot(child: AeroPassApp()));
}
