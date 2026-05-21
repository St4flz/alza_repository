import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';
import 'package:alza/features/home/providers/home_provider.dart';
import 'package:alza/features/home/models/cross_menu_item.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/shared/components/ui/button.dart';
import 'package:alza/features/home/views/components/header_section.dart';
import 'package:alza/features/home/views/components/total_card.dart';
import 'package:alza/features/home/views/components/section_title.dart';
import 'package:alza/features/home/views/components/wallet_item.dart';
import 'package:alza/features/home/views/components/movement_item_placeholder.dart';
import 'package:alza/features/home/views/components/custom_bottom_nav.dart';
import 'package:alza/features/home/views/components/action_cross_overlay.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final user = authProvider.currentUser;

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeaderSection(
                    userName: user?.email,
                    onTap: () async {
                      await authProvider.signOut();
                    },
                  ),
                  const SizedBox(height: 32),
                  GrandTotalCard(
                    amount: homeProvider.totalAmount,
                    title: homeProvider.totalTitle,
                  ),
                  const SizedBox(height: 32),
                  SectionTitle(title: homeProvider.walletsSectionTitle),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: homeProvider.wallets.map((wallet) {
                      return WalletItem(
                        title: wallet.name,
                        icon: wallet.icon,
                        isActive: homeProvider.selectedWalletName == wallet.name,
                        onTap: () => homeProvider.selectWallet(wallet.name),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                  const SectionTitle(title: 'Ultimos movimientos'),
                  const SizedBox(height: 16),
                  ...List.generate(
                    homeProvider.movementsCount,
                    (_) => const MovementItemPlaceholder(),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Boton(
                      width: 220,
                      height: 48,
                      text: 'Cerrar sesión',
                      backgroundColor: AppColors.negro.solid,
                      textStyle: AppFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blanco.solid,
                      ),
                      onPressed: () async {
                        await authProvider.signOut();
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: ActionCrossOverlay(
          onDefaultTap: () {
            print("Navegar a vista por defecto");
          },
          topAction: CrossMenuItem(
            icon: Icons.add,
            onTap: () => print("Acción Arriba"),
          ),
          topLeftAction: CrossMenuItem(
            icon: Icons.local_offer,
            onTap: () => print("Acción Arriba-Izquierda"),
          ),
          topRightAction: CrossMenuItem(
            icon: Icons.grid_view,
            onTap: () => print("Acción Arriba-Derecha"),
          ),
          bottomAction: CrossMenuItem(
            icon: Icons.bar_chart,
            onTap: () => print("Acción Abajo"),
          ),
          bottomLeftAction: CrossMenuItem(
            icon: Icons.local_offer,
            onTap: () => print("Acción Abajo-Izquierda"),
          ),
          bottomRightAction: CrossMenuItem(
            icon: Icons.grid_view,
            onTap: () => print("Acción Abajo-Derecha"),
          ),
          leftAction: CrossMenuItem(
            icon: Icons.local_offer,
            onTap: () => print("Acción Izquierda"),
          ),
          leftTopAction: null,
          leftBottomAction: null,
          rightAction: CrossMenuItem(
            icon: Icons.edit_document,
            onTap: () => print("Acción Derecha"),
          ),
          rightTopAction: CrossMenuItem(
            icon: Icons.mic,
            onTap: () => print("Acción Derecha-Arriba"),
          ),
          rightBottomAction: CrossMenuItem(
            icon: Icons.camera_alt,
            onTap: () => print("Acción Derecha-Abajo"),
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(bottom: 70),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.blanco.solid,
              boxShadow: [
                BoxShadow(
                  color: AppColors.negro.withOpacity(0.05),
                  spreadRadius: 8,
                  blurRadius: 10,
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed:
                  null, // Dejamos que ActionCrossOverlay maneje los gestos
              backgroundColor: AppColors.blanco.solid,
              elevation: 0,
              shape: CircleBorder(
                side: BorderSide(color: AppColors.verde.solid, width: 2),
              ),
              child: Icon(
                Icons.playlist_add,
                color: AppColors.verde.solid,
                size: 32,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const CustomBottomNav(),
      ),
    );
  }
}
