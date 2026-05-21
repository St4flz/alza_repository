import 'package:go_router/go_router.dart';
import 'package:alza/features/auth/views/initial_view.dart';
import 'package:alza/features/auth/views/login_view.dart';
import 'package:alza/features/home/views/home_view.dart';
import 'package:alza/features/home/views/wallets_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appRouter = GoRouter(
  initialLocation: '/initial',
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/initial'),
    GoRoute(path: '/login-callback', redirect: (context, state) => '/home'),
    GoRoute(path: '/initial', builder: (context, state) => const InitialView()),
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
    GoRoute(
      path: '/wallets',
      builder: (context, state) => const WalletsView(),
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
