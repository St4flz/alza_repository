import 'package:flutter/material.dart';
import 'package:alza/theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.person, color: AppColors.negro.solid, size: 28),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home, color: AppColors.negro.solid, size: 28),
              const SizedBox(height: 4),
              Container(width: 24, height: 3, color: AppColors.verde.solid),
            ],
          ),
          const SizedBox(width: 48), // Space for FAB
          Icon(Icons.edit_document, color: AppColors.negro.solid, size: 28),
          Icon(Icons.settings, color: AppColors.negro.solid, size: 28),
        ],
      ),
    );
  }
}
