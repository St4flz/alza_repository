import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    this.onPersonTap,
    this.onHomeTap,
    this.onDocumentTap,
    this.onSettingsTap,
  });

  final VoidCallback? onPersonTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onDocumentTap;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.blanco.solid,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.negro.solid.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPersonTap ?? () {},
                  icon: Icon(Icons.person, color: AppColors.negro.solid, size: 28),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onHomeTap ?? () {},
                      icon: Icon(Icons.home, color: AppColors.negro.solid, size: 28),
                    ),
                    const SizedBox(height: 4),
                    Container(width: 24, height: 3, color: AppColors.verde.solid),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onDocumentTap ?? () {},
                  icon: Icon(Icons.edit_document, color: AppColors.negro.solid, size: 28),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: onSettingsTap ?? () {},
                  icon: Icon(Icons.settings, color: AppColors.negro.solid, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
