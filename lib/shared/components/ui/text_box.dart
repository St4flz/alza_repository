import 'package:flutter/material.dart';
import 'package:alza/app/style/app_fonts.dart';

class CajaTexto extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Color backgroundColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Widget? suffixIcon;
  final double? width;
  final double? height;

  const CajaTexto({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    required this.backgroundColor,
    this.hintStyle,
    this.textStyle,
    this.suffixIcon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: textStyle ?? AppFonts.verdanaPro(fontSize: 16),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          filled: true,
          fillColor: backgroundColor,
          contentPadding: const EdgeInsets.only(left: 26, right: 16),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white24, width: 1),
          ),
        ),
      ),
    );
  }
}
