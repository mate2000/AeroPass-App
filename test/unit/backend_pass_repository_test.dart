// 015 T064 (FR-010 to FR-015b, research.md §10): the pass against the real
// backend. It is issued by flight code, renewed at renovar_en_segundos,
// polled for the current credential only, CONSUMIDA is boarded, refusals are
// told apart, and the code stays until expira_at when a renewal fails.
import 'package:aeropass_app/app/clock_trust_monitor.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/services/backend_pass_repository.dart';
import 'package:aeropass_app/data/services/issued_token_pass_code_source.dart';
import 'package:aeropass_app/data/services/pass_service.dart';
import 'package:aeropass_app/domain/entities/pass.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_clock.dart';
import '../fakes/scripted_backend_adapter.dart';

/// `pase.json`: emitida 17:04:00Z, expira 17:04:45Z, renovar 40 s.
final _issuedAt = DateTime.utc(2026, 9, 23, 17, 4);

Map<String, dynamic> _pase({
  required String id,
  required DateTime issuedAt,
  String token = 'eyJ.token.sig',
}) => {
  ...readFixture('pase')! as Map<String, dynamic>,
  'credencial_id': id,
  'token': token,
  'emitida_at': issuedAt.toIso8601String(),
  'expira_at': issuedAt.add(const Duration(seconds: 45)).toIso8601String(),
};

Map<String, dynamic> _detalle(String id, String estado) => {
  ...readFixture('detalle_pase_activa')! as Map<String, dynamic>,
  'credencial_id': id,
  'estado': estado,
};

void main() {
  late ScriptedBackendAdapter backend;
  late FakeClock clock;
  late ClockTrustMonitor clockTrust;
  late BackendPassRepository repository;

  setUp(() {
    backend = ScriptedBackendAdapter();
    clock = FakeClock(_issuedAt);
    clockTrust = ClockTrustMonitor(clock: clock);
    repository = BackendPassRepository(
      PassService(dio: dioOver(backend)),
      clockTrustMonitor: clockTrust,
    );
  });

  Future<Pass> issue({String id = 'c-1', DateTime? at}) async {
    backend.enqueue(
      ScriptedResponse(201, _pase(id: id, issuedAt: at ?? _issuedAt)),
    );
    return (await repository.issue('AV9201')).valueOrNull!;
  }

  group('issue', () {
    test('maps the pass: id, flight, expiry, renewal, boarding only', () async {
      final pass = await issue();
      expect(pass.passId, 'c-1');
      expect(pass.tripId, 'AV9201');
      expect(pass.validUntil, _issuedAt.add(const Duration(seconds: 45)));
      expect(pass.rotation, const Duration(seconds: 40));
      expect(pass.checkpoints, {Checkpoint.boarding});
      expect(pass.nextCheckpoint, Checkpoint.boarding);
      expect(repository.current!.token, 'eyJ.token.sig');
    });

    test('the server clock comes from emitida_at', () async {
      clock.set(_issuedAt.subtract(const Duration(seconds: 3)));
      await issue();
      expect(clockTrust.isTrusted, isTrue);
      expect(
        clockTrust.serverNow().difference(_issuedAt).inSeconds.abs(),
        lessThanOrEqualTo(1),
      );
    });

    test('each renewal replaces the current pass', () async {
      await issue(id: 'c-1');
      final renewed = await issue(
        id: 'c-2',
        at: _issuedAt.add(const Duration(seconds: 40)),
      );
      expect(repository.activePassFor('AV9201'), renewed);
      expect(repository.current!.pass.passId, 'c-2');
    });

    test('refusals are told apart (FR-015)', () async {
      for (final (fixture, refusal) in [
        ('documento_vencido_pase', PassIssueRefusal.documentExpired),
        ('identidad_no_activa', PassIssueRefusal.identityNotActive),
        ('datos_invalidos', PassIssueRefusal.invalidFlightCode),
        ('limite_emision_excedido', PassIssueRefusal.busy),
        ('almacenamiento_no_disponible', PassIssueRefusal.busy),
      ]) {
        backend.enqueue(ScriptedResponse.error(fixture));
        final error = (await repository.issue('AV9201'))
            .when(ok: (_) => null, error: (e, _) => e);
        expect((error! as PassIssueRefused).refusal, refusal, reason: fixture);
      }
    });

    test('429 carries its Retry-After (FR-014)', () async {
      backend.enqueue(ScriptedResponse.error('limite_emision_excedido'));
      final error =
          (await repository.issue('AV9201'))
                  .when(ok: (_) => null, error: (e, _) => e)!
              as PassIssueRefused;
      expect(error.retryAfter, const Duration(seconds: 12));
    });
  });

  group('status', () {
    test('polls the current credential, whatever id it is given', () async {
      await issue(id: 'c-1');
      await issue(id: 'c-2', at: _issuedAt.add(const Duration(seconds: 40)));
      backend.enqueue(ScriptedResponse(200, _detalle('c-2', 'ACTIVA')));
      final state = (await repository.status('c-1')).valueOrNull;
      expect(state, isA<PassActive>());
      expect(backend.requests.last.path, '/v1/passes/c-2');
    });

    test('CONSUMIDA is boarded, a success (FR-015b)', () async {
      await issue();
      backend.enqueue(ScriptedResponse(200, _detalle('c-1', 'CONSUMIDA')));
      expect(
        (await repository.status('c-1')).valueOrNull,
        const PassState.boarded(),
      );
    });

    test('EXPIRADA, REVOCADA and 404 are not usable', () async {
      await issue();
      backend
        ..enqueue(ScriptedResponse(200, _detalle('c-1', 'EXPIRADA')))
        ..enqueue(ScriptedResponse(200, _detalle('c-1', 'REVOCADA')))
        ..enqueue(ScriptedResponse.error('credencial_no_encontrada'));
      expect(
        (await repository.status('c-1')).valueOrNull,
        const PassState.expired(),
      );
      expect(
        (await repository.status('c-1')).valueOrNull,
        const PassState.revoked(),
      );
      expect(
        (await repository.status('c-1')).valueOrNull,
        const PassState.expired(),
      );
    });

    test('a failed read is an error, never a state', () async {
      await issue();
      backend.enqueueFailure(
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/v1/passes/c-1'),
          reason: 'offline',
        ),
      );
      expect((await repository.status('c-1')).isError, isTrue);
    });
  });

  group('the token code source (FR-012, SC-006)', () {
    late IssuedTokenPassCodeSource source;

    setUp(() => source = IssuedTokenPassCodeSource(repository));

    test(
      'before the renewal time: the token, until the renewal time',
      () async {
        final pass = await issue();
        final code = (await source.codeAt(
          pass,
          _issuedAt.add(const Duration(seconds: 10)),
        )).valueOrNull!;
        expect(code.payload, 'eyJ.token.sig');
        expect(code.windowEndsAt, _issuedAt.add(const Duration(seconds: 40)));
        expect(code.renewalPending, isFalse);
        expect(backend.requests, hasLength(1));
      },
    );

    test('at the renewal time: a new pass, and its token', () async {
      final pass = await issue();
      backend.enqueue(
        ScriptedResponse(
          201,
          _pase(
            id: 'c-2',
            issuedAt: _issuedAt.add(const Duration(seconds: 40)),
            token: 'eyJ.renewed.sig',
          ),
        ),
      );
      final code = (await source.codeAt(
        pass,
        _issuedAt.add(const Duration(seconds: 40)),
      )).valueOrNull!;
      expect(code.payload, 'eyJ.renewed.sig');
      expect(repository.current!.pass.passId, 'c-2');
    });

    test(
      'a failed renewal keeps the valid token, pending, and retries',
      () async {
        final pass = await issue();
        backend.enqueueFailure(
          DioException.connectionError(
            requestOptions: RequestOptions(path: '/v1/passes'),
            reason: 'offline',
          ),
        );
        final at = _issuedAt.add(const Duration(seconds: 40));
        final code = (await source.codeAt(pass, at)).valueOrNull!;
        expect(code.payload, 'eyJ.token.sig');
        expect(code.renewalPending, isTrue);
        expect(code.windowEndsAt, at.add(IssuedTokenPassCodeSource.retryPause));

        // Within the pause nothing is sent.
        await source.codeAt(pass, at.add(const Duration(seconds: 1)));
        expect(backend.requests, hasLength(2));
      },
    );

    test('the pending window never passes expira_at', () async {
      final pass = await issue();
      backend.enqueue(ScriptedResponse.error('limite_emision_excedido'));
      final at = _issuedAt.add(const Duration(seconds: 40));
      final code = (await source.codeAt(pass, at)).valueOrNull!;
      // Retry-After is 12 s, but the pass expires 5 s after the renewal time.
      expect(code.windowEndsAt, pass.validUntil);
    });

    test('past expira_at with no renewal there is no code', () async {
      final pass = await issue();
      backend.enqueueFailure(
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/v1/passes'),
          reason: 'offline',
        ),
      );
      final result = await source.codeAt(
        pass,
        _issuedAt.add(const Duration(seconds: 45)),
      );
      expect(result.isError, isTrue);
      expect(
        result.when(ok: (_) => null, error: (e, _) => e),
        isA<ConnectivityFailure>(),
      );
    });
  });

  test('nothing is persisted: forget drops the only copy', () async {
    final pass = await issue();
    await repository.forget(pass.passId);
    expect(repository.current, isNull);
    expect(repository.activePassFor('AV9201'), isNull);
  });

  test('a token never appears in toString', () async {
    await issue();
    expect(repository.current.toString(), isNot(contains('eyJ')));
    expect(
      Result<Object>.ok(repository.current!).toString(),
      isNot(contains('eyJ')),
    );
  });
}
