// 010-escalar-agente T007/T021/T025: Contract — EscalationRepository
// (contracts/escalation-port.md). The real implementation runs every case;
// the dev fake, which opens once and stays open, runs cases 1–3.

import 'package:aeropass_app/data/dev/dev_escalation_repository.dart';
import 'package:aeropass_app/domain/entities/escalation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dev fake', () {
    test(
      '1–3. opens once, then reports an open case with both channels',
      () async {
        final dev = DevEscalationRepository(
          now: () => DateTime.utc(2026, 9, 23, 12),
        );

        final first = (await dev.openOrResume(
          arrival: EscalationArrival.afterLimit,
        )).valueOrNull;
        final second = (await dev.openOrResume(
          arrival: EscalationArrival.byChoice,
        )).valueOrNull;
        final status = (await dev.getStatus()).valueOrNull;

        expect(second, first);
        expect(status, isA<EscalationOpen>());
        final kinds = (status! as EscalationOpen).channels.map((c) => c.kind);
        expect(kinds, containsAll(AgentChannelKind.values));
        final module = (status as EscalationOpen).channels.firstWhere(
          (c) => c.kind == AgentChannelKind.module,
        );
        expect(module.locationName, isNotEmpty);
        expect(module.locationDetail, isNotEmpty);
      },
    );
  });
}
