import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:alza/theme/app_colors.dart';
import 'package:alza/theme/app_fonts.dart';
import 'package:alza/components/animated_background.dart';
import 'package:alza/components/boton.dart';
import 'package:alza/components/caja_texto.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';

enum AuthStep { email, password }

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

    if (_currentStep == AuthStep.email) {
      if (!text.contains('@')) {
        _changeMessage("Correo inválido");
        return;
      }
      setState(() {
        _email = text;
        _currentStep = AuthStep.password;
        _controller.clear();
      });
      _changeMessage("Ingresa tu contraseña");
    } else {
      // Step password
      final password = text;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      _changeMessage("Validando...");

      // Intentamos login primero
      bool success = await authProvider.signIn(_email, password);

      if (success) {
        _changeMessage("Inicio exitoso");
        if (mounted) context.go('/home');
      } else {
        // Si falló, podría ser contraseña incorrecta o usuario no existe.
        // Intentamos registrar
        final errorMsg = authProvider.errorMessage ?? '';
        if (errorMsg.toLowerCase().contains("invalid login credentials")) {
          _changeMessage("Creando cuenta...");
          bool registered = await authProvider.signUp(_email, password);
          if (registered) {
            _changeMessage("Registro exitoso. Revisa tu correo.");
            setState(() {
              _currentStep = AuthStep.email;
              _controller.clear();
              _email = '';
            });
          } else {
            // Si el registro falló, el usuario ya existía y puso mal la contraseña (o ingresó con Google previamente sin password)
            if ((authProvider.errorMessage ?? '').toLowerCase().contains(
              "already registered",
            )) {
              _changeMessage(
                "Credenciales inválidas. Usa Google o recupera la contraseña.",
              );
            } else {
              _changeMessage(authProvider.errorMessage ?? "Error de registro");
            }
          }
        } else {
          _changeMessage(errorMsg);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 140,
              bottom: 140,
              left: 41,
              right: 41,
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

                const SizedBox(height: 70),

                Boton(
                  width: 329,
                  height: 49,
                  text: 'Continuar con',
                  svgPath: 'assets/google.svg',
                  spacing: 100,
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

                const SizedBox(height: 70),

                CajaTexto(
                  width: 329,
                  height: 49,
                  controller: _controller,
                  obscureText: _currentStep == AuthStep.password,
                  hintText: _currentStep == AuthStep.email
                      ? "Digita tu correo"
                      : "Digita tu contraseña",
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

                const SizedBox(height: 70),

                SizedBox(
                  height: 60,
                  child: Column(
                    children: [
                      Text(
                        _systemMessage,
                        style: AppFonts.verdanaPro(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.azul.solid,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 36),
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

                const SizedBox(height: 70),

                GestureDetector(
                  onTap: () async {
                    if (_email.isEmpty) {
                      _changeMessage("Ingresa correo primero");
                    } else {
                      _changeMessage("Enviando correo...");
                      bool sent = await authProvider.resetPassword(_email);
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

                const SizedBox(height: 70),

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
