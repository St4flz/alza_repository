import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alza/features/auth/views/initial_view.dart';
import 'package:alza/features/auth/views/login_view.dart';
import 'package:alza/features/home/views/home_view.dart';

// Constantes de rutas para evitar typos
abstract class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String loginCallback = '/login-callback';
  static const String home = '/home';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.initial,
  
  // Escucha los cambios de sesión de Supabase y fuerza a re-evaluar las rutas
  refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),

  routes: [
    GoRoute(
      path: AppRoutes.initial,
      builder: (context, state) => const InitialView(),
    ),
    GoRoute(
      path: AppRoutes.loginCallback,
      redirect: (context, state) => AppRoutes.home,
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeView(),
    ),
  ],

  // Guardas centralizadas
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    
    final isGoingToLogin = state.matchedLocation == AppRoutes.login;
    final isGoingToInitial = state.matchedLocation == AppRoutes.initial;

    // 1. Usuario no logueado intenta ir a una ruta privada
    if (!isLoggedIn && !isGoingToLogin && !isGoingToInitial) {
      return AppRoutes.login;
    }

    // 2. Usuario logueado intenta ir a Login o a la pantalla Inicial
    if (isLoggedIn && (isGoingToLogin || isGoingToInitial)) {
      return AppRoutes.home;
    }

    return null; // Deja navegar normalmente
  },
);

// Clase de soporte para transformar el Stream de Supabase en Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

