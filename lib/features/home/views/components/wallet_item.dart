import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';

class WalletItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;

  const WalletItem({
    super.key,
    required this.title,
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: AppColors.negro.solid,
              borderRadius: BorderRadius.circular(20),
              border: isActive
                  ? Border.all(color: AppColors.verde.solid, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.verde.solid : AppColors.blanco.solid,
              size: 36,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: AppColors.negro.withOpacity(0.4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
