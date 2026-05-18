import 'package:flutter/material.dart';
import 'package:alza/theme/app_colors.dart';
import 'package:alza/components/pulsing_circle_button.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

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
              onTap: () {
                // TODO: Pasa aquí el redirect como parámetro
                print("Botón pulsado!");
              },
            ),
            Text(
              'Hola, ya esta listo tu reporte\nsemanal.',
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
        Container(
          width: 200,
          height: 2,
          color: AppColors.azul.solid,
        ),
      ],
    );
  }
}
