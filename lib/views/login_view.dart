import 'dart:async';
import 'package:flutter/material.dart';
import 'package:alza/theme/app_colors.dart';
import 'package:alza/theme/app_fonts.dart';
import 'package:alza/components/animated_background.dart';
import 'package:alza/components/boton.dart';
import 'package:alza/components/caja_texto.dart';
import 'package:alza/utils/mensaje.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final List<String> _placeholders = [
    "Digita tu credencial",
    "Digita tu contraseña",
    "Crea una contraseña"
  ];
  int _placeholderIndex = 0;
  late Timer _placeholderTimer;

  String _systemMessage = 'Bienvenido';
  late AnimationController _lineAnimationController;
  late Animation<double> _lineWidthAnimation;

  @override
  void initState() {
    super.initState();
    
    // Timer para alternar los placeholders
    _placeholderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _placeholderIndex = (_placeholderIndex + 1) % _placeholders.length;
        });
      }
    });

    // Animación de la línea azul
    _lineAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Inicia en 0 (o tamaño pequeño) y crece a un tamaño mayor hacia los lados
    _lineWidthAnimation = Tween<double>(begin: 40.0, end: 180.0).animate(
      CurvedAnimation(parent: _lineAnimationController, curve: Curves.easeOut),
    );
    
    // Mostrar la animación en el primer render
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
    setState(() {
      _systemMessage = newMessage;
    });
    _triggerMessageAnimation();
  }

  @override
  void dispose() {
    _placeholderTimer.cancel();
    _lineAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                // 1. Título
                Text(
                  'Alza+',
                  style: AppFonts.verdanaPro(
                    fontSize: 70,
                    fontWeight: FontWeight.w700,
                    color: AppColors.verde.solid,
                  ),
                ),
                
                const SizedBox(height: 70),
                
                // 2. Botón Google
                Boton(
                  width: 329,
                  height: 49,
                  text: 'Continuar con',
                  svgPath: 'assets/google.svg',
                  paddingLeftText: 26,
                  spacing: 100, // Espacio exacto requerido entre el texto y el logo
                  svgSize: 20,
                  backgroundColor: AppColors.negro.solid,
                  contentColor: Colors.white, 
                  textStyle: AppFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.blanco.withOpacity(0.40),
                  ),
                  onPressed: () {
                    mostrarMensaje(context, "boton google");
                  },
                ),
                
                const SizedBox(height: 70),
                
                // 3. Caja de texto con flecha
                CajaTexto(
                  width: 329,
                  height: 49,
                  hintText: _placeholders[_placeholderIndex],
                  backgroundColor: AppColors.negro.withOpacity(0.80),
                  hintStyle: AppFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.normal,
                    color: AppColors.blanco.withOpacity(0.40),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.arrow_forward, 
                      color: AppColors.blanco.withOpacity(0.40),
                    ),
                    onPressed: () {
                      mostrarMensaje(context, "flecha dentro caja de texto");
                      _changeMessage("Credencial validada");
                    },
                  ),
                ),
                
                const SizedBox(height: 70),
                
                // 4. Área de Mensajes Dinámicos
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
                      // Línea animable
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
                
                // 5. Enlace "No puedes acceder"
                GestureDetector(
                  onTap: () {
                    mostrarMensaje(context, "presiona aqui");
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
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 70),
                
                // 6. Términos y Condiciones
                GestureDetector(
                  onTap: () {
                    mostrarMensaje(context, "terminos y condiciones");
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
                        const TextSpan(text: 'Al continuar, aceptas nuestros\n'),
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
