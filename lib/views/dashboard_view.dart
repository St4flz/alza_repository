import 'package:flutter/material.dart';
import 'package:alza/theme/app_colors.dart';
import 'package:alza/components/header_section.dart';
import 'package:alza/components/grand_total_card.dart';
import 'package:alza/components/section_title.dart';
import 'package:alza/components/wallet_item.dart';
import 'package:alza/components/movement_item_placeholder.dart';
import 'package:alza/components/custom_bottom_nav.dart';
import 'package:alza/components/action_cross_overlay.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
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
                const HeaderSection(),
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
