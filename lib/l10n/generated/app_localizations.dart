import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// The application's display name.
  ///
  /// In es, this message translates to:
  /// **'AeroPass'**
  String get appTitle;

  /// Shown on the branded splash while the launch-time credential-status check runs (FR-017).
  ///
  /// In es, this message translates to:
  /// **'Verificando tu credencial...'**
  String get splashLoadingLabel;

  /// US1 / FR-001: the passenger-facing benefit statement.
  ///
  /// In es, this message translates to:
  /// **'Tu identidad, una sola vez.'**
  String get welcomeBenefitHeadline;

  /// US1 / FR-001: elaboration of the benefit, folding in the fact that the service is free to the passenger.
  ///
  /// In es, this message translates to:
  /// **'Regístrate hoy y pasa seguridad sin volver a mostrar documentos. Este servicio no tiene ningún costo para ti.'**
  String get welcomeBenefitDescription;

  /// First of the three enrollment steps (FR-001).
  ///
  /// In es, this message translates to:
  /// **'Escanea tu documento de identidad'**
  String get welcomeStepDocumentTitle;

  /// Second of the three enrollment steps (FR-001).
  ///
  /// In es, this message translates to:
  /// **'Toma una selfie rápida'**
  String get welcomeStepSelfieTitle;

  /// Third of the three enrollment steps (FR-001).
  ///
  /// In es, this message translates to:
  /// **'Viaja sin fricciones'**
  String get welcomeStepTravelTitle;

  /// FR-002: the single primary action.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get welcomePrimaryActionLabel;

  /// FR-002: the single secondary action, for account recovery on a new device.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo cuenta'**
  String get welcomeSecondaryActionLabel;

  /// FR-006: distinct explanation shown when a credential exists but is expired/revoked.
  ///
  /// In es, this message translates to:
  /// **'Tu credencial ya no es válida'**
  String get welcomeReenrollmentRequiredHeadline;

  /// No description provided for @welcomeReenrollmentRequiredExpiredDescription.
  ///
  /// In es, this message translates to:
  /// **'Tu credencial venció. Vuelve a inscribirte para seguir usando AeroPass.'**
  String get welcomeReenrollmentRequiredExpiredDescription;

  /// No description provided for @welcomeReenrollmentRequiredRevokedDescription.
  ///
  /// In es, this message translates to:
  /// **'Tu credencial fue revocada. Vuelve a inscribirte para seguir usando AeroPass.'**
  String get welcomeReenrollmentRequiredRevokedDescription;

  /// FR-007: shown when credential validity could not be confirmed because the backend is unreachable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos actualizar tu información. Mostramos el último estado conocido.'**
  String get welcomeUnrefreshedIndicator;

  /// FR-008: shown when an in-progress (process-alive) enrollment session can be resumed.
  ///
  /// In es, this message translates to:
  /// **'Continúa donde lo dejaste'**
  String get welcomeResumeHeadline;

  /// No description provided for @welcomeResumeDescription.
  ///
  /// In es, this message translates to:
  /// **'Tienes una inscripción sin terminar. Puedes continuar ahora.'**
  String get welcomeResumeDescription;

  /// FR-012: shown when the device can't complete enrollment.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no admite la inscripción en la app'**
  String get welcomeDeviceUnsupportedHeadline;

  /// No description provided for @welcomeDeviceUnsupportedNoCameraDescription.
  ///
  /// In es, this message translates to:
  /// **'Este dispositivo no tiene una cámara utilizable. Dirígete al mostrador del aeropuerto para continuar con el proceso habitual.'**
  String get welcomeDeviceUnsupportedNoCameraDescription;

  /// No description provided for @welcomeDeviceUnsupportedOsDescription.
  ///
  /// In es, this message translates to:
  /// **'La versión del sistema operativo de este dispositivo no es compatible. Dirígete al mostrador del aeropuerto para continuar con el proceso habitual.'**
  String get welcomeDeviceUnsupportedOsDescription;

  /// US3 / FR-010: link to the plain-language data-handling statement.
  ///
  /// In es, this message translates to:
  /// **'Cómo tratamos tus datos'**
  String get welcomePrivacyTermsLinkLabel;

  /// No description provided for @termsScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo tratamos tus datos'**
  String get termsScreenTitle;

  /// No description provided for @termsWhatWeCollectHeading.
  ///
  /// In es, this message translates to:
  /// **'Qué recopilamos'**
  String get termsWhatWeCollectHeading;

  /// No description provided for @termsWhatWeCollectBody.
  ///
  /// In es, this message translates to:
  /// **'Un documento de identidad y una selfie de verificación de vida, únicamente durante el proceso de inscripción.'**
  String get termsWhatWeCollectBody;

  /// No description provided for @termsWhoVerifiesHeading.
  ///
  /// In es, this message translates to:
  /// **'Quién verifica tu identidad'**
  String get termsWhoVerifiesHeading;

  /// No description provided for @termsWhoVerifiesBody.
  ///
  /// In es, this message translates to:
  /// **'Un proveedor externo especializado realiza la verificación biométrica en nombre de AeroPass.'**
  String get termsWhoVerifiesBody;

  /// No description provided for @termsRetentionHeading.
  ///
  /// In es, this message translates to:
  /// **'Cuánto tiempo se conserva'**
  String get termsRetentionHeading;

  /// No description provided for @termsRetentionBody.
  ///
  /// In es, this message translates to:
  /// **'La plantilla facial se conserva hasta 30 días después de tu último vuelo.'**
  String get termsRetentionBody;

  /// No description provided for @termsRevocationHeading.
  ///
  /// In es, this message translates to:
  /// **'Cómo revocar tu consentimiento'**
  String get termsRevocationHeading;

  /// No description provided for @termsRevocationBody.
  ///
  /// In es, this message translates to:
  /// **'Puedes revocar tu consentimiento en cualquier momento desde la sección de cuenta de la aplicación, sin necesidad de contactar a soporte.'**
  String get termsRevocationBody;

  /// FR-011: the screen ships against a placeholder link until legal delivers the final published URLs.
  ///
  /// In es, this message translates to:
  /// **'Enlace a los términos legales completos: pendiente de publicación (placeholder de revisión interna).'**
  String get termsPlaceholderLinkNotice;

  /// UI Reference: the gate's title. Static chrome, not part of the fetched ConsentTextVersion.
  ///
  /// In es, this message translates to:
  /// **'Cómo tratamos tus datos'**
  String get consentTitle;

  /// UI Reference: the gate's subtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu privacidad es nuestra prioridad. Aquí te explicamos todo.'**
  String get consentSubtitle;

  /// FR-004: the confirmation control's label.
  ///
  /// In es, this message translates to:
  /// **'Autorizo el tratamiento de mis datos'**
  String get consentCheckboxLabel;

  /// FR-006: the primary action, disabled until the checkbox is confirmed.
  ///
  /// In es, this message translates to:
  /// **'Acepto y continúo'**
  String get consentPrimaryActionLabel;

  /// FR-006: the disabled-state reason exposed to assistive technology (not color alone).
  ///
  /// In es, this message translates to:
  /// **'Marca la casilla de autorización para continuar.'**
  String get consentPrimaryActionDisabledHint;

  /// FR-009: the explicit decline action.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get consentSecondaryActionLabel;

  /// FR-010/SC-008: semantic label for the dimmed area outside the sheet, tapping it is equivalent to declining.
  ///
  /// In es, this message translates to:
  /// **'Cerrar y volver a la pantalla de bienvenida'**
  String get consentBarrierDismissLabel;

  /// FR-012: access to the full privacy policy/terms without leaving the enrollment context.
  ///
  /// In es, this message translates to:
  /// **'Leer política de privacidad y términos completos'**
  String get consentLegalLinksLabel;

  /// FR-014: shown when the gate is re-presented because the recorded consent refers to a superseded text version.
  ///
  /// In es, this message translates to:
  /// **'Actualizamos los términos de tratamiento de datos. Revísalos y confírmalos de nuevo para continuar.'**
  String get consentPriorRecordBanner;

  /// No description provided for @consentUnavailableOfflineHeadline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get consentUnavailableOfflineHeadline;

  /// Edge Cases: the consent text cannot be loaded; the gate blocks with an explanation rather than falling back to stale text.
  ///
  /// In es, this message translates to:
  /// **'No podemos mostrarte los términos de tratamiento de datos sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.'**
  String get consentUnavailableOfflineBody;

  /// No description provided for @consentUnavailableFetchErrorHeadline.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar esta información'**
  String get consentUnavailableFetchErrorHeadline;

  /// No description provided for @consentUnavailableFetchErrorBody.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un problema al cargar los términos de tratamiento de datos. Inténtalo de nuevo en unos momentos.'**
  String get consentUnavailableFetchErrorBody;

  /// No description provided for @consentRetryLabel.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get consentRetryLabel;

  /// FR-008: shown inline when recordConsent() fails while offline — the flow does not advance.
  ///
  /// In es, this message translates to:
  /// **'No podemos iniciar la inscripción sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.'**
  String get consentConfirmBlockedOfflineMessage;

  /// FR-008: shown inline when recordConsent() fails for a reason other than connectivity.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tu consentimiento. Inténtalo de nuevo.'**
  String get consentConfirmBlockedGenericMessage;

  /// FR-009: statement that the conventional airport process remains available, shown after declining or dismissing the gate.
  ///
  /// In es, this message translates to:
  /// **'Puedes continuar con el proceso habitual del aeropuerto cuando quieras.'**
  String get consentDeclinedMessage;

  /// FR-015/FR-016: the withdrawal placeholder route's title.
  ///
  /// In es, this message translates to:
  /// **'Retirar tu consentimiento'**
  String get withdrawalTitle;

  /// No description provided for @withdrawalDescription.
  ///
  /// In es, this message translates to:
  /// **'Al retirar tu consentimiento, tu credencial y cualquier pase se invalidan de inmediato. La solicitud se procesa en un máximo de 24 horas, incluso si ahora mismo no tienes conexión.'**
  String get withdrawalDescription;

  /// No description provided for @withdrawalConfirmActionLabel.
  ///
  /// In es, this message translates to:
  /// **'Retirar consentimiento'**
  String get withdrawalConfirmActionLabel;

  /// No description provided for @withdrawalCancelActionLabel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get withdrawalCancelActionLabel;

  /// SC-005: shown once the local invalidation effect has been applied, no network dependency.
  ///
  /// In es, this message translates to:
  /// **'Tu consentimiento fue retirado. Tu credencial ya no es válida.'**
  String get withdrawalSuccessMessage;

  /// No description provided for @withdrawalNoRecordMessage.
  ///
  /// In es, this message translates to:
  /// **'No encontramos un consentimiento activo para retirar en este dispositivo.'**
  String get withdrawalNoRecordMessage;

  /// UI Reference: top bar left control. FR-012: discards any held image and preserves the session as incomplete.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get captureTopBarBackLabel;

  /// UI Reference: top bar right control. FR-013: returns to this step with the session intact.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get captureTopBarHelpLabel;

  /// No description provided for @captureStepDocumentLabel.
  ///
  /// In es, this message translates to:
  /// **'Documento'**
  String get captureStepDocumentLabel;

  /// No description provided for @captureStepSelfieLabel.
  ///
  /// In es, this message translates to:
  /// **'Selfie'**
  String get captureStepSelfieLabel;

  /// No description provided for @captureStepDoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get captureStepDoneLabel;

  /// FR-003/FR-019: names the accepted documents — cédula de ciudadanía and Colombian passport only.
  ///
  /// In es, this message translates to:
  /// **'Ubica tu cédula o pasaporte dentro del marco'**
  String get captureInstruction;

  /// FR-003: glare/shadow avoidance guidance, visible while the preview is active.
  ///
  /// In es, this message translates to:
  /// **'Evita reflejos y sombras'**
  String get captureHint;

  /// No description provided for @captureCaption.
  ///
  /// In es, this message translates to:
  /// **'Toca el círculo central para capturar'**
  String get captureCaption;

  /// FR-005: announced when the torch is currently on (tapping turns it off).
  ///
  /// In es, this message translates to:
  /// **'Apagar la linterna'**
  String get captureTorchOnSemanticLabel;

  /// FR-005: announced when the torch is currently off (tapping turns it on).
  ///
  /// In es, this message translates to:
  /// **'Encender la linterna'**
  String get captureTorchOffSemanticLabel;

  /// FR-004/FR-016: the manual capture control.
  ///
  /// In es, this message translates to:
  /// **'Capturar documento'**
  String get captureButtonSemanticLabel;

  /// FR-002: the explanation shown alongside the camera-permission request.
  ///
  /// In es, this message translates to:
  /// **'AeroPass necesita acceder a la cámara para escanear tu cédula o pasaporte. Solo se usa durante este paso y la foto nunca se guarda en tu dispositivo.'**
  String get capturePermissionRationale;

  /// No description provided for @capturePermissionDeniedTemporaryHeadline.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos acceso a tu cámara'**
  String get capturePermissionDeniedTemporaryHeadline;

  /// No description provided for @capturePermissionDeniedTemporaryBody.
  ///
  /// In es, this message translates to:
  /// **'Sin acceso a la cámara no podemos escanear tu documento. Puedes intentarlo de nuevo.'**
  String get capturePermissionDeniedTemporaryBody;

  /// No description provided for @capturePermissionRetryLabel.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get capturePermissionRetryLabel;

  /// FR-014: shown after a permanent denial — MUST NOT re-prompt the system dialog again.
  ///
  /// In es, this message translates to:
  /// **'El acceso a la cámara está bloqueado'**
  String get capturePermissionDeniedPermanentHeadline;

  /// No description provided for @capturePermissionDeniedPermanentBody.
  ///
  /// In es, this message translates to:
  /// **'Activa el permiso de cámara para AeroPass desde los ajustes del sistema para continuar con la inscripción.'**
  String get capturePermissionDeniedPermanentBody;

  /// FR-014: the route to system settings.
  ///
  /// In es, this message translates to:
  /// **'Abrir configuración'**
  String get capturePermissionOpenSettingsLabel;

  /// FR-014/US3: states that the conventional airport process remains available.
  ///
  /// In es, this message translates to:
  /// **'Mientras tanto, puedes continuar con el proceso habitual en el mostrador del aeropuerto.'**
  String get captureConventionalProcessStatement;

  /// No description provided for @captureOfflineHeadline.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión'**
  String get captureOfflineHeadline;

  /// FR-015: shown when submission fails for a transport reason; the image is never queued to disk to survive the wait.
  ///
  /// In es, this message translates to:
  /// **'No podemos enviar tu documento para verificación sin conexión a internet. Verifica tu conexión e inténtalo de nuevo.'**
  String get captureOfflineBody;

  /// No description provided for @captureOfflineRetryLabel.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get captureOfflineRetryLabel;

  /// No description provided for @captureRejectionBlurHeadline.
  ///
  /// In es, this message translates to:
  /// **'La imagen está borrosa'**
  String get captureRejectionBlurHeadline;

  /// No description provided for @captureRejectionBlurBody.
  ///
  /// In es, this message translates to:
  /// **'Mantén el teléfono firme y espera a que enfoque antes de capturar.'**
  String get captureRejectionBlurBody;

  /// No description provided for @captureRejectionGlareHeadline.
  ///
  /// In es, this message translates to:
  /// **'Hay reflejo sobre el documento'**
  String get captureRejectionGlareHeadline;

  /// No description provided for @captureRejectionGlareBody.
  ///
  /// In es, this message translates to:
  /// **'Aleja el documento de luces directas o cambia el ángulo para evitar el brillo.'**
  String get captureRejectionGlareBody;

  /// No description provided for @captureRejectionFramingHeadline.
  ///
  /// In es, this message translates to:
  /// **'El documento no está completo en el marco'**
  String get captureRejectionFramingHeadline;

  /// No description provided for @captureRejectionFramingBody.
  ///
  /// In es, this message translates to:
  /// **'Ubica el documento completo dentro del marco antes de capturar.'**
  String get captureRejectionFramingBody;

  /// FR-019: shown when the shape doesn't match cédula de ciudadanía or Colombian passport.
  ///
  /// In es, this message translates to:
  /// **'Este documento no es válido'**
  String get captureRejectionWrongDocumentHeadline;

  /// No description provided for @captureRejectionWrongDocumentBody.
  ///
  /// In es, this message translates to:
  /// **'Solo aceptamos cédula de ciudadanía o pasaporte colombiano. Verifica que sea el documento correcto.'**
  String get captureRejectionWrongDocumentBody;

  /// No description provided for @captureRejectionLowResolutionHeadline.
  ///
  /// In es, this message translates to:
  /// **'La imagen no tiene suficiente calidad'**
  String get captureRejectionLowResolutionHeadline;

  /// No description provided for @captureRejectionLowResolutionBody.
  ///
  /// In es, this message translates to:
  /// **'Acércate un poco más al documento y vuelve a intentarlo.'**
  String get captureRejectionLowResolutionBody;

  /// No description provided for @captureRejectionUnreadableHeadline.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer tu documento'**
  String get captureRejectionUnreadableHeadline;

  /// No description provided for @captureRejectionUnreadableBody.
  ///
  /// In es, this message translates to:
  /// **'Verifica que el documento esté en buen estado, bien iluminado y vuelve a intentarlo.'**
  String get captureRejectionUnreadableBody;

  /// No description provided for @captureRejectionRetryLabel.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get captureRejectionRetryLabel;

  /// 004-confirmar-datos FR-012: visible before the fields, instructing exact comparison.
  ///
  /// In es, this message translates to:
  /// **'Verifica que los datos coincidan exactamente con tu documento original.'**
  String get confirmationNoticeText;

  /// Paired with a checkmark icon on the document thumbnail card.
  ///
  /// In es, this message translates to:
  /// **'Capturado'**
  String get confirmationCapturedBadgeLabel;

  /// No description provided for @confirmationFieldFullNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get confirmationFieldFullNameLabel;

  /// No description provided for @confirmationFieldDocumentNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Número de documento'**
  String get confirmationFieldDocumentNumberLabel;

  /// No description provided for @confirmationFieldNationalityLabel.
  ///
  /// In es, this message translates to:
  /// **'Nacionalidad'**
  String get confirmationFieldNationalityLabel;

  /// No description provided for @confirmationFieldExpiryDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de vencimiento'**
  String get confirmationFieldExpiryDateLabel;

  /// Prefixed to the field label to build each field's edit-button semantic label, e.g. 'Editar Nombre completo'.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get confirmationEditActionLabel;

  /// No description provided for @confirmationSaveEditLabel.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get confirmationSaveEditLabel;

  /// No description provided for @confirmationCancelEditLabel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get confirmationCancelEditLabel;

  /// FR-006: shown inline under a field being edited.
  ///
  /// In es, this message translates to:
  /// **'El valor ingresado no tiene el formato esperado.'**
  String get confirmationInvalidFormatMessage;

  /// FR-005: shown when the automated re-check could not confirm an edit.
  ///
  /// In es, this message translates to:
  /// **'No pudimos confirmar este dato con tu documento. Puedes intentarlo de nuevo o escanear otra vez.'**
  String get confirmationUnresolvedMessage;

  /// No description provided for @confirmationReverifyingLabel.
  ///
  /// In es, this message translates to:
  /// **'Verificando...'**
  String get confirmationReverifyingLabel;

  /// No description provided for @confirmationPrimaryActionLabel.
  ///
  /// In es, this message translates to:
  /// **'Los datos son correctos'**
  String get confirmationPrimaryActionLabel;

  /// No description provided for @confirmationSecondaryActionLabel.
  ///
  /// In es, this message translates to:
  /// **'Escanear de nuevo'**
  String get confirmationSecondaryActionLabel;

  /// FR-017: confirmation could not be recorded durably.
  ///
  /// In es, this message translates to:
  /// **'No pudimos guardar tus datos. Verifica tu conexión e inténtalo de nuevo.'**
  String get confirmationConfirmFailedMessage;

  /// FR-009: an explicit gap, never rendered as a blank value.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer este dato'**
  String get confirmationMissingFieldLabel;

  /// FR-008.
  ///
  /// In es, this message translates to:
  /// **'Tu documento está vencido'**
  String get confirmationExpiredHeadline;

  /// No description provided for @confirmationExpiredBody.
  ///
  /// In es, this message translates to:
  /// **'No podemos continuar la inscripción con un documento vencido.'**
  String get confirmationExpiredBody;

  /// FR-009.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer todos los datos de tu documento'**
  String get confirmationMissingFieldHeadline;

  /// No description provided for @confirmationMissingFieldBody.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a escanear tu documento para intentar leer el dato faltante.'**
  String get confirmationMissingFieldBody;

  /// 005-instrucciones-selfie FR-001.
  ///
  /// In es, this message translates to:
  /// **'Ahora una selfie'**
  String get selfieInstructionsTitle;

  /// No description provided for @selfieInstructionsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Necesitamos confirmar que eres el titular del documento.'**
  String get selfieInstructionsSubtitle;

  /// FR-002/FR-003, stated first since lighting is the most common cause of failure.
  ///
  /// In es, this message translates to:
  /// **'Buena iluminación, de frente a la luz'**
  String get selfieInstructionsRuleLightingLabel;

  /// FR-003/CONFLICT-001 resolved: states what must be visible (the unobstructed face), never a list of garments to remove — never asks to remove glasses or a religious head covering.
  ///
  /// In es, this message translates to:
  /// **'Rostro descubierto y visible por completo'**
  String get selfieInstructionsRuleFaceVisibleLabel;

  /// No description provided for @selfieInstructionsRuleEyesLabel.
  ///
  /// In es, this message translates to:
  /// **'Mira directamente a la cámara'**
  String get selfieInstructionsRuleEyesLabel;

  /// No description provided for @selfieInstructionsPrimaryActionLabel.
  ///
  /// In es, this message translates to:
  /// **'Tomar selfie'**
  String get selfieInstructionsPrimaryActionLabel;

  /// 006-selfie-liveness FR-003/FR-018, UI Reference.
  ///
  /// In es, this message translates to:
  /// **'La captura es automática — no toques la pantalla'**
  String get livenessFooter;

  /// FR-006, UI Reference ("64%", top right).
  ///
  /// In es, this message translates to:
  /// **'{percent}%'**
  String livenessProgressBadge(int percent);

  /// FR-004, UI Reference's example instruction.
  ///
  /// In es, this message translates to:
  /// **'Acércate un poco'**
  String get livenessInstructionMoveCloser;

  /// No description provided for @livenessInstructionMoveBack.
  ///
  /// In es, this message translates to:
  /// **'Aléjate un poco'**
  String get livenessInstructionMoveBack;

  /// No description provided for @livenessInstructionCenterFace.
  ///
  /// In es, this message translates to:
  /// **'Centra tu rostro en el óvalo'**
  String get livenessInstructionCenterFace;

  /// Also the fallback for an unrecognized processor instruction code (data-model.md).
  ///
  /// In es, this message translates to:
  /// **'Mantente quieto'**
  String get livenessInstructionHoldStill;

  /// No description provided for @livenessInstructionLookAtCamera.
  ///
  /// In es, this message translates to:
  /// **'Mira directamente a la cámara'**
  String get livenessInstructionLookAtCamera;

  /// No description provided for @livenessInstructionImproveLighting.
  ///
  /// In es, this message translates to:
  /// **'Busca un lugar con mejor iluminación'**
  String get livenessInstructionImproveLighting;

  /// FR-010/Clarifications: shared verbatim (text and styling) by unclassifiedFailure and attackDetected — never a message unique to attack detection.
  ///
  /// In es, this message translates to:
  /// **'No pudimos completar la captura'**
  String get livenessFailureGenericHeadline;

  /// No description provided for @livenessFailureGenericBody.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a intentarlo en un lugar con buena luz, mirando directamente a la cámara.'**
  String get livenessFailureGenericBody;

  /// FR-009, same vocabulary as 005-instrucciones-selfie's lighting condition.
  ///
  /// In es, this message translates to:
  /// **'Hay poca luz'**
  String get livenessFailureTooDarkHeadline;

  /// No description provided for @livenessFailureTooDarkBody.
  ///
  /// In es, this message translates to:
  /// **'Busca un lugar con mejor iluminación y vuelve a intentarlo.'**
  String get livenessFailureTooDarkBody;

  /// No description provided for @livenessFailureFaceOutOfFrameHeadline.
  ///
  /// In es, this message translates to:
  /// **'No pudimos ver tu rostro completo'**
  String get livenessFailureFaceOutOfFrameHeadline;

  /// No description provided for @livenessFailureFaceOutOfFrameBody.
  ///
  /// In es, this message translates to:
  /// **'Centra tu rostro dentro del óvalo y vuelve a intentarlo.'**
  String get livenessFailureFaceOutOfFrameBody;

  /// No description provided for @livenessFailureMovementDetectedHeadline.
  ///
  /// In es, this message translates to:
  /// **'Detectamos demasiado movimiento'**
  String get livenessFailureMovementDetectedHeadline;

  /// No description provided for @livenessFailureMovementDetectedBody.
  ///
  /// In es, this message translates to:
  /// **'Mantente quieto durante la captura y vuelve a intentarlo.'**
  String get livenessFailureMovementDetectedBody;

  /// No description provided for @livenessFailureMultipleFacesDetectedHeadline.
  ///
  /// In es, this message translates to:
  /// **'Detectamos más de un rostro'**
  String get livenessFailureMultipleFacesDetectedHeadline;

  /// No description provided for @livenessFailureMultipleFacesDetectedBody.
  ///
  /// In es, this message translates to:
  /// **'Asegúrate de que solo tu rostro esté frente a la cámara y vuelve a intentarlo.'**
  String get livenessFailureMultipleFacesDetectedBody;

  /// FR-009/CONFLICT-001, same vocabulary as 005's face-visibility condition — never names a specific garment.
  ///
  /// In es, this message translates to:
  /// **'Tu rostro no está completamente visible'**
  String get livenessFailureFaceObstructedHeadline;

  /// No description provided for @livenessFailureFaceObstructedBody.
  ///
  /// In es, this message translates to:
  /// **'Descubre tu rostro por completo y vuelve a intentarlo.'**
  String get livenessFailureFaceObstructedBody;

  /// No description provided for @livenessFailureRetryLabel.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get livenessFailureRetryLabel;

  /// FR-013: ends with an explanation rather than continuing indefinitely.
  ///
  /// In es, this message translates to:
  /// **'La captura tardó más de lo esperado'**
  String get livenessStalledHeadline;

  /// No description provided for @livenessStalledBody.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a intentarlo en un lugar con buena luz y señal.'**
  String get livenessStalledBody;

  /// No description provided for @livenessStalledRetryLabel.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get livenessStalledRetryLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
