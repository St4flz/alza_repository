import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:alza/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  User? get currentUser => _authService.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setMessage({String? error, String? success}) {
    if (error != null) debugPrint('AuthProvider Error: $error');
    if (success != null) debugPrint('AuthProvider Success: $success');
    _errorMessage = error;
    _successMessage = success;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      debugPrint('AuthProvider: Ejecutando signIn');
      _setLoading(true);
      clearMessages();
      await _authService.signInWithPassword(email, password);
      _setMessage(success: 'Inicio de sesión exitoso');
      return true;
    } on AuthException catch (e) {
      _setMessage(error: e.message);
      return false;
    } catch (e) {
      _setMessage(error: 'Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      debugPrint('AuthProvider: Ejecutando signUp');
      _setLoading(true);
      clearMessages();
      await _authService.signUp(email, password);
      _setMessage(success: 'Registro exitoso. Revisa tu correo.');
      return true;
    } on AuthException catch (e) {
      _setMessage(error: e.message);
      return false;
    } catch (e) {
      _setMessage(error: 'Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      debugPrint('AuthProvider: Ejecutando signInWithGoogle');
      _setLoading(true);
      clearMessages();
      return await _authService.signInWithGoogle();
    } on AuthException catch (e) {
      _setMessage(error: e.message);
      return false;
    } catch (e) {
      _setMessage(error: 'Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('AuthProvider: Ejecutando signOut');
      _setLoading(true);
      await _authService.signOut();
    } catch (e) {
      _setMessage(error: 'Error al cerrar sesión: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      debugPrint('AuthProvider: Ejecutando resetPassword');
      _setLoading(true);
      clearMessages();
      const redirectTo = kIsWeb ? null : 'alza://reset-password';
      await _authService.resetPasswordForEmail(email, redirectTo: redirectTo);
      _setMessage(success: 'Correo de recuperación enviado');
      return true;
    } on AuthException catch (e) {
      _setMessage(error: e.message);
      return false;
    } catch (e) {
      _setMessage(error: 'Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      debugPrint('AuthProvider: Ejecutando updatePassword');
      _setLoading(true);
      clearMessages();
      await _authService.updatePassword(newPassword);
      _setMessage(success: 'Contraseña actualizada correctamente');
      return true;
    } on AuthException catch (e) {
      _setMessage(error: e.message);
      return false;
    } catch (e) {
      _setMessage(error: 'Error inesperado: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      _setLoading(true);
      clearMessages();
      return await _authService.checkEmailExists(email);
    } catch (e) {
      _setMessage(error: 'Error al buscar el correo');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
