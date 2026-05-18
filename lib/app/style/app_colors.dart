import 'package:flutter/material.dart';

class AppColorToken {
  final int _hex;

  const AppColorToken(this._hex);

  Color get solid => Color(0xFF000000 | _hex);

  Color withOpacity(double opacity) {
    assert(
      opacity >= 0.0 && opacity <= 1.0,
      'La opacidad debe estar entre 0.0 y 1.0',
    );
    final int alpha = (opacity * 255).round();
    return Color((alpha << 24) | _hex);
  }
}

class AppColors {
  AppColors._();

  static const AppColorToken verde = AppColorToken(0x00D764);
  static const AppColorToken blanco = AppColorToken(0xF8F8F6);
  static const AppColorToken negro = AppColorToken(0x1A1A17);
  static const AppColorToken cian = AppColorToken(0xF0F4FF);
  static const AppColorToken azul = AppColorToken(0x0A0B33);
}
