import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/shared/components/ui/button.dart';
import 'package:alza/shared/components/ui/text_box.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';
import 'package:alza/features/auth/hooks/use_login.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  AuthStep _currentStep = AuthStep.email;
  String _email = '';
  bool _emailExists = false;

  String _systemMessage = 'Bienvenido';
  late AnimationController _lineAnimationController;
  late Animation<double> _lineWidthAnimation;

  @override
  void initState() {
    super.initState();

    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _lineWidthAnimation = Tween<double>(begin: 40.0, end: 180.0).animate(
      CurvedAnimation(parent: _lineAnimationController, curve: Curves.easeOut),
    );

    _triggerMessageAnimation();
  }

  void _triggerMessageAnimation() {
    _lineAnimationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _lineAnimationController.reverse();
      });
    });
  }

  void _changeMessage(String newMessage) {
    if (mounted) {
      setState(() {
        _systemMessage = newMessage;
      });
      _triggerMessageAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineAnimationController.dispose();
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

    if (result.shouldRedirect) {
      if (mounted) {
        context.go('/home');
      }
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
                      : IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color: AppColors.blanco.withOpacity(0.40),
                          ),
                          onPressed: _handleNext,
                        ),
                ),

                SizedBox(height: dynamicSpacing),

                Container(
                  constraints: const BoxConstraints(minHeight: 60),
                  width: elementWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _systemMessage,
                        style: AppFonts.verdanaPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.azul.solid,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: _lineAnimationController,
                        builder: (context, child) {
                          return Container(
                            height: 3,
                            width: _lineWidthAnimation.value,
                            color: AppColors.azul.solid,
                          );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: dynamicSpacing),

                GestureDetector(
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
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                        color: AppColors.negro.withOpacity(0.40),
                      ),
                      children: const [
                        TextSpan(text: '¿No puedes acceder? Presiona '),
                        TextSpan(
                          text: 'aquí.',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_currentStep == AuthStep.password) ...[
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentStep = AuthStep.email;
                        _controller.clear();
                        _email = '';
                      });
                      _changeMessage("Digita tu correo");
                    },
                    child: Text(
                      'Cambiar correo',
                      style: AppFonts.montserrat(
                        fontSize: 13,
                        color: AppColors.azul.solid,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                SizedBox(height: dynamicSpacing),

                GestureDetector(
                  onTap: () {
                    _changeMessage("Términos y condiciones");
                  },
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: AppColors.negro.withOpacity(0.40),
                      ),
                      children: [
                        const TextSpan(
                          text: 'Al continuar, aceptas nuestros\n',
                        ),
                        TextSpan(
                          text: 'términos y condiciones',
                          style: AppFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.negro.withOpacity(0.40),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
