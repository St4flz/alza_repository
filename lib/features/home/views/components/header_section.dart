import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/shared/components/ui/animated_circle_button.dart';

class HeaderSection extends StatelessWidget {
  final VoidCallback? onTap;
  final String? userName;

  const HeaderSection({super.key, this.onTap, this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Stack(
          alignment: Alignment.center,
          children: [
            // Animated pulsing circle button
            PulsingCircleButton(
              size: 50,
              borderColor: AppColors.negro.withOpacity(0.05),
              onTap:
                  onTap ??
                  () {
                    print("Botón pulsado!");
                  },
            ),
            Text(
              userName != null
                  ? 'Hola ${userName!.split('@').first}, ya esta listo tu\nreporte semanal.'
                  : 'Hola, ya esta listo tu reporte\nsemanal.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.azul.solid,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(width: 200, height: 2, color: AppColors.azul.solid),
      ],
    );
  }
}
