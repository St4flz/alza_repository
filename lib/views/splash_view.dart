import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:alza/theme/app_colors.dart';
import 'package:alza/theme/app_fonts.dart';
import 'package:alza/global/app_state.dart';
import 'package:alza/components/animated_background.dart';
import 'package:alza/views/login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _showText = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Intercala entre el texto y el logo cada 2.5 segundos
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() {
          _showText = !_showText;
        });
      }
    });

    // Navegar automáticamente a la vista de Login después de 5 segundos
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          // AnimatedSwitcher es ideal para transicionar suavemente (fade)
          // entre dos widgets completamente distintos.
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: _showText
                ? Text(
                    'Alza+',
                    key: const ValueKey('text'),
                    style: AppFonts.verdanaPro(
                      fontSize: 70,
                      fontWeight: FontWeight.w700,
                      color: AppColors.verde.solid,
                    ),
                  )
                : SvgPicture.asset(
                    'assets/logo.svg',
                    key: const ValueKey('logo'),
                    width: 200,
                    height: 200,
                    colorFilter: ColorFilter.mode(
                      AppColors.verde.solid,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ),
        // Mantengo el botón para que sigas pudiendo alternar el tema y ver cómo reacciona el fondo
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            tema.value = tema.value == 'claro' ? 'oscuro' : 'claro';
          },
          backgroundColor: AppColors.verde.solid,
          child: const Icon(Icons.brightness_6, color: Colors.white),
        ),
      ),
    );
  }
}
