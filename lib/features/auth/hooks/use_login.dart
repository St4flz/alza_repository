import 'package:alza/features/auth/providers/auth_provider.dart';

enum AuthStep { email, password }

class AuthFormResult {
  final AuthStep nextStep;
  final String nextEmail;
  final String systemMessage;
  final bool shouldClearInput;
  final bool emailExists;

  AuthFormResult({
    required this.nextStep,
    required this.nextEmail,
    required this.systemMessage,
    required this.shouldClearInput,
    required this.emailExists,
  });
}

class AuthHooks {
  /// Valida si el formato de correo electrónico ingresado es correcto.
  static bool isValidEmail(String email) {
    return email.contains('@');
  }

  /// Mapea y traduce errores complejos del servidor/Supabase a mensajes legibles.
  static String translateAuthError(
    String? errorMessage, {
    required bool emailExists,
  }) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return "Ocurrió un error inesperado";
    }
    final lowerMsg = errorMessage.toLowerCase();

    // Si falla el inicio de sesión y la cuenta ya existe (podría ser cuenta de Google sin contraseña)
    if (lowerMsg.contains("invalid login credentials")) {
      if (emailExists) {
        return "Credenciales inválidas. Si te registraste con Google, inicia sesión con Google o recupera la cuenta.";
      }
      return "Credenciales inválidas o el usuario no existe.";
    }

    if (lowerMsg.contains("already registered")) {
      return "Credenciales inválidas. Usa Google o recupera la cuenta.";
    }
    return errorMessage;
  }

  /// Procesa el flujo lógico de autenticación paso a paso.
  /// Retorna un `AuthFormResult` que define cómo debe actualizarse la UI.
  static Future<AuthFormResult> handleAuthFlow({
    required String text,
    required AuthStep currentStep,
    required String currentEmail,
    required AuthProvider authProvider,
    required bool emailExists,
  }) async {
    if (currentStep == AuthStep.email) {
      if (!isValidEmail(text)) {
        return AuthFormResult(
          nextStep: AuthStep.email,
          nextEmail: currentEmail,
          systemMessage: "Correo inválido",
          shouldClearInput: false,
          emailExists: false,
        );
      }

      // 2. Verificar si el correo ya existe en la base de datos
      final exists = await authProvider.checkEmailExists(text);
      if (exists) {
        return AuthFormResult(
          nextStep: AuthStep.password,
          nextEmail: text,
          systemMessage: "Inicio de sesión detectado",
          shouldClearInput: true,
          emailExists: true,
        );
      } else {
        return AuthFormResult(
          nextStep: AuthStep.password,
          nextEmail: text,
          systemMessage: "Registro detectado",
          shouldClearInput: true,
          emailExists: false,
        );
      }
    } else {
      if (emailExists) {
        // En el caso de "Escribe tu contraseña" se inicia sesión normalmente
        bool success = await authProvider.signIn(currentEmail, text);
        if (success) {
          return AuthFormResult(
            nextStep: AuthStep.password,
            nextEmail: currentEmail,
            systemMessage: "Inicio exitoso",
            shouldClearInput: false,
            emailExists: true,
          );
        } else {
          final errorMsg = authProvider.errorMessage ?? '';
          return AuthFormResult(
            nextStep: AuthStep.password,
            nextEmail: currentEmail,
            systemMessage: translateAuthError(errorMsg, emailExists: true),
            shouldClearInput: false,
            emailExists: true,
          );
        }
      } else {
        // En el caso de "Crea tu contraseña" se hace signup
        bool success = await authProvider.signUp(currentEmail, text);
        if (success) {
          return AuthFormResult(
            nextStep: AuthStep.email,
            nextEmail: '',
            systemMessage: "Registro exitoso. Revisa tu correo.",
            shouldClearInput: true,
            emailExists: false,
          );
        } else {
          final errorMsg = authProvider.errorMessage ?? '';
          return AuthFormResult(
            nextStep: AuthStep.password,
            nextEmail: currentEmail,
            systemMessage: translateAuthError(errorMsg, emailExists: false),
            shouldClearInput: false,
            emailExists: false,
          );
        }
      }
    }
  }
}

