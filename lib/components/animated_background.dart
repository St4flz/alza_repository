import 'package:flutter/material.dart';
import 'package:alza/theme/app_colors.dart';

/// Un componente que consume la variable global "tema" y muestra un fondo
/// con gradiente radial animado ("adentro hacia afuera").
class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Controlador de animación que se repite constantemente
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, childWidget) {
        // Animamos el radio para que parezca que el gradiente se expande
        // y se contrae de adentro hacia afuera de forma continua.
        final currentRadius =
            0.6 + (_controller.value * 0.8); // Varía de 0.6 a 1.4

        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [AppColors.cian.solid, AppColors.blanco.solid],
              center: Alignment.center,
              radius: currentRadius,
            ),
          ),
          // Ponemos el contenido de la app encima del fondo animado
          child: childWidget,
        );
      },
      child: widget
          .child, // Pasamos el child para que no se reconstruya en cada frame animado
    );
  }
}
