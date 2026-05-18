import 'package:flutter/material.dart';
import 'package:alza/theme/app_colors.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.negro.withOpacity(0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Icon(
          Icons.arrow_forward,
          color: AppColors.verde.solid,
          size: 20,
        ),
      ],
    );
  }
}
