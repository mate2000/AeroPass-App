// 007-validando T013: contracts/step-indicator-addendum.md.
import 'package:aeropass_app/core/design/app_colors.dart';
import 'package:aeropass_app/core/design/step_indicator.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<Color?>> _segmentColors(
  WidgetTester tester,
  StepIndicator indicator,
) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: indicator),
    ),
  );
  return tester
      .widgetList<Container>(find.byType(Container))
      .where((c) => c.constraints?.maxHeight == 3)
      .map((c) => c.color)
      .toList();
}

void main() {
  testWidgets('1. defaults render as before: earlier steps complete, the '
      'current step active, later steps upcoming', (tester) async {
    final colors = await _segmentColors(
      tester,
      const StepIndicator(currentStep: EnrollmentProgressStep.selfie),
    );

    expect(colors, [AppColors.teal, AppColors.teal, Colors.white54]);
  });

  testWidgets('2. currentStepReached: false renders the current step as '
      'upcoming', (tester) async {
    final colors = await _segmentColors(
      tester,
      const StepIndicator(
        currentStep: EnrollmentProgressStep.done,
        currentStepReached: false,
      ),
    );

    expect(colors, [AppColors.teal, AppColors.teal, Colors.white54]);
    expect(find.bySemanticsLabel(RegExp('pendiente')), findsOneWidget);
  });

  testWidgets('3. onLightSurface changes only the upcoming colour', (
    tester,
  ) async {
    final colors = await _segmentColors(
      tester,
      const StepIndicator(
        currentStep: EnrollmentProgressStep.done,
        currentStepReached: false,
        onLightSurface: true,
      ),
    );

    expect(colors[0], AppColors.teal);
    expect(colors[1], AppColors.teal);
    expect(colors[2], isNot(Colors.white54));
    expect(colors[2], isNot(AppColors.teal));
  });
}
