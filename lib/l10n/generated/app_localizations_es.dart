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
      'Aceptamos cédula de ciudadanía, cédula de extranjería o pasaporte. Ubica el documento completo sobre una superficie lisa y de un solo color.';

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

  @override
  String get confirmationNoticeText =>
      'Verifica que los datos coincidan exactamente con tu documento original.';

  @override
  String get confirmationCapturedBadgeLabel => 'Capturado';

  @override
  String get confirmationFieldFullNameLabel => 'Nombre completo';

  @override
  String get confirmationFieldDocumentNumberLabel => 'Número de documento';

  @override
  String get confirmationFieldNationalityLabel => 'Nacionalidad';

  @override
  String get confirmationFieldExpiryDateLabel => 'Fecha de vencimiento';

  @override
  String get confirmationEditActionLabel => 'Editar';

  @override
  String get confirmationSaveEditLabel => 'Guardar';

  @override
  String get confirmationCancelEditLabel => 'Cancelar';

  @override
  String get confirmationInvalidFormatMessage =>
      'El valor ingresado no tiene el formato esperado.';

  @override
  String get confirmationUnresolvedMessage =>
      'No pudimos confirmar este dato con tu documento. Puedes intentarlo de nuevo o escanear otra vez.';

  @override
  String get confirmationReverifyingLabel => 'Verificando...';

  @override
  String get confirmationPrimaryActionLabel => 'Los datos son correctos';

  @override
  String get confirmationSecondaryActionLabel => 'Escanear de nuevo';

  @override
  String get confirmationConfirmFailedMessage =>
      'No pudimos guardar tus datos. Verifica tu conexión e inténtalo de nuevo.';

  @override
  String get confirmationMissingFieldLabel => 'No pudimos leer este dato';

  @override
  String get confirmationExpiredHeadline => 'Tu documento está vencido';

  @override
  String get confirmationExpiredBody =>
      'No podemos continuar la inscripción con un documento vencido.';

  @override
  String get confirmationMissingFieldHeadline =>
      'No pudimos leer todos los datos de tu documento';

  @override
  String get confirmationMissingFieldBody =>
      'Vuelve a escanear tu documento para intentar leer el dato faltante.';

  @override
  String get selfieInstructionsTitle => 'Ahora una selfie';

  @override
  String get selfieInstructionsSubtitle =>
      'Necesitamos confirmar que eres el titular del documento.';

  @override
  String get selfieInstructionsRuleLightingLabel =>
      'Buena iluminación, de frente a la luz';

  @override
  String get selfieInstructionsRuleFaceVisibleLabel =>
      'Rostro descubierto y visible por completo';

  @override
  String get selfieInstructionsRuleEyesLabel => 'Mira directamente a la cámara';

  @override
  String get selfieInstructionsPrimaryActionLabel => 'Tomar selfie';

  @override
  String get livenessFooter =>
      'La captura es automática — no toques la pantalla';

  @override
  String livenessProgressBadge(int percent) {
    return '$percent%';
  }

  @override
  String get livenessInstructionMoveCloser => 'Acércate un poco';

  @override
  String get livenessInstructionMoveBack => 'Aléjate un poco';

  @override
  String get livenessInstructionCenterFace => 'Centra tu rostro en el óvalo';

  @override
  String get livenessInstructionHoldStill => 'Mantente quieto';

  @override
  String get livenessInstructionLookAtCamera => 'Mira directamente a la cámara';

  @override
  String get livenessInstructionImproveLighting =>
      'Busca un lugar con mejor iluminación';

  @override
  String get livenessFailureGenericHeadline =>
      'No pudimos completar la captura';

  @override
  String get livenessFailureGenericBody =>
      'Vuelve a intentarlo en un lugar con buena luz, mirando directamente a la cámara.';

  @override
  String get livenessFailureTooDarkHeadline => 'Hay poca luz';

  @override
  String get livenessFailureTooDarkBody =>
      'Busca un lugar con mejor iluminación y vuelve a intentarlo.';

  @override
  String get livenessFailureFaceOutOfFrameHeadline =>
      'No pudimos ver tu rostro completo';

  @override
  String get livenessFailureFaceOutOfFrameBody =>
      'Centra tu rostro dentro del óvalo y vuelve a intentarlo.';

  @override
  String get livenessFailureMovementDetectedHeadline =>
      'Detectamos demasiado movimiento';

  @override
  String get livenessFailureMovementDetectedBody =>
      'Mantente quieto durante la captura y vuelve a intentarlo.';

  @override
  String get livenessFailureMultipleFacesDetectedHeadline =>
      'Detectamos más de un rostro';

  @override
  String get livenessFailureMultipleFacesDetectedBody =>
      'Asegúrate de que solo tu rostro esté frente a la cámara y vuelve a intentarlo.';

  @override
  String get livenessFailureFaceObstructedHeadline =>
      'Tu rostro no está completamente visible';

  @override
  String get livenessFailureFaceObstructedBody =>
      'Descubre tu rostro por completo y vuelve a intentarlo.';

  @override
  String get livenessFailureRetryLabel => 'Reintentar';

  @override
  String get livenessStalledHeadline => 'La captura tardó más de lo esperado';

  @override
  String get livenessStalledBody =>
      'Vuelve a intentarlo en un lugar con buena luz y señal.';

  @override
  String get livenessStalledRetryLabel => 'Reintentar';

  @override
  String get credentialActivatedTitle => 'Tu identidad digital está activa';

  @override
  String get credentialActivatedSubtitle =>
      'A partir de ahora, pasa los filtros de seguridad donde AeroPass está disponible sin mostrar documentos físicos.';

  @override
  String get credentialCardLabel => 'IDENTIDAD DIGITAL';

  @override
  String credentialCardIssuedOn(String date) {
    return 'Creada el $date';
  }

  @override
  String credentialCardValidUntil(String date) {
    return 'Válida hasta $date';
  }

  @override
  String get credentialCardActiveBadge => 'ACTIVA';

  @override
  String credentialCardMaskedDocument(String last4, String countryCode) {
    return '•••• $last4 · $countryCode';
  }

  @override
  String credentialCardMaskedDocumentSemantics(String last4, String country) {
    return 'Documento terminado en $last4, $country';
  }

  @override
  String get credentialCardPortraitSemantics => 'Imagen genérica de perfil';

  @override
  String get countryNameCol => 'Colombia';

  @override
  String get credentialActivatedPrimaryAction => 'Ir a mis viajes';

  @override
  String get credentialActivatedSecondaryAction => 'Ver mi identidad';

  @override
  String get verificationProgressMessage =>
      'Estamos activando tu identidad digital…';

  @override
  String get verificationProgressFailedMessage =>
      'No pudimos completar la activación. Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get verificationProgressRetryLabel => 'Reintentar';

  @override
  String get credentialNotActivePlaceholderMessage =>
      'No pudimos activar tu identidad digital. (Pantalla pendiente de su propia especificación.)';

  @override
  String get credentialDetailPlaceholderMessage =>
      'Tu identidad digital (pantalla pendiente de su propia especificación).';

  @override
  String get tripsGreetingMorning => 'Buenos días,';

  @override
  String get tripsGreetingAfternoon => 'Buenas tardes,';

  @override
  String get tripsGreetingEvening => 'Buenas noches,';

  @override
  String tripsMaskedDocument(String last4) {
    return '•••• $last4';
  }

  @override
  String get tripsBadgeActive => 'ACTIVA';

  @override
  String get tripsBadgeExpired => 'VENCIDA';

  @override
  String get tripsBadgeRevoked => 'REVOCADA';

  @override
  String get tripsBadgeSuspended => 'SUSPENDIDA';

  @override
  String get tripsBadgeUnconfirmed => 'sin confirmar';

  @override
  String get tripsNextHeading => 'PRÓXIMO VIAJE';

  @override
  String get tripsHistoryHeading => 'VIAJES RECIENTES';

  @override
  String tripsToday(String hora) {
    return 'Hoy · $hora';
  }

  @override
  String tripsTomorrow(String hora) {
    return 'Mañana · $hora';
  }

  @override
  String tripsOnDate(String fecha, String hora) {
    return '$fecha · $hora';
  }

  @override
  String tripsLocalTimeOf(String ciudad) {
    return '(hora local de $ciudad)';
  }

  @override
  String tripsGate(String gate) {
    return 'Puerta $gate';
  }

  @override
  String tripsSeat(String seat) {
    return 'Asiento $seat';
  }

  @override
  String get tripsDetailsUnavailable => 'Detalles no disponibles';

  @override
  String get tripsStatusDelayed => 'Retrasado';

  @override
  String get tripsStatusCancelled => 'Vuelo cancelado';

  @override
  String get tripsStatusUnknown => 'Estado no disponible';

  @override
  String tripsConnectsTo(String ciudad) {
    return 'Conexión a $ciudad';
  }

  @override
  String tripsUpdatedAgo(int min) {
    return 'Actualizado hace $min min';
  }

  @override
  String get tripsStart => 'Iniciar viaje';

  @override
  String get tripsReasonUnconfirmed =>
      'Sin conexión: no pudimos confirmar tu identidad';

  @override
  String get tripsReasonExpired => 'Tu identidad está vencida';

  @override
  String get tripsReasonRevoked => 'Tu identidad está revocada';

  @override
  String get tripsReasonSuspended => 'Tu identidad está suspendida';

  @override
  String get tripsReasonDeparted => 'Este vuelo ya salió';

  @override
  String tripsReasonAvailableFrom(String dia, String hora) {
    return 'Disponible desde el $dia a las $hora';
  }

  @override
  String tripsRouteSemantics(
    String origen,
    String destino,
    String vuelo,
    String cuando,
  ) {
    return 'De $origen a $destino, vuelo $vuelo, $cuando';
  }

  @override
  String get tripsEmptyTitle => 'Aún no tienes viajes';

  @override
  String get tripsEmptyBody =>
      'Cuando reserves un vuelo nacional con el mismo documento con el que te registraste, tu aerolínea lo agregará aquí. No tienes que hacer nada.';

  @override
  String get tripsHistoryRetention =>
      'Mostramos tus viajes de los últimos 90 días.';

  @override
  String tripsHistoryRow(String vuelo, String fecha) {
    return '$vuelo · $fecha';
  }

  @override
  String get tripsUnavailableTitle => 'No pudimos cargar tus viajes';

  @override
  String get tripsRetry => 'Reintentar';

  @override
  String get homeTabTrips => 'Viajes';

  @override
  String get homeTabIdentity => 'Identidad';

  @override
  String get homeTabProfile => 'Perfil';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileWithdrawConsent => 'Retirar consentimiento';

  @override
  String get tripVerificationTitle => 'Validación automática';

  @override
  String get tripVerificationBody =>
      'Aquí confirmaremos que eres tú antes de emitir tu pase. Esta pantalla llegará pronto.';

  @override
  String get tripVerificationBack => 'Volver';

  @override
  String get verificationHeader => 'Verificando';

  @override
  String get verificationTitle => 'Estamos validando tu identidad';

  @override
  String get verificationSubtitle =>
      'Esto toma unos segundos. No cierres la aplicación.';

  @override
  String get verificationStageDocumentRunning => 'Verificando documento';

  @override
  String get verificationStageDocumentPassed => 'Documento verificado';

  @override
  String get verificationStageFaceRunning => 'Comparando rostro';

  @override
  String get verificationStageFacePassed => 'Rostro verificado';

  @override
  String get verificationStageIssuanceRunning => 'Creando identidad digital';

  @override
  String get verificationStageIssuancePassed => 'Identidad digital creada';

  @override
  String get verificationFailureLine => 'No pudimos completar la verificación';

  @override
  String get verificationSlowNotice => 'Está tardando más de lo habitual';

  @override
  String get verificationKeepWaiting => 'Seguir esperando';

  @override
  String get verificationHelp => 'Ayuda';

  @override
  String get technicalErrorHelp => 'Ayuda';

  @override
  String get technicalErrorServiceTitle => 'No pudimos completar la validación';

  @override
  String get technicalErrorServiceSubtitle =>
      'Es un problema nuestro, no tuyo.';

  @override
  String get technicalErrorNotified => 'Nuestro equipo ya fue notificado.';

  @override
  String get technicalErrorConnectivityTitle => 'No pudimos conectarnos';

  @override
  String get technicalErrorConnectivitySubtitle =>
      'Parece que se perdió la conexión a internet.';

  @override
  String get technicalErrorConnectivityGuidance =>
      'Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get technicalErrorUndeterminedTitle =>
      'No pudimos completar la validación';

  @override
  String get technicalErrorUndeterminedSubtitle =>
      'No fue por algo que hayas hecho.';

  @override
  String technicalErrorRetryAt(String hora) {
    return 'Puedes reintentar a las $hora.';
  }

  @override
  String get technicalErrorPreservedNewSelfie =>
      'Tus datos del documento quedaron guardados. Al reintentar, solo tendrás que tomarte una nueva selfie.';

  @override
  String get technicalErrorPreservedRecheck =>
      'Tus datos del documento quedaron guardados. Al reintentar, revisaremos tu validación sin repetir fotos.';

  @override
  String get technicalErrorResumeWindow =>
      'Puedes retomar tu registro durante las próximas 24 horas.';

  @override
  String get technicalErrorStatusTitle => 'Estado del servicio';

  @override
  String get technicalErrorStepDocumentScan => 'Escaneo de documento';

  @override
  String get technicalErrorStepSelfie => 'Selfie';

  @override
  String get technicalErrorStepIssuance => 'Emisión de tu identidad';

  @override
  String get technicalErrorHealthOperational => 'Operativo';

  @override
  String get technicalErrorHealthDegraded => 'Con fallas';

  @override
  String get technicalErrorHealthUnavailable => 'No disponible';

  @override
  String get technicalErrorRetry => 'Reintentar';

  @override
  String technicalErrorRetryIn(int segundos) {
    return 'Reintentar en $segundos s';
  }

  @override
  String technicalErrorRetryHeldSemantics(int segundos) {
    return 'Reintentar no disponible por $segundos segundos';
  }

  @override
  String get technicalErrorExit => 'Salir';

  @override
  String get technicalErrorAgent => 'Hablar con un agente';

  @override
  String get technicalErrorCheckpointLine =>
      'También puedes usar el control de documentos habitual en el aeropuerto.';

  @override
  String get stepIndicatorPendingSuffix => 'pendiente';

  @override
  String get retryGuidanceHelp => 'Ayuda';

  @override
  String get retryGuidanceIconSemantics => 'Aviso';

  @override
  String get retrySelfieTitle => 'No pudimos confirmar que eres tú';

  @override
  String get retrySelfieBody =>
      'No logramos verificar tu identidad con esta selfie. ¡Sin problema, inténtalo otra vez!';

  @override
  String get retryAdviceHeading => 'Consejos para el siguiente intento:';

  @override
  String get retryTipLighting =>
      'Busca un lugar con buena iluminación, de preferencia natural.';

  @override
  String get retryTipFaceVisible =>
      'Asegúrate de que tu rostro esté descubierto y visible por completo.';

  @override
  String get retryTipHoldStill =>
      'Sostén el teléfono a la altura de tus ojos y quédate quieto.';

  @override
  String get retrySelfieLimitTitle => 'Alcanzaste el número máximo de intentos';

  @override
  String get retrySelfieLimitBody =>
      'Por ahora no puedes volver a tomar la selfie. Habla con un agente para volver a intentarlo, o usa el control de documentos habitual en el aeropuerto.';

  @override
  String get retryDocumentLimitTitle =>
      'Alcanzaste el número máximo de intentos con tu documento';

  @override
  String get retryDocumentLimitBody =>
      'Por ahora no puedes volver a escanear tu documento. Habla con un agente para volver a intentarlo, o usa el control de documentos habitual en el aeropuerto.';

  @override
  String get retryAction => 'Intentar de nuevo';

  @override
  String get retryAgentAction => 'Hablar con un agente';

  @override
  String get escalationHelp => 'Ayuda';

  @override
  String get escalationTitle => 'Necesitamos verificarte en persona';

  @override
  String get escalationBodyByChoice =>
      'Un agente en el módulo AeroPass puede ayudarte a completar tu verificación.';

  @override
  String get escalationBodyAfterLimit =>
      'No pudimos confirmar tu identidad automáticamente. Un agente en el módulo AeroPass puede ayudarte a completar el proceso.';

  @override
  String get escalationModuleTitle => 'Módulo AeroPass';

  @override
  String get escalationChatTitle => 'Chat con un agente';

  @override
  String get escalationChatPurpose =>
      'Resuelve tus dudas; la verificación se completa en el módulo.';

  @override
  String get escalationAvailableNow => 'Disponible ahora';

  @override
  String get escalationUnavailable => 'No disponible';

  @override
  String escalationOpensAt(String when) {
    return 'Abre $when';
  }

  @override
  String escalationEstimatedWait(int min, int max) {
    return 'Espera estimada: $min–$max minutos';
  }

  @override
  String get escalationDirectionsAction => 'Cómo llegar al módulo';

  @override
  String get escalationStartChatAction => 'Iniciar chat';

  @override
  String get escalationHomeAction => 'Volver al inicio';

  @override
  String get escalationReopenAction => 'Abrir nueva solicitud';

  @override
  String get escalationRetryAction => 'Reintentar';

  @override
  String get escalationCheckpointLine =>
      'También puedes usar el control de documentos habitual en el aeropuerto.';

  @override
  String get escalationNoChannelOpen =>
      'En este momento no hay canales abiertos. Revisa cuándo abren o usa el control de documentos habitual.';

  @override
  String get escalationDeclinedTitle => 'No pudimos completar tu verificación';

  @override
  String get escalationDeclinedBody =>
      'El agente no pudo verificar tu identidad. Puedes usar el control de documentos habitual en el aeropuerto.';

  @override
  String get escalationExpiredTitle => 'Tu solicitud expiró';

  @override
  String get escalationExpiredBody =>
      'Pasaron más de 24 horas. Puedes abrir una nueva solicitud; tu inscripción sigue guardada.';

  @override
  String get escalationUnavailableTitle => 'No pudimos abrir tu solicitud';

  @override
  String get escalationUnavailableBody =>
      'Revisa tu conexión y vuelve a intentarlo.';

  @override
  String get escalationLocationSheetTitle => 'Dónde encontrar el módulo';

  @override
  String escalationLocationHours(String hours) {
    return 'Horario: $hours';
  }

  @override
  String get agentChatTitle => 'Chat con un agente';

  @override
  String get agentChatNotice =>
      'Este chat responde tus dudas. No puede completar tu verificación y nunca recibe documentos.';

  @override
  String get agentChatHint => 'Escribe tu mensaje';

  @override
  String get agentChatSend => 'Enviar';

  @override
  String get agentChatNotSent => 'No enviado';

  @override
  String get passBack => 'Atrás';

  @override
  String get passHelp => 'Ayuda';

  @override
  String passSeat(String seat) {
    return 'Asiento $seat';
  }

  @override
  String passTripLine(
    String vuelo,
    String origen,
    String destino,
    String cuando,
  ) {
    return '$vuelo · $origen → $destino · $cuando';
  }

  @override
  String get passCheckpointSecurity => 'Seguridad';

  @override
  String get passCheckpointBoarding => 'Embarque';

  @override
  String passStepDone(String paso) {
    return '$paso, completado';
  }

  @override
  String passStepCurrent(String paso) {
    return '$paso, siguiente';
  }

  @override
  String passStepPending(String paso) {
    return '$paso, pendiente';
  }

  @override
  String passRefreshesIn(String tiempo) {
    return 'Se actualiza en $tiempo';
  }

  @override
  String get passCodeUpdated => 'Código actualizado';

  @override
  String get passCodeSemantics => 'Código de tu pase';

  @override
  String get passFooterSecurity =>
      'Presenta este código en el lector de seguridad';

  @override
  String get passFooterBoarding =>
      'Presenta este código en el lector de embarque';

  @override
  String get passCheckpointLine =>
      'Si tienes problemas, puedes usar el control habitual con tu documento.';

  @override
  String get passBoardedTitle => 'Abordaje confirmado';

  @override
  String get passBoardedBody => 'Buen viaje';

  @override
  String get passExpiredTitle => 'Este código expiró';

  @override
  String get passRequestNew => 'Solicitar nuevo código';

  @override
  String get passRevokedTitle => 'Tu identidad ya no está activa';

  @override
  String get passFlightChangedTitle => 'Tu vuelo cambió';

  @override
  String get passFlightCancelledTitle => 'Tu vuelo fue cancelado';

  @override
  String get passBackToTrips => 'Volver a Mis viajes';

  @override
  String get passClockTitle => 'La hora de tu teléfono no coincide';

  @override
  String get passClockBody =>
      'Activa la hora automática en los ajustes de tu teléfono.';

  @override
  String get passRetry => 'Reintentar';

  @override
  String get passCompromisedTitle =>
      'No podemos mostrar tu pase en este dispositivo';

  @override
  String get passTalkToAgent => 'Hablar con un agente';

  @override
  String get passIssuanceFailedTitle => 'No pudimos emitir tu código';

  @override
  String get passOfflineTitle => 'Necesitas conexión para obtener tu código';

  @override
  String get passDevExpire => 'Simular expirado';

  @override
  String get passContinueToPass => 'Continuar a tu pase';

  @override
  String get tripsViewPass => 'Ver pase';

  @override
  String get devSyntheticMarkerLabel => 'DEV · Resultado simulado';

  @override
  String get devSyntheticMarkerOk => 'Aprobado';

  @override
  String get devSyntheticMarkerSpoof => 'Falla de vida';

  @override
  String get devSyntheticMarkerOther => 'No coincide';

  @override
  String get devSyntheticMarkerTimeout => 'Sin respuesta';

  @override
  String get confirmationTypedNotice =>
      'Escribe los datos tal como aparecen en tu documento y revisa que coincidan. La fecha de vencimiento va como AAAA-MM-DD.';

  @override
  String get confirmationDocumentTypeLabel => 'Tipo de documento';

  @override
  String get confirmationDocumentTypeCc => 'Cédula de ciudadanía';

  @override
  String get confirmationDocumentTypeCe => 'Cédula de extranjería';

  @override
  String get confirmationDocumentTypePasaporte => 'Pasaporte';

  @override
  String get confirmationDocumentTypeInvalid => 'Elige el tipo de documento.';

  @override
  String get confirmationFailedConnection =>
      'No pudimos conectarnos. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get confirmationFailedServiceBusy =>
      'El servicio está ocupado en este momento. Inténtalo de nuevo en unos segundos.';

  @override
  String get confirmationFailedSession =>
      'No pudimos conectar tu sesión. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get confirmationFailedAccountHasOtherDocument =>
      'Esta cuenta ya tiene otro documento registrado. Un agente puede ayudarte.';

  @override
  String get passDocumentExpiredTitle => 'Tu documento está vencido';

  @override
  String get passIdentityNotActiveTitle => 'Tu identidad no está activa';

  @override
  String get passRenewing => 'Actualizando código…';

  @override
  String get tripsFlightCodeHeading => 'Tu vuelo';

  @override
  String get tripsFlightCodeLabel => 'Código de vuelo';

  @override
  String get tripsFlightCodeHint => 'Ej. AV9201';

  @override
  String get tripsFlightCodeInvalid => 'Revisa el código de vuelo (ej. AV9201)';

  @override
  String get tripsShowPass => 'Mostrar mi pase';

  @override
  String get escalationLaneOnlyTitle => 'Te atienden en el control habitual';

  @override
  String get escalationLaneOnlyBody =>
      'Por ahora no hay agentes disponibles desde la app. Acércate al control de documentos del aeropuerto con tu documento de identidad.';

  @override
  String get demoRibbonLabel => 'DEMO · biometría simulada';

  @override
  String get demoRibbonSemantics =>
      'Versión de demostración. La verificación biométrica es simulada; ninguna identidad queda verificada.';

  @override
  String get credentialActivatedTitleMock => 'Registro completado';

  @override
  String get credentialActivatedSubtitleMock =>
      'Esta es una versión de demostración. La biometría es simulada, así que este registro no sirve para pasar un control.';

  @override
  String get credentialCardBadgeMock => 'REGISTRADO';

  @override
  String get tripsBadgeMock => 'REGISTRADO';

  @override
  String get verificationStageDocumentPassedMock => 'Documento recibido';

  @override
  String get verificationStageFacePassedMock => 'Rostro procesado';

  @override
  String get withdrawalServerDataNotice =>
      'Tus datos en el servidor no se eliminan todavía desde la app.';

  @override
  String get signInTitle => 'Inicia sesión';

  @override
  String get signInPrivacy =>
      'Usamos tu correo solo para iniciar sesión. Lo gestiona Clerk, nuestro proveedor de identidad.';

  @override
  String get signInErrorNotAvailable =>
      'El inicio de sesión por correo no está disponible ahora.';

  @override
  String get signInCompleting => 'Iniciando sesión…';
}
