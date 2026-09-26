// Fault injection panel (015 observability, telemetry-events.md §6).
import 'package:aeropass_app/app/chaos_panel.dart';
import 'package:aeropass_app/core/fault_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the panel opens, sets a fault and clears it', (tester) async {
    final faults = FaultInjection();
    await tester.pumpWidget(
      MaterialApp(
        // Mounted as in the app: in the builder, above the navigator.
        builder: (context, child) => ChaosPanel(faults: faults, child: child!),
        home: const Scaffold(body: Text('pantalla')),
      ),
    );
    expect(find.text('pantalla'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bolt));
    await tester.pumpAndSettle();
    expect(find.text('Sin fallos'), findsOneWidget);

    await tester.tap(find.text('503 Blob'));
    await tester.pumpAndSettle();
    expect(faults.network, NetworkFault.http503Storage);
    expect(find.text('Activo: http503Storage'), findsOneWidget);

    // The panel scrolls when it is taller than 60 % of the screen.
    await tester.ensureVisible(find.text('Limpiar'));
    await tester.tap(find.text('Limpiar'));
    await tester.pumpAndSettle();
    expect(faults.active, isFalse);
  });
}
