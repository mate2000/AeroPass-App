import '../../domain/entities/consent_text_version.dart';

/// The consent text compiled into the app (015 DEC-02, research.md §15).
/// The backend has no consent endpoint, so the text and its version live
/// here, and a new version ships as an app update.
///
/// **Not shippable to a real passenger as it stands (F-03).** The retention
/// sentence states the constitution's figure, 30 days after the last flight.
/// The backend's own specification says 90 days after revocation or the
/// last failed attempt, and nothing deletes images yet. One agreed figure,
/// and a deletion job that honors it, must exist before this text is shown
/// to anyone outside the team.
const bundledConsentTextVersionId = 'consent_text_es_v1';

final bundledConsentText = ConsentTextVersion(
  id: bundledConsentTextVersionId,
  points: const [
    ConsentPoint(
      icon: ConsentPointIcon.camera,
      heading: 'Qué se captura',
      body:
          'Una foto de tu documento, una foto de tu rostro y los datos de tu '
          'documento que escribes tú. Nunca tu contraseña ni datos bancarios.',
    ),
    ConsentPoint(
      icon: ConsentPointIcon.clock,
      heading: 'Tiempo de conservación',
      body:
          'Tus datos biométricos se almacenan hasta 30 días después de tu '
          'último vuelo, o hasta que solicites su eliminación, lo que ocurra '
          'primero.',
    ),
    ConsentPoint(
      icon: ConsentPointIcon.share,
      heading: 'Con quién se comparte',
      body:
          'Con aerolíneas y aeropuertos donde uses AeroPass, y con un '
          'proveedor externo especializado que realiza la verificación de '
          'identidad en nuestro nombre. Nunca con terceros con fines '
          'comerciales.',
    ),
  ],
  rightsStatement:
      'Puedes conocer, actualizar, rectificar, eliminar y revocar la '
      'autorización de tus datos personales en cualquier momento.',
  optionalityStatement:
      'Brindar estos datos es opcional: no estás obligado a autorizarlo.',
  processorDisclosure:
      'La verificación de identidad es realizada por un proveedor externo '
      'especializado en nombre de AeroPass.',
  privacyPolicyUrl: 'https://aeropass-lac.vercel.app/privacidad',
  termsUrl: 'https://aeropass-lac.vercel.app/terminos',
  publishedAt: DateTime.utc(2026, 9, 23),
);
