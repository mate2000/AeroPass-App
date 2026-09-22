import '../../core/result.dart';
import '../../domain/entities/identity_record.dart';
import '../../domain/repositories/identity_record_repository.dart';

/// A local, no-network `IdentityRecordRepository` used only when the app is
/// launched with `--dart-define=USE_FAKE_VERIFICATION_BACKEND=true` (see
/// `.vscode/launch.json`'s "dev, offline demo" config and
/// `composition_root.dart`). Always accepts the confirmed record — lets
/// 004-confirmar-datos's "Los datos son correctos" action be reviewed
/// end-to-end (advancing to the selfie-instructions stub) before a real
/// backend exists. Writes no local display-only cache, unlike the real
/// implementation — nothing in this demo path needs it read back.
class DevIdentityRecordRepository implements IdentityRecordRepository {
  @override
  Future<Result<IdentityRecord>> confirm(IdentityRecord record) async {
    return Result.ok(record);
  }
}
