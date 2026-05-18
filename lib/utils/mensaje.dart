import 'package:flutter/material.dart';

void mostrarMensaje(BuildContext context, String mensaje) {
  print(mensaje);
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      duration: const Duration(seconds: 2),
    ),
  );
}
