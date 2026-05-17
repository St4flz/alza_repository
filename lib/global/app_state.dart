import 'package:flutter/foundation.dart';

/// Variable global para manejar el tema de la aplicación.
/// Valores permitidos: 'claro' u 'oscuro'.
/// Es el equivalente a un estado global (como Context o Zustand) en React.
final ValueNotifier<String> tema = ValueNotifier<String>('claro');
