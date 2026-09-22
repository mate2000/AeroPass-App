import 'dart:typed_data';

import '../../core/result.dart';
import '../../domain/entities/extraction_result.dart';
import '../../domain/entities/field_reverification_outcome.dart';
import '../../domain/repositories/field_reverification_repository.dart';

/// A local, no-network `FieldReverificationRepository` used only when the
/// app is launched with `--dart-define=USE_FAKE_VERIFICATION_BACKEND=true`
/// (see `.vscode/launch.json`'s "dev, offline demo" config and
/// `composition_root.dart`). Always confirms the passenger's edit, so a
/// high-confidence field's correction can be reviewed end-to-end (the
/// "reverifying" running state, then accepted-as-reverified) without a real
/// processor. Demoing the disagreed/unresolved path currently requires the
/// real backend — a deliberate simplification for a visual-review aid, not
/// a substitute for the contract test suite.
class DevFieldReverificationRepository implements FieldReverificationRepository {
  @override
  Future<Result<FieldReverificationOutcome>> reverify({
    required Uint8List documentImageBytes,
    required FieldKey field,
    required String candidateValue,
  }) async {
    return const Result.ok(FieldReverificationOutcome.confirmed());
  }
}
