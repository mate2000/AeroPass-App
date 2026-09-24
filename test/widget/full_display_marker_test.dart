// 015-observabilidad-sentry T040: a critical screen reports "fully
// displayed" once, after the first frame in which its content is ready
// (research §8).
import 'package:aeropass_app/app/full_display_marker.dart';
import 'package:aeropass_app/data/services/full_display_reporter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _CountingReporter implements FullDisplayReporter {
  int reports = 0;

  @override
  void reportFullyDisplayed() => reports++;
}

Widget _marker(FullDisplayReporter reporter, {required bool ready}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: FullDisplayMarker(
        reporter: reporter,
        ready: ready,
        child: const Text('screen'),
      ),
    );

void main() {
  testWidgets('a ready screen reports once, after its first frame', (
    tester,
  ) async {
    final reporter = _CountingReporter();

    await tester.pumpWidget(_marker(reporter, ready: true));
    expect(find.text('screen'), findsOneWidget);
    await tester.pump();
    await tester.pumpWidget(_marker(reporter, ready: true));
    await tester.pump();

    expect(reporter.reports, 1);
  });

  testWidgets('a screen reports only when its content becomes ready', (
    tester,
  ) async {
    final reporter = _CountingReporter();

    await tester.pumpWidget(_marker(reporter, ready: false));
    await tester.pump();
    expect(reporter.reports, 0);

    await tester.pumpWidget(_marker(reporter, ready: true));
    await tester.pump();
    expect(reporter.reports, 1);

    await tester.pumpWidget(_marker(reporter, ready: false));
    await tester.pumpWidget(_marker(reporter, ready: true));
    await tester.pump();
    expect(reporter.reports, 1);
  });

  test('the no-op reporter does nothing and does not fail', () {
    expect(
      const NoopFullDisplayReporter().reportFullyDisplayed,
      returnsNormally,
    );
  });

  test('the Sentry reporter does not fail when Sentry is not running', () {
    expect(
      const SentryFullDisplayReporter().reportFullyDisplayed,
      returnsNormally,
    );
  });
}
