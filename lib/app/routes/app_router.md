import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Segregamos los nombres de las rutas en constantes para evitar errores de dedo (Typos)
abstract class AppRoutes {
  static const String root = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String loginCallback = '/login-callback';
  static const String home = '/home';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  
  // 2. HACEMOS QUE EL ROUTER SEA REACTIVO
  // Supabase provee un Stream de auth. Convertimos ese stream en un Listenable 
  // para que GoRouter re-evalúe las rutas CADA VEZ que el estado del usuario cambie.
  refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),

  routes: [
    GoRoute(
      path: AppRoutes.root,
      redirect: (_, __) => AppRoutes.splash,
    ),
    GoRoute(
      path: AppRoutes.loginCallback,
      redirect: (_, __) => AppRoutes.splash,
    ),
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashView(),
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

  // 3. CENTRALIZAMOS LA LÓGICA DE GUARDIAS (Guards) EN UN REDIRECT GLOBAL
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    
    // Guardamos la ruta a la que el usuario está intentando ir
    final isGoingToLogin = state.matchedLocation == AppRoutes.login;
    final isGoingToSplash = state.matchedLocation == AppRoutes.splash;

    // Caso 1: El usuario no está logueado y no va hacia el Login ni al Splash
    if (!isLoggedIn && !isGoingToLogin && !isGoingToSplash) {
      return AppRoutes.login;
    }

    // Caso 2: El usuario SÍ está logueado e intenta ir al Login o al Splash
    if (isLoggedIn && (isGoingToLogin || isGoingToSplash)) {
      return AppRoutes.home;
    }

    // En cualquier otro caso, dejamos que navegue normalmente (return null)
    return null;
  },
);

// Helper necesario para transformar el Stream de Supabase en algo que GoRouter entienda
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