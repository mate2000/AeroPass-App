// 015 T049 (FR-006, FR-007, SC-002, contracts/outcome-mapping.md): no
// backend identifier, score or `mensaje` can reach a passenger.
//
// Every passenger-visible string lives in lib/l10n/app_es.arb, so no string
// there may carry a backend code, enum value or score. And no code in lib/
// reads `mensaje`, the one backend field that is free text. LIVENESS and a
// missing reason must be indistinguishable all the way to screen 009.
import 'dart:convert';
import 'dart:io';

import 'package:aeropass_app/app/submission_backed_job_repository.dart';
import 'package:aeropass_app/app/verification_submission.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/models/backend/resultado_verificacion_dto.dart';
import 'package:aeropass_app/data/services/verification_result_mapper.dart';
import 'package:aeropass_app/domain/entities/backend_error.dart';
import 'package:aeropass_app/domain/entities/verification_job_status.dart';
import 'package:aeropass_app/domain/entities/verification_result.dart';
import 'package:aeropass_app/domain/repositories/biometric_verification_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/scripted_backend_adapter.dart';

/// Every wire value the backend defines (`domain/enums.py`, `errors.py`).
const _backendIdentifiers = [
  'EXITOSO', 'FALLIDO', 'NO_CONCLUYENTE', //
  'LIVENESS', 'COMPARACION',
  'PENDIENTE_VERIFICACION', 'VERIFICADO', 'REQUIERE_REVISION_MANUAL',
  'EMITIDA', 'CONSUMIDA', 'EXPIRADA', 'REVOCADA',
  'PASAPORTE',
];

class _Answer implements BiometricVerificationRepository {
  _Answer(this.result);
  final VerificationResult result;
  @override
  Future<Result<VerificationResult>> verify(Uint8List selfieJpeg) async =>
      Result.ok(result);
}

void main() {
  final arb = jsonDecode(
    File('lib/l10n/app_es.arb').readAsStringSync(),
  ) as Map<String, dynamic>;
  final strings = {
    for (final MapEntry(:key, :value) in arb.entries)
      if (!key.startsWith('@') && value is String) key: value,
  };

  test('no passenger string carries a backend code or enum value', () {
    final identifiers = [
      ..._backendIdentifiers,
      for (final code in BackendErrorCode.values)
        if (code.wire.isNotEmpty) code.wire,
    ];
    // The app's own Spanish word, chosen by 012, that happens to match a
    // backend enum value. It is not an echo of the backend.
    const ownWords = {'tripsBadgeRevoked': 'REVOCADA'};
    for (final MapEntry(:key, :value) in strings.entries) {
      for (final id in identifiers) {
        if (ownWords[key] == id) continue;
        // Whole-word, case-sensitive: "Verificado" is not "VERIFICADO".
        expect(
          RegExp('\\b$id\\b').hasMatch(value),
          isFalse,
          reason: '$key contains $id',
        );
      }
    }
  });

  test('no passenger string carries a score-like number', () {
    for (final MapEntry(:key, :value) in strings.entries) {
      expect(RegExp(r'\b0[.,]\d{2}\b').hasMatch(value), isFalse, reason: key);
    }
  });

  test("no code in lib/ reads the backend's `mensaje`", () {
    final offenders = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final lines = file.readAsLinesSync();
      for (final (i, line) in lines.indexed) {
        final code = line.split('//').first;
        if (code.contains("'mensaje'") || code.contains('"mensaje"')) {
          offenders.add('${file.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  test('LIVENESS and a missing reason reach 007 as the same outcome', () async {
    Future<Object?> outcomeFor(Map<String, dynamic> override) async {
      final json = {
        ...readFixture('resultado_fallido_liveness')! as Map<String, dynamic>,
        ...override,
      };
      final result = verificationResultFromDto(
        ResultadoVerificacionDto.fromJson(json),
      );
      final submission = VerificationSubmission(repository: _Answer(result))
        ..submit(Uint8List(1));
      await Future<void>.delayed(Duration.zero);
      final status =
          (await SubmissionBackedJobRepository(
                submission,
              ).getStatus()).valueOrNull!
              as VerificationJobCompleted;
      return status.outcome;
    }

    expect(await outcomeFor({}), await outcomeFor({'motivo_fallo': null}));
  });
}
