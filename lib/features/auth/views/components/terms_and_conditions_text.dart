import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

class TermsAndConditionsText extends StatelessWidget {
  final VoidCallback onTap;

  const TermsAndConditionsText({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: AppColors.negro.withOpacity(0.40),
          ),
          children: [
            const TextSpan(
              text: 'Al continuar, aceptas nuestros\n',
            ),
            TextSpan(
              text: 'términos y condiciones',
              style: AppFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.negro.withOpacity(0.40),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
