import 'package:flutter/material.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:alza/theme/app_colors.dart';
import 'package:alza/theme/app_fonts.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Alza+', style: AppFonts.verdanaPro(color: AppColors.blanco.solid)),
        backgroundColor: AppColors.verde.solid,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.blanco.solid),
            onPressed: () async {
              await authProvider.signOut();
              // La redirección ocurrirá automáticamente por el listener del router (o forzamos go)
              if (context.mounted) {
                context.go('/login');
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido a tu Dashboard',
              style: AppFonts.verdanaPro(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.verde.solid),
            ),
            const SizedBox(height: 20),
            if (user != null)
              Text(
                user.email ?? 'Usuario',
                style: AppFonts.montserrat(fontSize: 16, color: AppColors.negro.withOpacity(0.8)),
              ),
          ],
        ),
      ),
    );
  }
}
