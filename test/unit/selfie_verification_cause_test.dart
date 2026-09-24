import 'dart:typed_data';

import 'package:aeropass_app/data/services/backend_error_mapper.dart';
import 'package:aeropass_app/data/services/selfie_verification_cause.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/scripted_backend_adapter.dart';

void main() {
  final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);

  group('before sending', () {
    test('an empty, oversized or non-JPEG selfie is named', () {
      expect(
        causeBeforeSending(Uint8List(0), maxBytes: 10),
        SelfieVerificationCause.emptySelfie,
      );
      expect(
        causeBeforeSending(Uint8List(11), maxBytes: 10),
        SelfieVerificationCause.tooLarge,
      );
      expect(
        causeBeforeSending(
          Uint8List.fromList([0x89, 0x50, 0x4E]),
          maxBytes: 10,
        ),
        SelfieVerificationCause.notJpeg,
      );
      expect(causeBeforeSending(jpeg, maxBytes: 10), isNull);
    });
  });

  group('backend errors', () {
    Future<SelfieVerificationCause> causeFor(String fixture) async {
      final dio = dioOver(
        ScriptedBackendAdapter()..enqueue(ScriptedResponse.error(fixture)),
      );
      try {
        await dio.post<dynamic>('/v1/biometrics/verifications');
      } on DioException catch (e) {
        return causeForFailure(e, mapBackendError(e));
      }
      fail('expected an error');
    }

    test(
      '503 ALMACENAMIENTO_NO_DISPONIBLE is the Blob storage cause',
      () async {
        expect(
          await causeFor('almacenamiento_no_disponible'),
          SelfieVerificationCause.blobStorage,
        );
      },
    );

    test('401 is the session cause', () async {
      expect(await causeFor('no_autenticado'), SelfieVerificationCause.session);
    });
  });

  group('transport', () {
    DioException dioError(DioExceptionType type, {int? status, Object? data}) =>
        DioException(
          requestOptions: RequestOptions(path: '/v1/biometrics/verifications'),
          type: type,
          response: status == null
              ? null
              : Response<dynamic>(
                  requestOptions: RequestOptions(),
                  statusCode: status,
                  data: data,
                ),
        );

    test('Vercel cutting the function is its own cause', () {
      final e = dioError(DioExceptionType.badResponse, status: 504);
      expect(
        causeForFailure(e, e),
        SelfieVerificationCause.backendFunctionTimeout,
      );
    });

    test('app timeouts and connection errors are named', () {
      for (final (type, cause) in [
        (DioExceptionType.sendTimeout, SelfieVerificationCause.appSendTimeout),
        (
          DioExceptionType.receiveTimeout,
          SelfieVerificationCause.appReceiveTimeout,
        ),
        (DioExceptionType.connectionError, SelfieVerificationCause.connection),
      ]) {
        final e = dioError(type);
        expect(causeForFailure(e, e), cause, reason: type.name);
      }
    });
  });
}
