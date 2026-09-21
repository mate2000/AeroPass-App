import 'dart:math';

/// A minimal, dependency-free UUID v4 generator. Used for identifiers that
/// exist only to satisfy an in-process invariant (an `EnrollmentSession`'s
/// id, the per-launch `AnalyticsSessionId`) and are never sent to the
/// backend as a stable identifier — so a full `uuid` package dependency
/// isn't justified here (Constitution: "KISS... an abstraction requires
/// two real call sites before it is introduced").
String generateUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 10xx

  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();

  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
