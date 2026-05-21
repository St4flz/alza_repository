import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; // Para debugPrint

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges {
    debugPrint('AuthService: Escuchando cambios de estado de autenticación');
    return _client.auth.onAuthStateChange;
  }

  User? get currentUser {
    final user = _client.auth.currentUser;
    debugPrint(
      'AuthService: Usuario actual solicitado -> ${user?.email ?? "Ninguno"}',
    );
    return user;
  }

  Future<AuthResponse> signInWithPassword(String email, String password) async {
    debugPrint('AuthService: Intentando iniciar sesión con correo: $email');
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(String email, String password) async {
    debugPrint('AuthService: Intentando registrar usuario con correo: $email');
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<bool> signInWithGoogle() async {
    debugPrint('AuthService: Iniciando flujo OAuth con Google');
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'alza://login-callback',
    );
  }

  Future<void> signOut() async {
    debugPrint('AuthService: Cerrando sesión...');
    await _client.auth.signOut();
    debugPrint('AuthService: Sesión cerrada exitosamente');
  }

  Future<void> resetPasswordForEmail(String email) async {
    debugPrint(
      'AuthService: Solicitando recuperación de contraseña para: $email',
    );
    await _client.auth.resetPasswordForEmail(email);
    debugPrint('AuthService: Correo de recuperación enviado');
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      debugPrint('AuthService: Verificando si el correo existe: $email');
      final response = await _client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint('AuthService: Error al verificar correo: $e');
      return false;
    }
  }
}
