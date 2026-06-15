import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:alza/features/auth/services/auth_service.dart';
import 'package:alza/core/network/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  User? get currentUser => _authService.currentUser;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  bool _loadingProfile = false;
  bool get loadingProfile => _loadingProfile;

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

  Future<void> loadProfile() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('[PROFILE DEB] loadProfile: No hay usuario autenticado.');
      _profile = null;
      notifyListeners();
      return;
    }
    
    debugPrint('[PROFILE DEB] loadProfile: Cargando perfil para user_id: ${user.id}');
    _loadingProfile = true;
    notifyListeners();
    
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
          
      debugPrint('[PROFILE DEB] loadProfile: Resultado de la consulta: $data');
      if (data == null) {
        debugPrint('[PROFILE DEB] loadProfile: El perfil no existe. Creando uno por defecto...');
        final newProfile = {
          'id': user.id,
          'email': user.email ?? '',
          'full_name': user.userMetadata?['full_name'] ?? '',
          'avatar_url': user.userMetadata?['avatar_url'] ?? '',
          'username': '',
        };
        await Supabase.instance.client.from('profiles').insert(newProfile);
        _profile = newProfile;
        debugPrint('[PROFILE DEB] loadProfile: Perfil por defecto creado e insertado.');
      } else {
        _profile = data;
      }
    } catch (e) {
      debugPrint('[PROFILE DEB] ERROR al cargar perfil: $e');
    } finally {
      _loadingProfile = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? username,
    String? fullName,
    String? avatarUrl,
  }) async {
    final user = currentUser;
    if (user == null) {
      debugPrint('[PROFILE DEB] updateProfile: No hay usuario autenticado.');
      return false;
    }
    
    debugPrint('[PROFILE DEB] updateProfile: Iniciando actualización para user_id: ${user.id}');
    debugPrint('  - username: $username, fullName: $fullName, avatarUrl: $avatarUrl');
    
    try {
      _setLoading(true);
      final updates = <String, dynamic>{};
      if (username != null) updates['username'] = username;
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      
      await Supabase.instance.client.from('profiles').update(updates).eq('id', user.id);
      debugPrint('[PROFILE DEB] updateProfile: Perfil actualizado en Supabase exitosamente.');
      
      // Reload local profile state
      await loadProfile();
      return true;
    } catch (e) {
      debugPrint('[PROFILE DEB] ERROR al actualizar perfil: $e');
      _setMessage(error: 'Error al actualizar el perfil: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAccount() async {
    final user = currentUser;
    if (user == null) {
      debugPrint('[DELETE ACCOUNT DEB] deleteAccount: No hay usuario autenticado.');
      return false;
    }
    
    debugPrint('[DELETE ACCOUNT DEB] deleteAccount: Solicitando eliminación para user_id: ${user.id}');
    
    try {
      _setLoading(true);
      clearMessages();
      
      final response = await _apiService.deleteUserAccount();
      debugPrint('[DELETE ACCOUNT DEB] Respuesta del backend: success=${response.success}, message=${response.message}');
      
      if (response.success) {
        _setMessage(success: response.message);
        debugPrint('[DELETE ACCOUNT DEB] Cuenta eliminada con éxito en backend. Cerrando sesión local...');
        // Cerrar sesión localmente en Supabase
        await _authService.signOut();
        _profile = null;
        notifyListeners();
        return true;
      } else {
        debugPrint('[DELETE ACCOUNT DEB] ERROR: El backend reportó falla en eliminación: ${response.message}');
        _setMessage(error: response.message);
        return false;
      }
    } catch (e) {
      debugPrint('[DELETE ACCOUNT DEB] ERROR: Excepción durante el proceso de eliminación: $e');
      _setMessage(error: 'Excepción al eliminar cuenta: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
