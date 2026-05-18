import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';

class MovementItemPlaceholder extends StatelessWidget {
  const MovementItemPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 0, 0, 0),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.negro.withOpacity(0.3),
          width: 1.5,
          style: BorderStyle
              .solid, // Using solid border as dashed requires extra logic/package
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
    );
  }
}
