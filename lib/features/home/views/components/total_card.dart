import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';

class GrandTotalCard extends StatelessWidget {
  final String amount;
  final String title;

  const GrandTotalCard({
    super.key,
    required this.amount,
    this.title = 'Gran total',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.negro.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.negro.solid,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                Icons.visibility_outlined,
                color: AppColors.blanco.solid,
                size: 20,
              ),
              Text(
                amount,
                style: TextStyle(
                  color: AppColors.verde.solid,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '\$',
                style: TextStyle(
                  color: AppColors.blanco.solid,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
