// 015 T050 (contracts/outcome-mapping.md "Verification", FR-005 to FR-009):
// rows are evaluated in order, the review state wins over the counter,
// LIVENESS is erased to generic, and no score survives.
import 'package:aeropass_app/data/models/backend/resultado_verificacion_dto.dart';
import 'package:aeropass_app/data/services/verification_result_mapper.dart';
import 'package:aeropass_app/domain/entities/verification_result.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/scripted_backend_adapter.dart';

VerificationResult _map(String fixture, [Map<String, dynamic>? override]) {
  final json = {...readFixture(fixture)! as Map<String, dynamic>, ...?override};
  return verificationResultFromDto(ResultadoVerificacionDto.fromJson(json));
}

void main() {
  test('row 1: REQUIERE_REVISION_MANUAL wins, even with attempts left', () {
    expect(
      _map('resultado_fallido_comparacion', {
        'estado_pasajero': 'REQUIERE_REVISION_MANUAL',
        'intentos_restantes': 2,
      }),
      isA<NeedsReview>(),
    );
  });

  test('row 2: EXITOSO is verified, with its identity', () {
    final result = _map('resultado_exitoso') as Verified;
    expect(result.identityId, isNotNull);
  });

  test('row 3: NO_CONCLUYENTE is inconclusive and carries its wait', () {
    final result = _map('resultado_no_concluyente') as Inconclusive;
    expect(result.retryAfter, const Duration(seconds: 30));
  });

  test('row 4: no attempts left is review', () {
    expect(_map('resultado_fallido_tercero'), isA<NeedsReview>());
    expect(
      _map('resultado_fallido_comparacion', {'intentos_restantes': 0}),
      isA<NeedsReview>(),
    );
  });

  test('row 5: COMPARACION is a match failure with the server budget', () {
    final result = _map('resultado_fallido_comparacion') as Failed;
    expect(result.reason, FailureReason.match);
    expect(result.remaining, 2);
  });

  test('row 6: LIVENESS is erased to generic (FR-006)', () {
    final result = _map('resultado_fallido_liveness') as Failed;
    expect(result.reason, FailureReason.generic);
    expect(result.remaining, 2);
  });

  test('row 7: FALLIDO with no reason is generic', () {
    final result =
        _map('resultado_fallido_liveness', {'motivo_fallo': null}) as Failed;
    expect(result.reason, FailureReason.generic);
  });

  test('rows 6 and 7 are indistinguishable', () {
    final liveness = _map('resultado_fallido_liveness') as Failed;
    final none =
        _map('resultado_fallido_liveness', {'motivo_fallo': null}) as Failed;
    expect(
      (liveness.reason, liveness.remaining),
      (none.reason, none.remaining),
    );
  });

  test('no domain result exposes a score', () {
    for (final fixture in [
      'resultado_exitoso',
      'resultado_fallido_liveness',
      'resultado_fallido_comparacion',
      'resultado_no_concluyente',
    ]) {
      final text = _map(fixture).toString();
      expect(text, isNot(matches(RegExp(r'0\.\d'))), reason: fixture);
      expect(text.toLowerCase(), isNot(contains('liveness')), reason: fixture);
    }
  });
}
