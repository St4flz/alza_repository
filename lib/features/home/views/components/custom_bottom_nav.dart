import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/app/routes/app_router.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    this.onPersonTap,
    this.onHomeTap,
    this.onAgentTap,
    this.onSettingsTap,
  });

  final VoidCallback? onPersonTap;
  final VoidCallback? onHomeTap;
  final VoidCallback? onAgentTap;
  final VoidCallback? onSettingsTap;

  void _showUserOptionsBottomSheet(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.blanco.solid,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.negro.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar decorativo
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.negro.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Cabecera con datos del usuario - Clickable para ir al perfil
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.pop(context); // Cierra el menú inferior
                      context.push('/profile');
                    },
                    child: Row(
                      children: [
                        // Avatar dinámico
                        authProvider.profile?['avatar_url'] != null &&
                                (authProvider.profile!['avatar_url'] as String).startsWith('http')
                            ? Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(authProvider.profile!['avatar_url'] as String),
                                    fit: BoxFit.cover,
                                  ),
                                  border: Border.all(
                                    color: AppColors.verde.solid.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.verde.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.verde.solid,
                                  size: 28,
                                ),
                              ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authProvider.profile?['full_name'] != null &&
                                        (authProvider.profile!['full_name'] as String).isNotEmpty
                                    ? authProvider.profile!['full_name'] as String
                                    : (authProvider.profile?['username'] != null &&
                                            (authProvider.profile!['username'] as String).isNotEmpty
                                        ? authProvider.profile!['username'] as String
                                        : 'Usuario'),
                                style: AppFonts.montserrat(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.negro.solid,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                user?.email ?? 'correo@ejemplo.com',
                                style: AppFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.negro.withOpacity(0.5),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.negro.withOpacity(0.3),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Opción: Cambiar contraseña
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.verde.withOpacity(0.12),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.verde.solid,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      'Cambiar contraseña',
                      style: AppFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.negro.solid,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.negro.withOpacity(0.3),
                      size: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: AppColors.negro.withOpacity(0.03),
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.changePassword);
                    },
                  ),
                  const SizedBox(height: 12),
                  // Opción: Cerrar sesión
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.negro.withOpacity(0.08),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: AppColors.negro.solid,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      'Cerrar sesión',
                      style: AppFonts.montserrat(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.negro.solid,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.negro.withOpacity(0.3),
                      size: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    tileColor: AppColors.negro.withOpacity(0.03),
                    onTap: () async {
                      Navigator.pop(context);
                      await authProvider.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.blanco.solid,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.negro.solid.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Izquierda: Persona y Home
            Row(
              children: [
                IconButton(
                  onPressed:
                      onPersonTap ?? () => _showUserOptionsBottomSheet(context),
                  icon: Icon(
                    Icons.person,
                    color: AppColors.negro.solid,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: onHomeTap ?? () {},
                      icon: Icon(
                        Icons.home,
                        color: AppColors.negro.solid,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 24,
                      height: 3,
                      color: AppColors.verde.solid,
                    ),
                  ],
                ),
              ],
            ),
            
            // Centro: Botón Agregar (Playlist Add Verde)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.blanco.solid,
                border: Border.all(color: AppColors.verde.solid, width: 2),
              ),
              child: IconButton(
                onPressed: () => context.push('/add-movement'),
                icon: Icon(
                  Icons.playlist_add,
                  color: AppColors.verde.solid,
                  size: 28,
                ),
              ),
            ),

            // Derecha: AI Stars (Chat) y Reports
            Row(
              children: [
                IconButton(
                  onPressed: () => context.push('/chat'),
                  icon: Icon(
                    Icons.auto_awesome,
                    color: AppColors.negro.solid,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => context.push('/reports'),
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color: AppColors.negro.solid,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
