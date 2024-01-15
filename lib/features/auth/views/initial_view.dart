import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:go_router/go_router.dart';

class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  State<InitialView> createState() => _SplashViewState();
}

class _SplashViewState extends State<InitialView> {
  bool _showText = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _showText = !_showText;
        });
      }
    });

    // Delega el flujo de sesión completamente a las guardas de GoRouter
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/home');
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
                    'assets/icons/svg/logo.svg',
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
      ),
    );
  }
}
