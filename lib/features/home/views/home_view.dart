import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
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
  String? _selectedWallet;

  void _onWalletTapped(String walletName) {
    setState(() {
      if (_selectedWallet == walletName) {
        _selectedWallet = null;
      } else {
        _selectedWallet = walletName;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    String currentTotal = '525.000';
    String titleText = 'Gran total';
    String walletsTitle = 'Billeteras';
    int movementsCount = 2;

    if (_selectedWallet == 'Nequi') {
      currentTotal = '200.000';
      titleText = 'Total';
      walletsTitle = 'Billeteras / Transferir';
      movementsCount = 3;
    } else if (_selectedWallet == 'Efectivo') {
      currentTotal = '125.000';
      titleText = 'Total';
      walletsTitle = 'Billeteras / Transferir';
      movementsCount = 1;
    } else if (_selectedWallet == 'Alcancia') {
      currentTotal = '200.000';
      titleText = 'Total';
      walletsTitle = 'Billeteras / Transferir';
      movementsCount = 4;
    }

    return Scaffold(
      backgroundColor: AppColors.blanco.solid,
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
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                const SizedBox(height: 32),
                GrandTotalCard(amount: currentTotal, title: titleText),
                const SizedBox(height: 32),
                SectionTitle(title: walletsTitle),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    WalletItem(
                      title: 'Nequi',
                      icon: Icons.badge_outlined,
                      isActive: _selectedWallet == 'Nequi',
                      onTap: () => _onWalletTapped('Nequi'),
                    ),
                    WalletItem(
                      title: 'Efectivo',
                      icon: Icons.menu_book,
                      isActive: _selectedWallet == 'Efectivo',
                      onTap: () => _onWalletTapped('Efectivo'),
                    ),
                    WalletItem(
                      title: 'Alcancia',
                      icon: Icons.savings_outlined,
                      isActive: _selectedWallet == 'Alcancia',
                      onTap: () => _onWalletTapped('Alcancia'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const SectionTitle(title: 'Ultimos movimientos'),
                const SizedBox(height: 16),
                ...List.generate(
                  movementsCount,
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
                      if (context.mounted) {
                        context.go('/login');
                      }
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
        bottomAction: CrossMenuItem(
          icon: Icons.bar_chart,
          onTap: () => print("Acción Abajo"),
        ),
        leftAction: CrossMenuItem(
          icon: Icons.local_offer,
          onTap: () => print("Acción Izquierda"),
        ),
        rightAction: CrossMenuItem(
          icon: Icons.edit_document,
          onTap: () => print("Acción Derecha"),
        ),
        child: Container(
          padding: const EdgeInsets.all(4),
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
            onPressed: null, // Dejamos que ActionCrossOverlay maneje los gestos
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
    );
  }
}
