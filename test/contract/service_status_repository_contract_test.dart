// 011-error-tecnico T024: the dev service-status stand-in.
// 015 T048: the real implementation called `GET /v1/service-status`, which
// the backend does not have. It was deleted with its tests, and release
// builds wire no status source, so 011 omits its card (FR-025).
import 'package:aeropass_app/data/dev/dev_service_status_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Dev fake', () {
    test('there is never a status in development', () async {
      final result = await const DevServiceStatusRepository().getStatus();
      expect(result.isError, isTrue);
    });
  });
}
