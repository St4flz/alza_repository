import 'package:go_router/go_router.dart';
import 'package:alza/features/splash/presentation/screens/splash_view.dart';
import 'package:alza/features/auth/presentation/screens/login_view.dart';
import 'package:alza/features/home/presentation/screens/home_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
    GoRoute(
      path: '/login-callback',
      redirect: (context, state) => '/splash',
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          return '/home';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeView(),
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return '/login';
        }
        return null;
      },
    ),
  ],
);
