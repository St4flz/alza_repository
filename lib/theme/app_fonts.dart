import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFonts {
  AppFonts._();

  /// Montserrat - Soporta todos los pesos
  /// Se obtiene dinámicamente mediante el paquete google_fonts
  static TextStyle montserrat({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.montserrat(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Verdana Pro - 3 pesos (Ej: Light, Regular, Bold)
  /// Al ser una fuente comercial, debes agregar los archivos de fuente (.ttf u .otf)
  /// en tu proyecto y registrarlos en tu pubspec.yaml bajo la familia 'VerdanaPro'.
  static TextStyle verdanaPro({
    double? fontSize,
    FontWeight? fontWeight, // Recomiendo usar FontWeight.w300, w400 y w700
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'VerdanaPro',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
