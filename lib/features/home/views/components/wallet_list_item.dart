import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

class WalletListItem extends StatelessWidget {
  final String title;
  final String balanceText;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback? onTap;

  const WalletListItem({
    super.key,
    required this.title,
    required this.balanceText,
    required this.icon,
    this.isActive = false,
    this.activeColor = const Color(0xFF00D764),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color contentColor = isActive ? AppColors.verde.solid : AppColors.blanco.solid;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.negro.solid,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.negro.solid.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: contentColor,
                      size: 38,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: AppFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: contentColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            balanceText,
                            style: AppFonts.montserrat(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: AppColors.blanco.solid.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildConcentricIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildConcentricIndicator() {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.verde.solid.withOpacity(0.12),
      ),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.verde.solid.withOpacity(0.18),
        ),
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF6B7280) : AppColors.blanco.solid,
            border: Border.all(
              color: AppColors.verde.solid.withOpacity(0.4),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
