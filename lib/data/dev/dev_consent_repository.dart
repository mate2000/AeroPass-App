import '../../core/result.dart';
import '../../domain/entities/consent_record.dart';
import '../../domain/entities/consent_text_version.dart';
import '../../domain/entities/enrollment_attempt_id.dart';
import '../../domain/entities/processing_scope.dart';
import '../../domain/repositories/consent_repository.dart';

/// A local, in-memory `ConsentRepository` used only when the app is
/// launched with `--dart-define=USE_FAKE_CONSENT_BACKEND=true` (see
/// `.vscode/launch.json`'s "dev, offline demo" config and
/// `composition_root.dart`). Lets the consent gate be visually reviewed
/// against the UI reference before a real backend exists.
///
/// This is a deliberate, explicitly-flagged *substitute* for
/// `ConsentRepositoryImpl`, never a fallback *within* it — the production
/// "never fall back on a failed fetch" rule (research.md §5) is untouched;
/// `ConsentRepositoryImpl` still returns `Error` unconditionally on a
/// failed call, with no code path to this class.
///
/// The demo text below intentionally corrects the two errors spec.md's UI
/// Reference section flags in the raw screenshot (retention period,
/// processor disclosure) rather than reproducing them.
class DevConsentRepository implements ConsentRepository {
  ConsentRecord? _localRecord;

  static final _demoText = ConsentTextVersion(
    id: 'dev-demo-v1',
    points: [
      const ConsentPoint(
        icon: ConsentPointIcon.camera,
        heading: 'Qué se captura',
        body:
            'Imagen de tu documento, foto de tu rostro y los datos '
            'extraídos. Nunca tu contraseña ni datos bancarios.',
      ),
      const ConsentPoint(
        icon: ConsentPointIcon.clock,
        heading: 'Tiempo de conservación',
        body:
            'Tus datos biométricos se almacenan hasta 30 días después de '
            'tu último vuelo, o hasta que solicites su eliminación, lo '
            'que ocurra primero.',
      ),
      const ConsentPoint(
        icon: ConsentPointIcon.share,
        heading: 'Con quién se comparte',
        body:
            'Con aerolíneas y aeropuertos donde uses AeroPass, y con un '
            'proveedor externo especializado que realiza la verificación '
            'de identidad en nuestro nombre. Nunca con terceros con '
            'fines comerciales.',
      ),
    ],
    rightsStatement:
        'Puedes conocer, actualizar, rectificar, eliminar y revocar la '
        'autorización de tus datos personales en cualquier momento.',
    optionalityStatement:
        'Brindar estos datos es opcional: no estás obligado a autorizarlo.',
    processorDisclosure:
        'La verificación de identidad es realizada por un proveedor '
        'externo especializado en nombre de AeroPass.',
    privacyPolicyUrl: 'https://aeropass.example/privacidad',
    termsUrl: 'https://aeropass.example/terminos',
    publishedAt: DateTime.utc(2026, 1, 1),
  );

  @override
  Future<Result<ConsentTextVersion>> getCurrentText() async {
    return Result.ok(_demoText);
  }

  @override
  Future<Result<ConsentRecord>> recordConsent({
    required String textVersionId,
  }) async {
    final record = ConsentRecord(
      textVersionId: textVersionId,
      enrollmentAttemptId: EnrollmentAttemptId.generate(),
      scope: ProcessingScope.identityVerification,
      confirmedAt: DateTime.now(),
      status: ConsentRecordStatus.active,
    );
    _localRecord = record;
    return Result.ok(record);
  }

  @override
  Future<Result<ConsentRecord?>> getLocalRecord() async {
    return Result.ok(_localRecord);
  }

  @override
  Future<Result<ConsentRecord>> withdraw() async {
    final current = _localRecord;
    if (current == null) {
      return Result.error(StateError('no local record to withdraw'));
    }
    final withdrawn = current.copyWith(
      status: ConsentRecordStatus.withdrawn,
      withdrawalRequestedAt: DateTime.now(),
    );
    _localRecord = withdrawn;
    return Result.ok(withdrawn);
  }

  @override
  Future<void> retryPendingWithdrawal() async {}
}
