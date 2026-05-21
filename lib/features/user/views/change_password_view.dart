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

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _systemMessage = 'Digita tu nueva contraseña';
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changeMessage(String newMessage) {
    if (mounted) {
      setState(() {
        _systemMessage = newMessage;
      });
    }
  }

  Future<void> _handleUpdatePassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      _changeMessage("Por favor, completa ambos campos");
      return;
    }

    if (password.length < 6) {
      _changeMessage("La contraseña debe tener al menos 6 caracteres");
      return;
    }

    if (password != confirmPassword) {
      _changeMessage("Las contraseñas no coinciden");
      return;
    }

    _changeMessage("Actualizando contraseña...");

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.updatePassword(password);

    if (success) {
      setState(() {
        _isSuccess = true;
      });
      _changeMessage("¡Contraseña actualizada con éxito!");
      
      // Esperar 2 segundos y redirigir al Home de la aplicación
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/home');
        }
      });
    } else {
      _changeMessage(authProvider.errorMessage ?? "Error al actualizar contraseña");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double horizontalPadding = (screenWidth * 0.1).clamp(24.0, 41.0);
    final double verticalPadding = (screenHeight * 0.15).clamp(60.0, 140.0);

    // Spacing entre elementos
    final double dynamicSpacing = (screenHeight * 0.05).clamp(20.0, 50.0);

    // Ancho responsivo de campos y botones
    final double elementWidth = (screenWidth - 2 * horizontalPadding).clamp(
      280.0,
      329.0,
    );

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: verticalPadding,
              bottom: verticalPadding,
              left: horizontalPadding,
              right: horizontalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Alza+',
                  style: AppFonts.verdanaPro(
                    fontSize: 60,
                    fontWeight: FontWeight.w700,
                    color: AppColors.verde.solid,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                Text(
                  'Recuperar Cuenta',
                  style: AppFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.negro.solid,
                  ),
                ),

                SizedBox(height: dynamicSpacing),

                // Campo Nueva Contraseña
                CajaTexto(
                  width: elementWidth,
                  height: 49,
                  controller: _passwordController,
                  obscureText: true,
                  hintText: "Nueva contraseña",
                  backgroundColor: AppColors.negro.withOpacity(0.80),
                  hintStyle: AppFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.blanco.withOpacity(0.40),
                  ),
                  textStyle: AppFonts.verdanaPro(
                    fontSize: 16,
                    color: AppColors.blanco.solid,
                  ),
                ),

                const SizedBox(height: 16),

                // Campo Confirmar Contraseña
                CajaTexto(
                  width: elementWidth,
                  height: 49,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  hintText: "Confirmar contraseña",
                  backgroundColor: AppColors.negro.withOpacity(0.80),
                  hintStyle: AppFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.blanco.withOpacity(0.40),
                  ),
                  textStyle: AppFonts.verdanaPro(
                    fontSize: 16,
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

                // Botón de Actualizar Contraseña
                if (!_isSuccess)
                  Boton(
                    width: elementWidth,
                    height: 49,
                    text: 'Actualizar Contraseña',
                    backgroundColor: AppColors.negro.solid,
                    textStyle: AppFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blanco.solid,
                    ),
                    onPressed: authProvider.isLoading ? () {} : _handleUpdatePassword,
                  )
                else
                  Boton(
                    width: elementWidth,
                    height: 49,
                    text: 'Ir al Inicio',
                    backgroundColor: AppColors.verde.solid,
                    textStyle: AppFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blanco.solid,
                    ),
                    onPressed: () => context.go('/home'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
