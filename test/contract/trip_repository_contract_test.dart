// 012-mis-viajes T009/T027/T033: Contract — TripRepository
// (contracts/trip-port.md). Domestic only, 90 days of history, nothing
// guessed, and the last good snapshot kept in memory.
import 'package:aeropass_app/core/clock.dart';
import 'package:aeropass_app/core/result.dart';
import 'package:aeropass_app/data/dev/dev_trip_repository.dart';
import 'package:aeropass_app/data/services/trip_repository_impl.dart';
import 'package:aeropass_app/data/services/trip_service.dart';
import 'package:aeropass_app/domain/entities/consent_record.dart';
import 'package:aeropass_app/domain/entities/enrollment_attempt_id.dart';
import 'package:aeropass_app/domain/entities/processing_scope.dart';
import 'package:aeropass_app/domain/entities/transport_failure.dart';
import 'package:aeropass_app/domain/entities/trip.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_consent_repository.dart';
import '../fakes/fake_http_client_adapter.dart';

/// 2026-09-23 12:00 UTC (07:00 in Bogotá).
final _now = DateTime.utc(2026, 9, 23, 12);

class _Clock implements Clock {
  @override
  DateTime now() => _now;
}

class _Harness {
  _Harness({bool withConsent = true}) {
    dio.httpClientAdapter = adapter;
    consent.seedLocalRecord(
      withConsent
          ? ConsentRecord(
              textVersionId: 'v1',
              enrollmentAttemptId: const EnrollmentAttemptId('attempt-1'),
              scope: ProcessingScope.identityVerification,
              confirmedAt: DateTime.utc(2026, 9, 1),
              status: ConsentRecordStatus.active,
            )
          : null,
    );
  }

  final adapter = FakeHttpClientAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'https://api.test.aeropass.example'));
  final consent = FakeConsentRepository();

  late final repository = TripRepositoryImpl(
    TripService(dio: dio),
    consentRepository: consent,
    clock: _Clock(),
  );
}

Map<String, dynamic> _segment({
  String id = 'seg',
  String from = 'BOG',
  String fromCity = 'Bogotá',
  String to = 'MDE',
  String toCity = 'Medellín',
  String? flight = 'AV 9201',
  String? departure = '2026-09-23T14:35:00-05:00',
  String? status = 'on_time',
  bool? live = true,
  String? gate = 'D12',
  String? seat = '22A',
  bool? domestic = true,
  Map<String, dynamic>? connectsTo,
}) => {
  'id': id,
  'origin': {'code': from, 'city': fromCity},
  'destination': {'code': to, 'city': toCity},
  'flightNumber': ?flight,
  'departureLocal': ?departure,
  'status': ?status,
  'live': ?live,
  'gate': ?gate,
  'seat': ?seat,
  'domestic': ?domestic,
  'connectsTo': ?connectsTo,
};

Future<TripsSnapshot> _read(List<Map<String, dynamic>> segments) async {
  final h = _Harness()..adapter.respondWith({'segments': segments});
  return (await h.repository.getTrips()).valueOrNull!;
}

void main() {
  group('Real implementation', () {
    test(
      '1. a valid body maps every field, keeping the airport offset',
      () async {
        final snapshot = await _read([
          _segment(connectsTo: {'code': 'CLO', 'city': 'Cali'}),
        ]);

        final trip = snapshot.next!;
        expect(trip.origin, const Airport(code: 'BOG', city: 'Bogotá'));
        expect(trip.destination, const Airport(code: 'MDE', city: 'Medellín'));
        expect(trip.flightNumber, 'AV 9201');
        expect(trip.departureUtc, DateTime.utc(2026, 9, 23, 19, 35));
        expect(trip.departureOffset, const Duration(hours: -5));
        expect(trip.departureLocal.hour, 14);
        expect(trip.departureLocal.minute, 35);
        expect(trip.status, TripStatus.onTime);
        expect(trip.live, isTrue);
        expect(trip.gate, 'D12');
        expect(trip.seat, '22A');
        expect(trip.connectsTo?.city, 'Cali');
        expect(snapshot.fetchedAt, _now);
      },
    );

    test(
      '2. an international segment is dropped, next and in history',
      () async {
        final snapshot = await _read([
          _segment(id: 'gru', to: 'GRU', toCity: 'São Paulo', domestic: false),
          _segment(
            id: 'old-int',
            departure: '2026-09-01T10:00:00-05:00',
            status: 'departed',
            domestic: null,
          ),
        ]);

        expect(snapshot.next, isNull);
        expect(snapshot.history, isEmpty);
      },
    );

    for (final (name, segment) in [
      ('no flight number', _segment(id: 'x', flight: null)),
      ('a blank flight number', _segment(id: 'x', flight: '  ')),
      ('no departure', _segment(id: 'x', departure: null)),
      (
        'a departure without an offset',
        _segment(id: 'x', departure: '2026-09-23T14:35:00'),
      ),
      ('a bad airport code', _segment(id: 'x', from: 'BOGOTA')),
      ('a missing city', _segment(id: 'x', toCity: '')),
    ]) {
      test(
        '3. a segment with $name is dropped; the others still map',
        () async {
          final snapshot = await _read([
            segment,
            _segment(id: 'good', departure: '2026-09-24T09:00:00-05:00'),
          ]);

          expect(snapshot.next?.id, 'good');
        },
      );
    }

    test(
      '4. an unknown status is unknown, and a missing live is false',
      () async {
        final snapshot = await _read([
          _segment(status: 'boarding_soon', live: null),
        ]);

        expect(snapshot.next!.status, TripStatus.unknown);
        expect(snapshot.next!.live, isFalse);
      },
    );

    test('5. the earliest undeparted segment is next; departed ones are '
        'history, newest first', () async {
      final snapshot = await _read([
        _segment(id: 'later', departure: '2026-09-25T08:00:00-05:00'),
        _segment(id: 'soon', departure: '2026-09-23T14:35:00-05:00'),
        _segment(
          id: 'past-1',
          departure: '2026-09-10T08:00:00-05:00',
          status: 'departed',
        ),
        _segment(
          id: 'past-2',
          departure: '2026-09-20T08:00:00-05:00',
          status: 'departed',
        ),
        _segment(
          id: 'departed-early',
          departure: '2026-09-23T13:00:00-05:00',
          status: 'departed',
        ),
      ]);

      expect(snapshot.next?.id, 'soon');
      // The airline's `departed` wins over a scheduled time still ahead.
      expect(snapshot.history.map((t) => t.id), [
        'departed-early',
        'past-2',
        'past-1',
      ]);
    });

    test('6. history keeps 89 days and drops 91', () async {
      final snapshot = await _read([
        _segment(
          id: 'd89',
          departure: '2026-06-26T12:00:00Z',
          status: 'departed',
        ),
        _segment(
          id: 'd91',
          departure: '2026-06-24T12:00:00Z',
          status: 'departed',
        ),
      ]);

      expect(snapshot.history.map((t) => t.id), ['d89']);
    });

    test(
      '7. a transport failure is wrapped and leaves lastKnown unchanged',
      () async {
        final h = _Harness()
          ..adapter.respondWith({
            'segments': [_segment()],
          });
        final first = (await h.repository.getTrips()).valueOrNull;
        expect(h.repository.lastKnown, first);

        h.adapter.failWith(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );
        final second = await h.repository.getTrips();

        expect(
          second,
          isA<Error<TripsSnapshot>>().having(
            (e) => e.error,
            'error',
            isA<ConnectivityFailure>(),
          ),
        );
        expect(h.repository.lastKnown, first);
      },
    );

    test('7. no consent record: an error, and no request is sent', () async {
      final h = _Harness(withConsent: false)
        ..adapter.respondWith({
          'segments': [_segment()],
        });

      expect((await h.repository.getTrips()).isError, isTrue);
      expect(h.adapter.requestCount, 0);
      expect(h.repository.lastKnown, isNull);
    });

    test(
      '8. the request carries the attempt id as a query and no body',
      () async {
        final h = _Harness()..adapter.respondWith({'segments': []});

        final _ = await h.repository.getTrips();

        final request = h.adapter.lastRequest!;
        expect(request.method, 'GET');
        expect(request.path, '/v1/trips');
        expect(request.queryParameters, {'enrollmentAttemptId': 'attempt-1'});
        expect(request.data, isNull);
      },
    );

    test('an empty body is an empty snapshot, not an error', () async {
      final snapshot = await _read([]);
      expect(snapshot.next, isNull);
      expect(snapshot.history, isEmpty);
    });
  });

  group('Dev fake', () {
    test(
      'a domestic next trip 3 h out, and three history rows in 90 days',
      () async {
        final repository = DevTripRepository(clock: _Clock());

        final snapshot = (await repository.getTrips()).valueOrNull!;

        expect(snapshot.next!.departureUtc, _now.add(const Duration(hours: 3)));
        expect(snapshot.next!.gate, 'D12');
        expect(snapshot.history, hasLength(3));
        expect(
          snapshot.history.every(
            (t) => _now.difference(t.departureUtc) < tripHistoryRetention,
          ),
          isTrue,
        );
        expect(repository.lastKnown, snapshot);
      },
    );
  });
}
