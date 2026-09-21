// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'AeroPass';

  @override
  String get splashLoadingLabel => 'Verificando tu credencial...';

  @override
  String get welcomeBenefitHeadline => 'Tu identidad, una sola vez.';

  @override
  String get welcomeBenefitDescription =>
      'Regístrate hoy y pasa seguridad sin volver a mostrar documentos. Este servicio no tiene ningún costo para ti.';

  @override
  String get welcomeStepDocumentTitle => 'Escanea tu documento de identidad';

  @override
  String get welcomeStepSelfieTitle => 'Toma una selfie rápida';

  @override
  String get welcomeStepTravelTitle => 'Viaja sin fricciones';

  @override
  String get welcomePrimaryActionLabel => 'Comenzar';

  @override
  String get welcomeSecondaryActionLabel => 'Ya tengo cuenta';

  @override
  String get welcomeReenrollmentRequiredHeadline =>
      'Tu credencial ya no es válida';

  @override
  String get welcomeReenrollmentRequiredExpiredDescription =>
      'Tu credencial venció. Vuelve a inscribirte para seguir usando AeroPass.';

  @override
  String get welcomeReenrollmentRequiredRevokedDescription =>
      'Tu credencial fue revocada. Vuelve a inscribirte para seguir usando AeroPass.';

  @override
  String get welcomeUnrefreshedIndicator =>
      'No pudimos actualizar tu información. Mostramos el último estado conocido.';

  @override
  String get welcomeResumeHeadline => 'Continúa donde lo dejaste';

  @override
  String get welcomeResumeDescription =>
      'Tienes una inscripción sin terminar. Puedes continuar ahora.';

  @override
  String get welcomeDeviceUnsupportedHeadline =>
      'Este dispositivo no admite la inscripción en la app';

  @override
  String get welcomeDeviceUnsupportedNoCameraDescription =>
      'Este dispositivo no tiene una cámara utilizable. Dirígete al mostrador del aeropuerto para continuar con el proceso habitual.';

  @override
  String get welcomeDeviceUnsupportedOsDescription =>
      'La versión del sistema operativo de este dispositivo no es compatible. Dirígete al mostrador del aeropuerto para continuar con el proceso habitual.';

  @override
  String get welcomePrivacyTermsLinkLabel => 'Cómo tratamos tus datos';

  @override
  String get termsScreenTitle => 'Cómo tratamos tus datos';

  @override
  String get termsWhatWeCollectHeading => 'Qué recopilamos';

  @override
  String get termsWhatWeCollectBody =>
      'Un documento de identidad y una selfie de verificación de vida, únicamente durante el proceso de inscripción.';

  @override
  String get termsWhoVerifiesHeading => 'Quién verifica tu identidad';

  @override
  String get termsWhoVerifiesBody =>
      'Un proveedor externo especializado realiza la verificación biométrica en nombre de AeroPass.';

  @override
  String get termsRetentionHeading => 'Cuánto tiempo se conserva';

  @override
  String get termsRetentionBody =>
      'La plantilla facial se conserva hasta 30 días después de tu último vuelo.';

  @override
  String get termsRevocationHeading => 'Cómo revocar tu consentimiento';

  @override
  String get termsRevocationBody =>
      'Puedes revocar tu consentimiento en cualquier momento desde la sección de cuenta de la aplicación, sin necesidad de contactar a soporte.';

  @override
  String get termsPlaceholderLinkNotice =>
      'Enlace a los términos legales completos: pendiente de publicación (placeholder de revisión interna).';

  @override
  String get consentTitle => 'Cómo tratamos tus datos';

  @override
  String get consentSubtitle =>
      'Tu privacidad es nuestra prioridad. Aquí te explicamos todo.';

  @override
  String get consentCheckboxLabel => 'Autorizo el tratamiento de mis datos';

  @override
  String get consentPrimaryActionLabel => 'Acepto y continúo';

  @override
  String get consentPrimaryActionDisabledHint =>
      'Marca la casilla de autorización para continuar.';

  @override
  String get consentSecondaryActionLabel => 'Ahora no';

  @override
  String get consentBarrierDismissLabel =>
      'Cerrar y volver a la pantalla de bienvenida';

  @override
  String get consentLegalLinksLabel =>
      'Leer política de privacidad y términos completos';

  @override
  String get consentPriorRecordBanner =>
      'Actualizamos los términos de tratamiento de datos. Revísalos y confírmalos de nuevo para continuar.';

  @override
  String get consentUnavailableOfflineHeadline => 'Sin conexión';

  @override
  String get consentUnavailableOfflineBody =>
      'No podemos mostrarte los términos de tratamiento de datos sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.';

  @override
  String get consentUnavailableFetchErrorHeadline =>
      'No pudimos cargar esta información';

  @override
  String get consentUnavailableFetchErrorBody =>
      'Ocurrió un problema al cargar los términos de tratamiento de datos. Inténtalo de nuevo en unos momentos.';

  @override
  String get consentRetryLabel => 'Reintentar';

  @override
  String get consentConfirmBlockedOfflineMessage =>
      'No podemos iniciar la inscripción sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.';

  @override
  String get consentConfirmBlockedGenericMessage =>
      'No pudimos guardar tu consentimiento. Inténtalo de nuevo.';

  @override
  String get consentDeclinedMessage =>
      'Puedes continuar con el proceso habitual del aeropuerto cuando quieras.';

  @override
  String get withdrawalTitle => 'Retirar tu consentimiento';

  @override
  String get withdrawalDescription =>
      'Al retirar tu consentimiento, tu credencial y cualquier pase se invalidan de inmediato. La solicitud se procesa en un máximo de 24 horas, incluso si ahora mismo no tienes conexión.';

  @override
  String get withdrawalConfirmActionLabel => 'Retirar consentimiento';

  @override
  String get withdrawalCancelActionLabel => 'Cancelar';

  @override
  String get withdrawalSuccessMessage =>
      'Tu consentimiento fue retirado. Tu credencial ya no es válida.';

  @override
  String get withdrawalNoRecordMessage =>
      'No encontramos un consentimiento activo para retirar en este dispositivo.';

  @override
  String get captureTopBarBackLabel => 'Atrás';

  @override
  String get captureTopBarHelpLabel => 'Ayuda';

  @override
  String get captureStepDocumentLabel => 'Documento';

  @override
  String get captureStepSelfieLabel => 'Selfie';

  @override
  String get captureStepDoneLabel => 'Listo';

  @override
  String get captureInstruction =>
      'Ubica tu cédula o pasaporte dentro del marco';

  @override
  String get captureHint => 'Evita reflejos y sombras';

  @override
  String get captureCaption => 'Toca el círculo central para capturar';

  @override
  String get captureTorchOnSemanticLabel => 'Apagar la linterna';

  @override
  String get captureTorchOffSemanticLabel => 'Encender la linterna';

  @override
  String get captureButtonSemanticLabel => 'Capturar documento';

  @override
  String get capturePermissionRationale =>
      'AeroPass necesita acceder a la cámara para escanear tu cédula o pasaporte. Solo se usa durante este paso y la foto nunca se guarda en tu dispositivo.';

  @override
  String get capturePermissionDeniedTemporaryHeadline =>
      'Necesitamos acceso a tu cámara';

  @override
  String get capturePermissionDeniedTemporaryBody =>
      'Sin acceso a la cámara no podemos escanear tu documento. Puedes intentarlo de nuevo.';

  @override
  String get capturePermissionRetryLabel => 'Reintentar';

  @override
  String get capturePermissionDeniedPermanentHeadline =>
      'El acceso a la cámara está bloqueado';

  @override
  String get capturePermissionDeniedPermanentBody =>
      'Activa el permiso de cámara para AeroPass desde los ajustes del sistema para continuar con la inscripción.';

  @override
  String get capturePermissionOpenSettingsLabel => 'Abrir configuración';

  @override
  String get captureConventionalProcessStatement =>
      'Mientras tanto, puedes continuar con el proceso habitual en el mostrador del aeropuerto.';

  @override
  String get captureOfflineHeadline => 'Sin conexión';

  @override
  String get captureOfflineBody =>
      'No podemos enviar tu documento para verificación sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.';

  @override
  String get captureOfflineRetryLabel => 'Reintentar';

  @override
  String get captureRejectionBlurHeadline => 'La imagen está borrosa';

  @override
  String get captureRejectionBlurBody =>
      'Mantén el teléfono firme y espera a que enfoque antes de capturar.';

  @override
  String get captureRejectionGlareHeadline => 'Hay reflejo sobre el documento';

  @override
  String get captureRejectionGlareBody =>
      'Aleja el documento de luces directas o cambia el ángulo para evitar el brillo.';

  @override
  String get captureRejectionFramingHeadline =>
      'El documento no está completo en el marco';

  @override
  String get captureRejectionFramingBody =>
      'Ubica el documento completo dentro del marco antes de capturar.';

  @override
  String get captureRejectionWrongDocumentHeadline =>
      'Este documento no es válido';

  @override
  String get captureRejectionWrongDocumentBody =>
      'Solo aceptamos cédula de ciudadanía o pasaporte colombiano. Verifica que sea el documento correcto.';

  @override
  String get captureRejectionLowResolutionHeadline =>
      'La imagen no tiene suficiente calidad';

  @override
  String get captureRejectionLowResolutionBody =>
      'Acércate un poco más al documento y vuelve a intentarlo.';

  @override
  String get captureRejectionUnreadableHeadline =>
      'No pudimos leer tu documento';

  @override
  String get captureRejectionUnreadableBody =>
      'Verifica que el documento esté en buen estado, bien iluminado y vuelve a intentarlo.';

  @override
  String get captureRejectionRetryLabel => 'Reintentar';
}
