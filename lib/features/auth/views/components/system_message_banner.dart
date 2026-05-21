import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

class SystemMessageBanner extends StatefulWidget {
  final String message;
  final double width;

  const SystemMessageBanner({
    super.key,
    required this.message,
    required this.width,
  });

  @override
  State<SystemMessageBanner> createState() => _SystemMessageBannerState();
}

class _SystemMessageBannerState extends State<SystemMessageBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(begin: 40.0, end: 180.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _triggerAnimation();
  }

  @override
  void didUpdateWidget(covariant SystemMessageBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _triggerAnimation();
    }
  }

  void _triggerAnimation() {
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _controller.reverse();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message,
            style: AppFonts.verdanaPro(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.azul.solid,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                height: 3,
                width: _widthAnimation.value,
                color: AppColors.azul.solid,
              );
            },
          ),
        ],
      ),
    );
  }
}
