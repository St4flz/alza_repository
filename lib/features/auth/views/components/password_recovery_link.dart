import 'package:flutter/material.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';

class PasswordRecoveryLink extends StatelessWidget {
  final VoidCallback onTap;

  const PasswordRecoveryLink({
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
            fontStyle: FontStyle.italic,
            color: AppColors.negro.withOpacity(0.40),
          ),
          children: const [
            TextSpan(text: '¿No puedes acceder? Presiona '),
            TextSpan(
              text: 'aquí.',
              style: TextStyle(
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
