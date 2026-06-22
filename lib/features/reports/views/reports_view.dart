import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blanco.solid,
      appBar: AppBar(
        title: Text(
          'Reportes',
          style: AppFonts.montserrat(
            color: AppColors.negro.solid,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.blanco.solid,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.negro.solid),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 80, color: AppColors.verde.solid),
            const SizedBox(height: 16),
            Text(
              'Coming soon...',
              style: AppFonts.montserrat(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.negro.solid,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tus reportes financieros estarán aquí muy pronto.',
              style: AppFonts.montserrat(
                fontSize: 14,
                color: AppColors.negro.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
