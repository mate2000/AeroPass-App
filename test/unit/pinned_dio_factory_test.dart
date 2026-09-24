// 015 T014 (research.md §4, constitution Security "TLS with certificate
// pinning... fail closed"): the bundled roots are the only trust anchors. A
// real TLS server proves it: its chain is accepted when its root is an
// anchor, and refused otherwise, even though the platform's default roots
// are not consulted.
import 'dart:io';

import 'package:aeropass_app/data/services/pinned_dio_factory.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late Uri url;

  setUpAll(() async {
    final context = SecurityContext()
      ..useCertificateChain('test/fixtures/tls/localhost.pem')
      ..usePrivateKey('test/fixtures/tls/localhost.key');
    server = await HttpServer.bindSecure('localhost', 0, context);
    server.listen((request) {
      request.response
        ..statusCode = 200
        ..write('ok')
        ..close();
    });
    url = Uri.parse('https://localhost:${server.port}');
  });

  tearDownAll(() => server.close(force: true));

  TrustAnchors fromFiles(List<String> paths) => TrustAnchors.fromPemBytes([
    for (final path in paths) File(path).readAsBytesSync(),
  ]);

  test('the bundled GTS roots are all loaded from assets/tls', () {
    final anchors = fromFiles(TrustAnchors.assetPaths);
    expect(anchors.pems, hasLength(4));
    for (final pem in anchors.pems) {
      expect(String.fromCharCodes(pem), contains('BEGIN CERTIFICATE'));
    }
  });

  test('a chain ending in an anchor is accepted', () async {
    final dio = buildPinnedDio(
      baseUrl: '$url',
      anchors: fromFiles(['test/fixtures/tls/localhost.pem']),
    );
    final response = await dio.get<String>('/');
    expect(response.data, 'ok');
  });

  test('a chain not ending in an anchor fails closed', () async {
    final dio = buildPinnedDio(
      baseUrl: '$url',
      anchors: fromFiles(TrustAnchors.assetPaths),
    );
    await expectLater(
      dio.get<String>('/'),
      throwsA(
        isA<DioException>().having(
          (e) => e.type,
          'type',
          anyOf(DioExceptionType.badCertificate, DioExceptionType.unknown),
        ),
      ),
    );
  });

  test('plain http is refused unless the dev flag allows it', () {
    final anchors = fromFiles(TrustAnchors.assetPaths);
    expect(
      () => buildPinnedDio(baseUrl: 'http://10.0.2.2:8000', anchors: anchors),
      throwsArgumentError,
    );
    expect(
      () => buildPinnedDio(
        baseUrl: 'http://10.0.2.2:8000',
        anchors: anchors,
        allowInsecureHttp: true,
      ),
      returnsNormally,
    );
  });

  test('there are no anchors, there is no client', () {
    expect(
      () => buildPinnedDio(
        baseUrl: 'https://aeropass-lac.vercel.app',
        anchors: TrustAnchors.fromPemBytes(const []),
      ),
      throwsArgumentError,
    );
  });
}
