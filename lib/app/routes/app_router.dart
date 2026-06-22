import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alza/features/auth/views/initial_view.dart';
import 'package:alza/features/auth/views/login_view.dart';
import 'package:alza/features/home/views/home_view.dart';
import 'package:alza/features/wallets/views/wallets_view.dart';
import 'package:alza/features/user/views/change_password_view.dart';
import 'package:alza/features/user/views/profile_view.dart';
import 'package:alza/features/movements/views/add_movement_view.dart';
import 'package:alza/features/movements/views/movements_list_view.dart';
import 'package:alza/features/chat/views/chat_view.dart';
import 'package:alza/features/reports/views/reports_view.dart';

// Constantes de rutas para evitar typos
abstract class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String loginCallback = '/login-callback';
  static const String home = '/home';
  static const String wallets = '/wallets';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String profile = '/profile';
  static const String addMovement = '/add-movement';
  static const String movements = '/movements';
  static const String chat = '/chat';
  static const String reports = '/reports';
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
      path: '/login-callback',
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
    GoRoute(
      path: AppRoutes.wallets,
      builder: (context, state) {
        final forceBalance = state.uri.queryParameters['forceInitialBalance'] == 'true';
        return WalletsView(forceInitialBalance: forceBalance);
      },
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      redirect: (context, state) => AppRoutes.changePassword,
    ),
    GoRoute(
      path: '/reset-password',
      redirect: (context, state) => AppRoutes.changePassword,
    ),
    GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => const ChangePasswordView(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileView(),
    ),
    GoRoute(
      path: AppRoutes.addMovement,
      builder: (context, state) => const AddMovementView(),
    ),
    GoRoute(
      path: AppRoutes.movements,
      builder: (context, state) => const MovementsListView(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatView(),
    ),
    GoRoute(
      path: AppRoutes.reports,
      builder: (context, state) => const ReportsView(),
    ),
  ],

  // Guardas centralizadas
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    
    final isGoingToLogin = state.matchedLocation == AppRoutes.login;
    final isGoingToInitial = state.matchedLocation == AppRoutes.initial;
    final isGoingToResetPassword = state.matchedLocation == AppRoutes.resetPassword || state.matchedLocation == '/reset-password';
    final isGoingToChangePassword = state.matchedLocation == AppRoutes.changePassword;

    // 1. Usuario no logueado intenta ir a una ruta privada
    if (!isLoggedIn && !isGoingToLogin && !isGoingToInitial && !isGoingToResetPassword && !isGoingToChangePassword) {
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
    _subscription = stream.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        debugPrint('GoRouterRefreshStream: passwordRecovery detectado, redirigiendo a ${AppRoutes.changePassword}');
        Future.microtask(() {
          appRouter.go(AppRoutes.changePassword);
        });
      } else {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

