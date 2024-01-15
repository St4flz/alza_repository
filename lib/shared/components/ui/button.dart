import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Boton extends StatelessWidget {
  final String? text;
  final String? svgPath;
  final Color backgroundColor;
  final Color? contentColor;
  final TextStyle? textStyle;
  final VoidCallback onPressed;

  // Opciones extra para maquetación exacta
  final double? width;
  final double? height;
  final double? paddingLeftText;
  final double? spacing;
  final double? svgSize;

  const Boton({
    super.key,
    this.text,
    this.svgPath,
    required this.backgroundColor,
    this.contentColor,
    this.textStyle,
    required this.onPressed,
    this.width,
    this.height,
    this.paddingLeftText,
    this.spacing,
    this.svgSize = 24,
  }) : assert(text != null || svgPath != null, 'Debe proveer texto o svgPath');

  @override
  Widget build(BuildContext context) {
    // Si hay parámetros específicos de layout como padding o spacing,
    // forzamos el alineamiento customizado
    final customLayout = paddingLeftText != null || spacing != null;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: customLayout
          ? MainAxisAlignment.start
          : MainAxisAlignment.center,
      children: [
        if (text != null)
          Padding(
            padding: EdgeInsets.only(left: paddingLeftText ?? 0),
            child: Text(text!, style: textStyle),
          ),
        if (text != null && svgPath != null) SizedBox(width: spacing ?? 12),
        if (svgPath != null)
          SvgPicture.asset(
            svgPath!,
            width: svgSize,
            height: svgSize,
            colorFilter: contentColor != null
                ? ColorFilter.mode(contentColor!, BlendMode.srcIn)
                : null,
          ),
      ],
    );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          padding: customLayout
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: buttonContent,
      ),
    );
  }
}
