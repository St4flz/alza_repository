import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/features/auth/providers/auth_provider.dart';
import 'package:alza/features/home/providers/home_provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/features/home/views/components/header_section.dart';
import 'package:alza/features/home/views/components/total_card.dart';
import 'package:alza/features/home/views/components/section_title.dart';
import 'package:alza/features/home/views/components/wallet_item.dart';
import 'package:alza/features/movements/providers/movements_provider.dart';
import 'package:alza/features/movements/views/components/movement_item.dart';
import 'package:alza/features/home/views/components/custom_bottom_nav.dart';
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
      await _loadMovements();
    });
  }

  Future<void> _loadMovements() async {
    if (!mounted) return;
    final movementsProvider = Provider.of<MovementsProvider>(context, listen: false);
    debugPrint('[HOME VIEW] Cargando movimientos reales...');
    await movementsProvider.fetchMovements();
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
    final createdDefault = await walletsProvider.checkAndSetupWallets();
    
    if (createdDefault && mounted) {
      debugPrint('[HOME VIEW] Redirigiendo a wallets para configurar saldo inicial...');
      context.push('/wallets?forceInitialBalance=true');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final walletsProvider = Provider.of<WalletsProvider>(context);
    final movementsProvider = Provider.of<MovementsProvider>(context);
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
                  GestureDetector(
                    onTap: () => context.push('/movements'),
                    behavior: HitTestBehavior.opaque,
                    child: const SectionTitle(title: 'Últimos movimientos'),
                  ),
                  const SizedBox(height: 16),
                  if (movementsProvider.isLoading && movementsProvider.movements.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D764)),
                        ),
                      ),
                    )
                  else if (movementsProvider.movements.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        'No tienes movimientos registrados.',
                        style: AppFonts.montserrat(
                          fontSize: 14,
                          color: AppColors.negro.withOpacity(0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    ...movementsProvider.movements.take(10).map((movement) {
                      return MovementItem(movement: movement);
                    }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const CustomBottomNav(),
      ),
    );
  }
}
