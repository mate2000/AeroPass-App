// ignore_for_file: lines_longer_than_80_chars
import 'package:clerk_flutter/generated/clerk_sdk_localizations.dart';

/// Spanish for Clerk's embedded sign-in UI (015). `clerk_flutter` ships
/// English only, and AeroPass speaks Spanish (es-CO).
///
/// Error strings that carry an argument (`serverErrorResponse`,
/// `unknownError`, `externalError`, …) do not echo it: Clerk puts its own
/// server message there, which may repeat the address typed and is never
/// shown to the passenger (FR-007).
class ClerkSdkLocalizationsEs extends ClerkSdkLocalizations {
  ClerkSdkLocalizationsEs([super.locale = 'es']);

  @override
  String aLengthOfBetweenMINAndMAX(int min, int max) =>
      'una longitud de entre $min y $max';
  @override
  String aLengthOfMINOrGreater(int min) => 'una longitud de $min o más';
  @override
  String get aLowercaseLetter => 'una letra MINÚSCULA';
  @override
  String get aNumber => 'un NÚMERO';
  @override
  String aSpecialCharacter(String chars) => 'un CARÁCTER ESPECIAL ($chars)';
  @override
  String get abandoned => 'abandonado';
  @override
  String get acceptTerms =>
      'Acepto los Términos del servicio y la Política de privacidad';
  @override
  String get active => 'activo';
  @override
  String get addAccount => 'Agregar cuenta';
  @override
  String get addDomain => 'Agregar dominio';
  @override
  String get addEmailAddress => 'Agregar correo electrónico';
  @override
  String get addPasskey => 'Agregar una llave de acceso';
  @override
  String get addPhoneNumber => 'Agregar número de teléfono';
  @override
  String get alreadyHaveAnAccount => '¿Ya tienes cuenta?';
  @override
  String get anUppercaseLetter => 'una letra MAYÚSCULA';
  @override
  String get and => 'y';
  @override
  String get areYouSure => '¿Estás seguro?';
  @override
  String authenticationServiceError(String arg) =>
      'Hubo un error en el servicio de autenticación. Inténtalo de nuevo.';
  @override
  String get authenticatorApp => 'app de autenticación';
  @override
  String get automaticInvitation => 'Invitación automática';
  @override
  String get automaticSuggestion => 'Sugerencia automática';
  @override
  String get back => 'Atrás';
  @override
  String get backupCode => 'código de respaldo';
  @override
  String get cancel => 'Cancelar';
  @override
  String get cannotDeleteSelf => 'No tienes permiso para eliminar tu usuario';
  @override
  String clickOnTheLinkThatsBeenSentTo(String identifier) =>
      'Abre el enlace que enviamos a $identifier y luego vuelve aquí';
  @override
  String get clickOnTheLinkThatsBeenSentToYou =>
      'Abre el enlace que te enviamos y luego vuelve aquí';
  @override
  String get complete => 'completo';
  @override
  String get connectAccount => 'Conectar cuenta';
  @override
  String get connectedAccounts => 'Cuentas conectadas';
  @override
  String get cont => 'Continuar';
  @override
  String get createOrganization => 'Crear organización';
  @override
  String get created => 'Creado';
  @override
  String get developmentMode => 'Modo de desarrollo';
  @override
  String get didntReceiveCode => '¿No recibiste el código?';
  @override
  String get domainName => 'Nombre de dominio';
  @override
  String get dontHaveAnAccount => '¿No tienes cuenta?';
  @override
  String get edit => 'editar';
  @override
  String get emailAddress => 'correo electrónico';
  @override
  String get emailAddressConcise => 'correo';
  @override
  String get emailAddresses => 'Correos electrónicos';
  @override
  String get enrollment => 'Inscripción';
  @override
  String get enrollmentMode => 'Modo de inscripción:';
  @override
  String get enterOneOfYourBackupCodes =>
      'Escribe uno de tus códigos de respaldo';
  @override
  String get enterTheCodeFromYourAuthenticatorApp =>
      'Escribe el código que genera tu app de autenticación';
  @override
  String enterTheCodeSentTo(String identifier) =>
      'Escribe el código que enviamos a $identifier';
  @override
  String get enterTheCodeSentToYou => 'Escribe el código que te enviamos';
  @override
  String get enterTheCodeSentToYouByEmail =>
      'Escribe el código que te enviamos por correo';
  @override
  String get enterTheCodeSentToYouByTextMessage =>
      'Escribe el código que te enviamos por mensaje de texto';
  @override
  String get enterYourOrganizationDetailsToContinue =>
      'Escribe los datos de tu organización para continuar';
  @override
  String get enterYourPassword => 'Escribe tu contraseña';
  @override
  String get expired => 'vencido';
  @override
  String externalError(String arg) => 'Ocurrió un error. Inténtalo de nuevo.';
  @override
  String get failed => 'fallido';
  @override
  String get firstName => 'nombre';
  @override
  String get forgottenPassword => '¿Olvidaste tu contraseña?';
  @override
  String get generalDetails => 'Datos generales';
  @override
  String invalidEmailAddress(String address) =>
      'El correo electrónico no es válido';
  @override
  String invalidPhoneNumber(String number) =>
      'El número de teléfono no es válido';
  @override
  String get join => 'UNIRSE';
  @override
  String jwtPoorlyFormatted(String arg) =>
      'Ocurrió un error con la sesión. Inicia sesión de nuevo.';
  @override
  String get lastName => 'apellido';
  @override
  String get lastUsed => 'Último uso';
  @override
  String get leave => 'Salir';
  @override
  String leaveOrg(String organization) => 'Salir de $organization';
  @override
  String get leaveOrganization => 'Salir de la organización';
  @override
  String get legalAcceptanceRequired =>
      'Para crear tu cuenta debes aceptar los términos';
  @override
  String get loading => 'Cargando…';
  @override
  String get logo => 'Logo';
  @override
  String get longDateFormat => 'd \'de\' MMMM \'de\' y, h:mm a';
  @override
  String get manualInvitation => 'Invitación manual';
  @override
  String get missingRequirements => 'faltan datos';
  @override
  String get myOrganization => 'Mi organización';
  @override
  String get name => 'Nombre';
  @override
  String get needsFirstFactor => 'requiere primer factor';
  @override
  String get needsIdentifier => 'requiere identificador';
  @override
  String get needsSecondFactor => 'requiere segundo factor';
  @override
  String get newPassword => 'Nueva contraseña';
  @override
  String get newPasswordConfirmation => 'Confirma la nueva contraseña';
  @override
  String noAssociatedCodeRetrievalMethod(String arg) =>
      'No encontramos cómo enviarte un código.';
  @override
  String noAssociatedStrategy(String arg) =>
      'Este método de inicio de sesión no está disponible.';
  @override
  String get noInitialCodeHasBeenSetUpToResend =>
      'Todavía no se ha enviado ningún código para reenviar';
  @override
  String noSessionFoundForUser(String arg) =>
      'No encontramos una sesión. Inicia sesión de nuevo.';
  @override
  String get noSessionTokenRetrieved =>
      'No pudimos obtener tu sesión. Inicia sesión de nuevo.';
  @override
  String noStageForStatus(String arg) =>
      'Ocurrió un error. Inténtalo de nuevo.';
  @override
  String noSuchFirstFactorStrategy(String arg) =>
      'Este método de verificación no está disponible.';
  @override
  String noSuchSecondFactorStrategy(String arg) =>
      'Este método de verificación no está disponible.';
  @override
  String noUserAttributeForField(String arg) =>
      'Ocurrió un error. Inténtalo de nuevo.';
  @override
  String get ok => 'Aceptar';
  @override
  String get optional => '(opcional)';
  @override
  String get or => 'o';
  @override
  String get organizationProfile => 'Perfil de la organización';
  @override
  String get organizations => 'Organizaciones';
  @override
  String get passkey => 'llave de acceso';
  @override
  String get passkeys => 'Llaves de acceso';
  @override
  String get password => 'Contraseña';
  @override
  String get passwordConfirmation => 'confirma la contraseña';
  @override
  String get passwordMatchError => 'Las contraseñas no coinciden';
  @override
  String get passwordMustBeSupplied => 'Debes escribir una contraseña';
  @override
  String get passwordRequires => 'La contraseña necesita:';
  @override
  String get pending => 'pendiente';
  @override
  String get personalAccount => 'Cuenta personal';
  @override
  String get phoneNumber => 'número de teléfono';
  @override
  String get phoneNumberConcise => 'teléfono';
  @override
  String get phoneNumbers => 'Números de teléfono';
  @override
  String get pleaseAddRequiredInformation =>
      'Falta información. Completa los datos requeridos';
  @override
  String get pleaseChooseAnAccountToConnect => 'Elige una cuenta para conectar';
  @override
  String get pleaseEnterYourIdentifier => 'Escribe tu correo electrónico';
  @override
  String get primary => 'PRINCIPAL';
  @override
  String get privacyPolicy => 'Política de privacidad';
  @override
  String get profile => 'Perfil';
  @override
  String get profileDetails => 'Datos del perfil';
  @override
  String get recommendSize => 'Tamaño recomendado 1:1, hasta 5 MB.';
  @override
  String get requiredField => '(obligatorio)';
  @override
  String get requiredFieldsAreMissing => 'Faltan datos obligatorios';
  @override
  String get resend => 'Reenviar';
  @override
  String get resetFailed =>
      'No pudimos restablecer la contraseña. Te enviamos un código nuevo.';
  @override
  String get resetPassword => 'Restablecer contraseña e iniciar sesión';
  @override
  String get selectAccount => 'Elige la cuenta con la que quieres continuar';
  @override
  String get sendMeTheCode => 'Enviarme el código';
  @override
  String serverErrorResponse(String arg) =>
      'No pudimos completar la solicitud. Revisa los datos e inténtalo de nuevo.';
  @override
  String get setUpYourOrganization => 'Configura tu organización';
  @override
  String get signIn => 'Iniciar sesión';
  @override
  String get signInByCodeSentToYourEmail => 'Enviar un código a tu correo';
  @override
  String signInByEmailCode(String arg) => 'Enviar un código a $arg';
  @override
  String signInByEmailLink(String arg) => 'Enviar un enlace a $arg';
  @override
  String get signInByEnteringOneOfYourBackupCodes =>
      'Usar un código de respaldo';
  @override
  String get signInByLinkSentToYourEmail => 'Enviar un enlace a tu correo';
  @override
  String signInBySMSCode(String arg) => 'Enviar un código por SMS a $arg';
  @override
  String get signInBySMSCodeToYourPhone => 'Enviar un código a tu teléfono';
  @override
  String signInTo(String name) => 'Inicia sesión en $name';
  @override
  String get signInUsingEnterpriseSSO => 'Iniciar sesión con SSO empresarial';
  @override
  String get signInUsingYourAuthenticatorApp => 'Usar tu app de autenticación';
  @override
  String get signInWithOneOfYourBackupCodes =>
      'Usar uno de tus códigos de respaldo';
  @override
  String get signOut => 'Cerrar sesión';
  @override
  String signOutIdentifier(String identifier) => 'Cerrar sesión de $identifier';
  @override
  String get signOutOfAllAccounts => 'Cerrar sesión en todas las cuentas';
  @override
  String get signUp => 'Crear cuenta';
  @override
  String signUpTo(String name) => 'Crea tu cuenta en $name';
  @override
  String get slug => 'Identificador';
  @override
  String get slugUrl => 'URL del identificador';
  @override
  String get switchTo => 'Cambiar a';
  @override
  String get termsOfService => 'Términos del servicio';
  @override
  String get tooManyRetries =>
      'El servicio está ocupado. Inténtalo de nuevo en un momento.';
  @override
  String get transferable => 'transferible';
  @override
  String get twoStepVerification => 'Verificación en dos pasos';
  @override
  String typeTypeInvalid(String type) =>
      'Ocurrió un error. Inténtalo de nuevo.';
  @override
  String unknownError(String arg) => 'Ocurrió un error. Inténtalo de nuevo.';
  @override
  String unsupportedPasswordResetStrategy(String arg) =>
      'Este método para restablecer la contraseña no está disponible.';
  @override
  String get unverified => 'sin verificar';
  @override
  String get usePasskeyInstead => 'Usar una llave de acceso';
  @override
  String get username => 'nombre de usuario';
  @override
  String get verificationEmailAddress => 'Verificación del correo';
  @override
  String get verificationPhoneNumber => 'Verificación del teléfono';
  @override
  String get verified => 'verificado';
  @override
  String get verifiedDomains => 'Dominios verificados';
  @override
  String get verifyThisDevice => 'Verifica este dispositivo';
  @override
  String get verifyYourEmailAddress => 'Verifica tu correo electrónico';
  @override
  String get verifyYourPhoneNumber => 'Verifica tu número de teléfono';
  @override
  String get viaAutomaticInvitation => 'por invitación automática';
  @override
  String get viaAutomaticSuggestion => 'por sugerencia automática';
  @override
  String get viaManualInvitation => 'por invitación manual';
  @override
  String get web3Wallet => 'billetera web3';
  @override
  String get welcomeBackPleaseSignInToContinue =>
      '¡Hola de nuevo! Inicia sesión para continuar';
  @override
  String get welcomePleaseFillInTheDetailsToGetStarted =>
      '¡Hola! Completa los datos para empezar';
}
