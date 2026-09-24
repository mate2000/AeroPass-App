// 015 T029 (research.md §9, FR-023): GET /v1/identity/me behind the
// passenger, credential-status and credential-summary ports.
import 'package:aeropass_app/data/services/credential_service.dart';
import 'package:aeropass_app/data/services/passenger_backed_credential_repository.dart';
import 'package:aeropass_app/data/services/passenger_service.dart';
import 'package:aeropass_app/domain/entities/credential_status.dart';
import 'package:aeropass_app/domain/entities/credential_summary.dart';
import 'package:aeropass_app/domain/entities/passenger_record.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:aeropass_app/domain/repositories/credential_summary_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_clock.dart';
import '../fakes/fake_secure_storage_platform.dart';
import '../fakes/scripted_backend_adapter.dart';

void main() {
  late ScriptedBackendAdapter backend;
  late PassengerBackedCredentialRepository repository;
  late FakeClock clock;

  setUp(() {
    FlutterSecureStoragePlatform.instance = FakeSecureStoragePlatform();
    backend = ScriptedBackendAdapter();
    clock = FakeClock();
    final dio = dioOver(backend);
    repository = PassengerBackedCredentialRepository(
      PassengerService(dio: dio),
      credentialService: CredentialService(
        secureStorage: const FlutterSecureStorage(),
      ),
      clock: clock,
    );
  });

  void offline() => backend.enqueueFailure(
    DioException.connectionError(
      requestOptions: RequestOptions(path: '/v1/identity/me'),
      reason: 'offline',
    ),
  );

  group('me()', () {
    test('404 is "not registered", not an error', () async {
      backend.enqueue(ScriptedResponse.error('pasajero_no_registrado'));
      final result = await repository.me();
      expect(result.isOk, isTrue);
      expect(result.valueOrNull, isNull);
      expect(backend.requests.single.path, '/v1/identity/me');
    });

    test('each backend state reaches the domain', () async {
      for (final (fixture, state) in [
        ('pasajero_pendiente', PassengerState.pendingVerification),
        ('pasajero_verificado', PassengerState.verified),
        ('pasajero_revision_manual', PassengerState.manualReview),
      ]) {
        backend.enqueue(ScriptedResponse.fixture(fixture));
        final passenger = (await repository.me()).valueOrNull!;
        expect(passenger.state, state, reason: fixture);
        expect(passenger.maskedNumber, '******4050');
      }
    });

    test('a transport failure is an error, never "not registered"', () async {
      offline();
      final result = await repository.me();
      expect(result.isError, isTrue);
      expect(
        result.when(ok: (_) => null, error: (e, _) => e),
        isA<ConnectivityFailure>(),
      );
    });
  });

  group('getStatus()', () {
    Future<CredentialStatus> status() async =>
        (await repository.getStatus()).valueOrNull!;

    test('verified with an identity is valid through the expiry day', () async {
      backend.enqueue(ScriptedResponse.fixture('pasajero_verificado'));
      expect(
        await status(),
        CredentialStatus.valid(validUntil: DateTime(2030, 2, 1)),
      );
    });

    test('pending, in review and unregistered have no credential', () async {
      for (final fixture in [
        'pasajero_pendiente',
        'pasajero_revision_manual',
      ]) {
        backend.enqueue(ScriptedResponse.fixture(fixture));
        expect(await status(), const CredentialStatus.noCredential());
      }
      backend.enqueue(ScriptedResponse.error('pasajero_no_registrado'));
      expect(await status(), const CredentialStatus.noCredential());
    });

    test('verified with a null identity is never shown active', () async {
      final json = readFixture('pasajero_verificado')! as Map<String, dynamic>;
      backend.enqueue(ScriptedResponse(200, {...json, 'identidad_id': null}));
      expect(await status(), const CredentialStatus.noCredential());
    });

    test(
      'offline, the last verified answer is the last known status',
      () async {
        backend.enqueue(ScriptedResponse.fixture('pasajero_verificado'));
        await status();
        offline();
        final unreachable = await status() as Unreachable;
        // The cache stores UTC. It is the same instant.
        final lastKnown = unreachable.lastKnownStatus! as Valid;
        expect(
          lastKnown.validUntil.isAtSameMomentAs(DateTime(2030, 2, 1)),
          isTrue,
        );
      },
    );

    test('offline with nothing cached has no last known status', () async {
      offline();
      expect(
        await status(),
        const CredentialStatus.unreachable(lastKnownStatus: null),
      );
    });

    test('an expired document is expired, not valid', () async {
      clock.advance(const Duration(days: 365 * 5));
      backend.enqueue(ScriptedResponse.fixture('pasajero_verificado'));
      expect(
        await status(),
        const CredentialStatus.expiredOrRevoked(reason: ExpiryReason.expired),
      );
    });
  });

  group('getSummary()', () {
    test('verified: the backend name and last four, confirmed', () async {
      backend.enqueue(ScriptedResponse.fixture('pasajero_verificado'));
      final summary = (await repository.getSummary()).valueOrNull!;
      expect(summary.holderName, 'Ana Prueba');
      expect(summary.documentLast4, '4050');
      expect(summary.state, CredentialDisplayState.active);
      expect(summary.showsActive, isTrue);
    });

    test(
      'offline after a verified answer: unconfirmed, so never ACTIVA',
      () async {
        backend.enqueue(ScriptedResponse.fixture('pasajero_verificado'));
        await repository.getSummary();
        offline();
        final summary = (await repository.getSummary()).valueOrNull!;
        expect(summary.confirmed, isFalse);
        expect(summary.showsActive, isFalse);
        expect(summary.holderName, 'Ana Prueba');
      },
    );

    test('not verified is NoCredentialFailure', () async {
      backend.enqueue(ScriptedResponse.fixture('pasajero_pendiente'));
      expect(
        (await repository.getSummary()).when(
          ok: (_) => null,
          error: (e, _) => e,
        ),
        isA<NoCredentialFailure>(),
      );
    });
  });
}
