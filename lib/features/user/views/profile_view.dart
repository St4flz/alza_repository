import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Estilos de la app
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

// Componentes compartidos
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/shared/components/ui/button.dart';
import 'package:alza/shared/components/ui/text_box.dart';

// Providers y componentes específicos
import 'package:alza/features/auth/providers/auth_provider.dart';
import 'package:alza/features/auth/views/components/system_message_banner.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();

  String _systemMessage = 'Edita tus datos de perfil';
  bool _isSuccess = false;
  String _avatarPreviewUrl = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load initial values from provider profile
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profile = authProvider.profile;
    
    if (profile != null) {
      _usernameController.text = profile['username'] ?? '';
      _fullNameController.text = profile['full_name'] ?? '';
      _avatarUrlController.text = profile['avatar_url'] ?? '';
      _avatarPreviewUrl = profile['avatar_url'] ?? '';
    }

    _avatarUrlController.addListener(_onAvatarUrlChanged);
  }

  void _onAvatarUrlChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _avatarPreviewUrl = _avatarUrlController.text.trim();
        });
      }
    });
  }

  @override
  void dispose() {
    _avatarUrlController.removeListener(_onAvatarUrlChanged);
    _usernameController.dispose();
    _fullNameController.dispose();
    _avatarUrlController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _changeMessage(String newMessage) {
    if (mounted) {
      setState(() {
        _systemMessage = newMessage;
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final avatarUrl = _avatarUrlController.text.trim();

    if (username.isEmpty) {
      _changeMessage('El nombre de usuario no puede estar vacío.');
      return;
    }

    _changeMessage('Guardando cambios en el perfil...');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    debugPrint('[PROFILE VIEW] Guardando perfil: username="$username", fullName="$fullName", avatarUrl="$avatarUrl"');
    final success = await authProvider.updateProfile(
      username: username,
      fullName: fullName,
      avatarUrl: avatarUrl,
    );

    if (success) {
      setState(() {
        _isSuccess = true;
      });
      _changeMessage('¡Perfil actualizado con éxito!');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/home');
        }
      });
    } else {
      _changeMessage(authProvider.errorMessage ?? 'Error al actualizar perfil');
    }
  }

  Future<void> _handleDeleteAccount() async {
    // Show a styled dialog to double check
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.negro.solid,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
          ),
          title: Text(
            '¿Eliminar tu cuenta?',
            style: AppFonts.montserrat(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Esta acción es permanente. Se borrarán todas tus billeteras, transacciones, datos y tu cuenta de autenticación de Supabase de forma definitiva.',
            style: AppFonts.montserrat(
              color: AppColors.blanco.solid,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancelar',
                style: AppFonts.montserrat(
                  color: AppColors.blanco.withOpacity(0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Eliminar',
                style: AppFonts.montserrat(
                  color: AppColors.blanco.solid,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (!mounted) return;
      _changeMessage('Eliminando cuenta y todos los datos...');
      debugPrint('[PROFILE VIEW] Iniciando eliminación de cuenta confirmada por el usuario.');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.deleteAccount();
      
      if (success) {
        debugPrint('[PROFILE VIEW] Cuenta eliminada con éxito. Redirigiendo a pantalla de login...');
        if (mounted) {
          context.go('/login');
        }
      } else {
        _changeMessage(authProvider.errorMessage ?? 'Error al eliminar cuenta. Inténtalo de nuevo.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double horizontalPadding = (screenWidth * 0.1).clamp(24.0, 41.0);
    final double bottomPadding = (screenHeight * 0.08).clamp(40.0, 100.0);

    // Spacing entre elementos
    final double dynamicSpacing = (screenHeight * 0.04).clamp(16.0, 40.0);

    // Ancho responsivo de campos y botones
    final double elementWidth = (screenWidth - 2 * horizontalPadding).clamp(
      280.0,
      329.0,
    );

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.negro.solid),
            onPressed: () => context.go('/home'),
          ),
          title: Text(
            'Mi Perfil',
            style: AppFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.negro.solid,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                top: 10,
                bottom: bottomPadding,
                left: horizontalPadding,
                right: horizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Previsualización dinámica de Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.verde.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.verde.solid.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.negro.solid.withOpacity(0.08),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _avatarPreviewUrl.startsWith('http')
                              ? Image.network(
                                  _avatarPreviewUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.verde.solid,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.verde.solid,
                                ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: dynamicSpacing),

                  // Campo Nombre de Usuario
                  CajaTexto(
                    width: elementWidth,
                    height: 49,
                    controller: _usernameController,
                    hintText: "Nombre de usuario *",
                    backgroundColor: AppColors.negro.withOpacity(0.80),
                    hintStyle: AppFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: AppColors.blanco.withOpacity(0.40),
                    ),
                    textStyle: AppFonts.verdanaPro(
                      fontSize: 15,
                      color: AppColors.blanco.solid,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo Nombre Completo
                  CajaTexto(
                    width: elementWidth,
                    height: 49,
                    controller: _fullNameController,
                    hintText: "Nombre completo",
                    backgroundColor: AppColors.negro.withOpacity(0.80),
                    hintStyle: AppFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: AppColors.blanco.withOpacity(0.40),
                    ),
                    textStyle: AppFonts.verdanaPro(
                      fontSize: 15,
                      color: AppColors.blanco.solid,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo URL de Avatar
                  CajaTexto(
                    width: elementWidth,
                    height: 49,
                    controller: _avatarUrlController,
                    hintText: "URL del avatar (imagen)",
                    backgroundColor: AppColors.negro.withOpacity(0.80),
                    hintStyle: AppFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: AppColors.blanco.withOpacity(0.40),
                    ),
                    textStyle: AppFonts.verdanaPro(
                      fontSize: 14,
                      color: AppColors.blanco.solid,
                    ),
                  ),

                  SizedBox(height: dynamicSpacing),

                  // Banner de Mensaje del Sistema
                  SystemMessageBanner(
                    message: _systemMessage,
                    width: elementWidth,
                  ),

                  SizedBox(height: dynamicSpacing),

                  // Botón Guardar Cambios
                  Boton(
                    width: elementWidth,
                    height: 49,
                    text: _isSuccess ? '¡Guardado!' : 'Guardar Cambios',
                    backgroundColor: _isSuccess ? AppColors.verde.solid : AppColors.negro.solid,
                    textStyle: AppFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blanco.solid,
                    ),
                    onPressed: authProvider.isLoading ? () {} : _handleSaveProfile,
                  ),

                  const SizedBox(height: 24),

                  // Botón Eliminar Cuenta
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onPressed: authProvider.isLoading ? null : _handleDeleteAccount,
                    icon: const Icon(Icons.delete_forever_rounded, size: 20),
                    label: Text(
                      'Eliminar Cuenta',
                      style: AppFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
