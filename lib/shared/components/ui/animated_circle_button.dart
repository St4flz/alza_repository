import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';

class PulsingCircleButton extends StatefulWidget {
  final VoidCallback onTap;
  final double size;
  final Color? borderColor;

  const PulsingCircleButton({
    super.key,
    required this.onTap,
    this.size = 50.0,
    this.borderColor,
  });

  @override
  State<PulsingCircleButton> createState() => _PulsingCircleButtonState();
}

class _PulsingCircleButtonState extends State<PulsingCircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.2,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.borderColor ?? AppColors.negro.withOpacity(0.1);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo animado (efecto de pulso)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: effectiveColor, width: 2),
                      ),
                    ),
                  ),
                );
              },
            ),
            // Círculo estático principal
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: effectiveColor, width: 2),
                color: Colors.transparent, // Transparente como solicitaste
              ),
            ),
          ],
        ),
      ),
    );
  }
}
