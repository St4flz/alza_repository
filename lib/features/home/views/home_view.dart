import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';
import 'package:alza/features/home/providers/home_provider.dart';
import 'package:alza/features/home/models/cross_menu_item.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/features/home/views/components/header_section.dart';
import 'package:alza/features/home/views/components/total_card.dart';
import 'package:alza/features/home/views/components/section_title.dart';
import 'package:alza/features/home/views/components/wallet_item.dart';
import 'package:alza/features/home/views/components/movement_item_placeholder.dart';
import 'package:alza/features/home/views/components/custom_bottom_nav.dart';
import 'package:alza/features/home/views/components/action_cross_overlay.dart';
import 'package:alza/features/home/views/components/username_modal.dart';
import 'package:alza/features/wallets/providers/wallets_provider.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAndPromptUsername();
      await _checkAndSetupWallets();
    });
  }

  Future<void> _checkAndPromptUsername() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    debugPrint('[HOME VIEW] Verificando perfil de usuario y nombre de usuario...');
    
    // Load profile
    await authProvider.loadProfile();
    
    final profile = authProvider.profile;
    if (profile == null) {
      debugPrint('[HOME VIEW] El perfil no se pudo cargar.');
      return;
    }
    
    final username = profile['username'] as String?;
    debugPrint('[HOME VIEW] Nombre de usuario actual: "$username"');
    
    if (username == null || username.isEmpty) {
      if (mounted) {
        debugPrint('[HOME VIEW] El nombre de usuario no existe o está vacío. Abriendo UsernameModal...');
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => UsernameModal(
            onSave: (newName) async {
              debugPrint('[HOME VIEW] Guardando nombre de usuario desde modal: $newName');
              final success = await authProvider.updateProfile(username: newName);
              return success;
            },
          ),
        );
      }
    }
  }

  Future<void> _checkAndSetupWallets() async {
    if (!mounted) return;
    final walletsProvider = Provider.of<WalletsProvider>(context, listen: false);
    debugPrint('[HOME VIEW] Cargando billeteras del backend...');
    final success = await walletsProvider.fetchWallets();
    
    if (success) {
      debugPrint('[HOME VIEW] Billeteras reales encontradas: ${walletsProvider.wallets.length}');
      if (walletsProvider.wallets.isEmpty) {
        debugPrint('[HOME VIEW] No se encontraron billeteras. Creando "Efectivo" automáticamente...');
        final createSuccess = await walletsProvider.createWallet(
          name: 'Efectivo',
          balance: 0.0,
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.verde.solid,
        );
        
        if (createSuccess && mounted) {
          debugPrint('[HOME VIEW] Billetera por defecto "Efectivo" creada. Redirigiendo a wallets...');
          context.push('/wallets?forceInitialBalance=true');
        }
      }
    } else {
      debugPrint('[HOME VIEW] ERROR al obtener billeteras: ${walletsProvider.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final walletsProvider = Provider.of<WalletsProvider>(context);
    final user = authProvider.currentUser;

    // Sincronizar las billeteras reales en tiempo real
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        homeProvider.setRealWallets(walletsProvider.wallets);
      }
    });

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
                    userName: authProvider.profile?['username']?.isNotEmpty == true
                        ? authProvider.profile!['username']
                        : user?.email,
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
                  GestureDetector(
                    onTap: () => context.push('/wallets'),
                    behavior: HitTestBehavior.opaque,
                    child: SectionTitle(
                      title: homeProvider.walletsSectionTitle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: walletsProvider.wallets.map((wallet) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: WalletItem(
                            title: wallet.name,
                            icon: wallet.icon,
                            isActive:
                                homeProvider.selectedWalletId == wallet.id,
                            onTap: () => homeProvider.selectWalletById(wallet.id),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SectionTitle(title: 'Ultimos movimientos'),
                  const SizedBox(height: 16),
                  ...List.generate(
                    homeProvider.movementsCount,
                    (_) => const MovementItemPlaceholder(),
                  ),
                  const SizedBox(height: 100),
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
