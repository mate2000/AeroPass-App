// 015 T053 (FR-020, SC-008): while the mock provider is declared, which is
// the default in every flavor today and in this test binary, every screen
// carries the ribbon, and no passenger string claims a verified or active
// identity.
import 'dart:convert';
import 'dart:io';

import 'package:aeropass_app/app/demo_ribbon.dart';
import 'package:aeropass_app/core/happy_path_flags.dart';
import 'package:aeropass_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the mock declaration is on in this build', () {
    expect(HappyPathFlags.biometricProviderMock, isTrue);
  });

  testWidgets('the ribbon is on top, readable, and announced', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        builder: (context, child) => DemoRibbon(child: child!),
        home: const Scaffold(body: SafeArea(child: Text('pantalla'))),
      ),
    );

    expect(find.byKey(const Key('demo-ribbon')), findsOneWidget);
    expect(find.text('DEMO · biometría simulada'), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(const Key('demo-ribbon'))).label,
      contains('La verificación biométrica es simulada'),
    );
    // The ribbon sits above the page, not over it.
    expect(
      tester.getBottomLeft(find.byKey(const Key('demo-ribbon'))).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.text('pantalla')).dy),
    );
    semantics.dispose();
  });

  test('the strings shown under the mock never claim a verified identity', () {
    final arb = jsonDecode(
      File('lib/l10n/app_es.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    // The screens that change under the mock show these keys instead
    // (credential_activated_view, credential_card, credential_strip,
    // verification_checklist).
    const shownUnderMock = [
      'credentialActivatedTitleMock',
      'credentialActivatedSubtitleMock',
      'credentialCardBadgeMock',
      'tripsBadgeMock',
      'verificationStageDocumentPassedMock',
      'verificationStageFacePassedMock',
    ];
    for (final key in shownUnderMock) {
      final value = (arb[key] as String).toLowerCase();
      expect(value, isNot(contains('verificad')), reason: key);
      expect(value, isNot(contains('identidad activa')), reason: key);
      expect(value, isNot(contains('activa')), reason: key);
    }
  });

  test('every view that shows the non-mock claims checks the flag', () {
    // The non-mock keys that claim verification: each file that uses one
    // must also read `biometricProviderMock`.
    const claims = [
      'credentialActivatedTitle',
      'credentialActivatedSubtitle',
      'credentialCardActiveBadge',
      'tripsBadgeActive',
      'verificationStageDocumentPassed',
      'verificationStageFacePassed',
    ];
    final offenders = <String>[];
    for (final f in Directory('lib/features').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final text = f.readAsStringSync();
      final uses = claims.any((k) => RegExp('l10n\\.$k\\b').hasMatch(text));
      if (uses && !text.contains('HappyPathFlags.biometricProviderMock')) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
