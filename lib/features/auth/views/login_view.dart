//Imports de estilos
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

//Imports de componentes
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/shared/components/ui/button.dart';
import 'package:alza/shared/components/ui/text_box.dart';

//Imports de librerias
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

//Imports de providers
import 'package:alza/features/auth/providers/auth_provider.dart';

//Imports de hooks
import 'package:alza/features/auth/hooks/use_login.dart';

//Imports de componentes locales
import 'package:alza/features/auth/views/components/system_message_banner.dart';
import 'package:alza/features/auth/views/components/password_recovery_link.dart';
import 'package:alza/features/auth/views/components/terms_and_conditions_text.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _controller = TextEditingController();

  AuthStep _currentStep = AuthStep.email;
  String _email = '';
  bool _emailExists = false;

  String _systemMessage = 'Bienvenido';

  @override
  void initState() {
    super.initState();
  }

  void _changeMessage(String newMessage) {
    if (mounted) {
      setState(() {
        _systemMessage = newMessage;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _changeMessage("Por favor ingresa un valor");
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_currentStep == AuthStep.password) {
      _changeMessage("Validando...");
    }

    final result = await AuthHooks.handleAuthFlow(
      text: text,
      currentStep: _currentStep,
      currentEmail: _email,
      authProvider: authProvider,
      emailExists: _emailExists,
    );

    // Actualiza los estados estéticos y visuales locales
    setState(() {
      _currentStep = result.nextStep;
      _email = result.nextEmail;
      _emailExists = result.emailExists;
    });

    _changeMessage(result.systemMessage);

    if (result.shouldClearInput) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final double horizontalPadding = (screenWidth * 0.1).clamp(24.0, 41.0);
    final double verticalPadding = (screenHeight * 0.15).clamp(60.0, 140.0);

    // Spacing between elements
    final double dynamicSpacing = (screenHeight * 0.065).clamp(24.0, 70.0);

    // Responsive width of the text input and button
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
                    fontSize: 70,
                    fontWeight: FontWeight.w700,
                    color: AppColors.verde.solid,
                  ),
                ),

                SizedBox(height: dynamicSpacing),

                Boton(
                  width: elementWidth,
                  height: 49,
                  text: 'Continuar con',
                  svgPath: 'assets/icons/svg/google.svg',
                  spacing: 170,
                  svgSize: 20,
                  backgroundColor: AppColors.negro.solid,
                  textStyle: AppFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.blanco.withOpacity(0.40),
                  ),
                  onPressed: () async {
                    _changeMessage("Conectando con Google...");
                    final success = await authProvider.signInWithGoogle();
                    if (!success && mounted) {
                      _changeMessage(
                        authProvider.errorMessage ?? "Error con Google",
                      );
                    }
                  },
                ),

                SizedBox(height: dynamicSpacing),
                CajaTexto(
                  width: elementWidth,
                  height: 49,
                  controller: _controller,
                  obscureText: _currentStep == AuthStep.password,
                  hintText: _currentStep == AuthStep.email
                      ? "Digita tu correo"
                      : (_emailExists
                            ? "Escribe tu contraseña"
                            : "Crea una contraseña"),
                  backgroundColor: AppColors.negro.withOpacity(0.80),
                  hintStyle: AppFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.blanco.withOpacity(0.40),
                  ),
                  suffixIcon: authProvider.isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.blanco.withOpacity(0.40),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_currentStep == AuthStep.password)
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back,
                                  color: AppColors.blanco.withOpacity(0.40),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _currentStep = AuthStep.email;
                                    _controller.clear();
                                    _email = '';
                                  });
                                  _changeMessage("Digita tu correo");
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward,
                                color: AppColors.blanco.withOpacity(0.40),
                              ),
                              onPressed: _handleNext,
                            ),
                          ],
                        ),
                ),

                SizedBox(height: dynamicSpacing),

                SystemMessageBanner(
                  message: _systemMessage,
                  width: elementWidth,
                ),

                SizedBox(height: dynamicSpacing),

                PasswordRecoveryLink(
                  onTap: () async {
                    final emailToRecover = _email.isNotEmpty
                        ? _email
                        : _controller.text.trim();
                    if (emailToRecover.isEmpty) {
                      _changeMessage("Ingresa correo primero");
                    } else if (!emailToRecover.contains('@')) {
                      _changeMessage("Correo inválido");
                    } else {
                      _changeMessage("Enviando correo...");
                      bool sent = await authProvider.resetPassword(
                        emailToRecover,
                      );
                      if (sent) {
                        _changeMessage("Correo enviado");
                      } else {
                        _changeMessage(
                          authProvider.errorMessage ?? "Error al enviar",
                        );
                      }
                    }
                  },
                ),

                SizedBox(height: dynamicSpacing),

                TermsAndConditionsText(
                  onTap: () {
                    _changeMessage("Términos y condiciones");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
