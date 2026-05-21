import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:go_router/go_router.dart';

class InitialView extends StatefulWidget {
  const InitialView({super.key});

  @override
  State<InitialView> createState() => _InitialViewState();
}

class _InitialViewState extends State<InitialView> {
  @override
  void initState() {
    super.initState();
    // Ejecuta la redirección inmediatamente después de renderizar el primer frame.
    // Aquí es donde en el futuro se pueden añadir llamadas de precarga/inicialización.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final router = GoRouter.of(context);
        final currentPath = router.routerDelegate.currentConfiguration.uri.path;
        if (currentPath == '/' || currentPath == '/initial') {
          context.go('/home');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text(
            'Alza+',
            style: AppFonts.verdanaPro(
              fontSize: 70,
              fontWeight: FontWeight.w700,
              color: AppColors.verde.solid,
            ),
          ),
        ),
      ),
    );
  }
}
