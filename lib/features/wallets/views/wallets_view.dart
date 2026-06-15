import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';
import 'package:alza/features/wallets/providers/wallets_provider.dart';
import 'package:alza/features/wallets/views/components/wallet_list_item.dart';
import 'package:alza/features/wallets/views/components/percentage_bar.dart';
import 'package:alza/features/wallets/views/components/wallet_edit_sheet.dart';
import 'package:alza/features/wallets/views/components/initial_balance_dialog.dart';
import 'package:alza/features/wallets/views/components/add_wallet_dialog.dart';
import 'package:alza/features/wallets/views/components/transfer_selector_bottom_sheet.dart';
import 'package:alza/features/home/views/components/custom_bottom_nav.dart';
import 'package:alza/shared/components/ui/button.dart';

class WalletsView extends StatefulWidget {
  final bool forceInitialBalance;
  const WalletsView({super.key, this.forceInitialBalance = false});

  @override
  State<WalletsView> createState() => _WalletsViewState();
}

class _WalletsViewState extends State<WalletsView> {
  Wallet? _selectedWallet;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  // Variables para transferencia
  Wallet? _transferOriginWallet;
  Wallet? _transferDestWallet;
  final TextEditingController _transferAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final walletsProvider = Provider.of<WalletsProvider>(context, listen: false);
      debugPrint('[WALLETS VIEW] Cargando billeteras...');
      await walletsProvider.fetchWallets();
      
      if (widget.forceInitialBalance) {
        debugPrint('[WALLETS VIEW] forceInitialBalance detectado. Buscando billetera "Efectivo"...');
        final efectivoWallet = walletsProvider.wallets.firstWhere(
          (w) => w.name == 'Efectivo',
          orElse: () => walletsProvider.wallets.first,
        );
        
        // Auto-select the Efectivo wallet in UI
        _onWalletTapped(efectivoWallet);
        
        // Show the balance setup dialog
        if (mounted) {
          _showInitialBalanceDialog(efectivoWallet);
        }
      }
    });
  }

  void _showInitialBalanceDialog(Wallet wallet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => InitialBalanceDialog(wallet: wallet),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _transferAmountController.dispose();
    super.dispose();
  }

  void _onWalletTapped(Wallet wallet) {
    setState(() {
      if (_selectedWallet?.id == wallet.id) {
        _selectedWallet = null;
        _nameController.clear();
        _balanceController.clear();
      } else {
        _selectedWallet = wallet;
        _nameController.text = wallet.name;
        _balanceController.text = wallet.balance.toStringAsFixed(0);
      }
    });
  }

  void _cancelEdits() {
    setState(() {
      _selectedWallet = null;
      _nameController.clear();
      _balanceController.clear();
    });
  }

  Future<void> _saveEdits() async {
    if (_selectedWallet == null) return;
    final String newName = _nameController.text.trim();
    final double? newBalance = double.tryParse(_balanceController.text.trim());

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío.')),
      );
      return;
    }

    final provider = Provider.of<WalletsProvider>(context, listen: false);
    final success = await provider.updateWallet(
      _selectedWallet!.id,
      name: newName,
      balance: newBalance,
      icon: _selectedWallet!.icon,
      color: _selectedWallet!.color,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _selectedWallet = null;
        _nameController.clear();
        _balanceController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Billetera actualizada con éxito.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al actualizar la billetera.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteWallet(Wallet wallet) async {
    final provider = Provider.of<WalletsProvider>(context, listen: false);
    final success = await provider.deleteWallet(wallet.id);

    if (!mounted) return;

    if (success) {
      setState(() {
        _selectedWallet = null;
        _nameController.clear();
        _balanceController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Billetera "${wallet.name}" eliminada.'),
          action: SnackBarAction(
            label: 'Deshacer',
            textColor: Colors.amber,
            onPressed: () async {
              await provider.createWallet(
                name: wallet.name,
                balance: wallet.balance,
                icon: wallet.icon,
                color: wallet.color,
              );
            },
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al eliminar la billetera.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openCustomizer() {
    if (_selectedWallet == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return WalletEditSheet(
          initialIcon: _selectedWallet!.icon,
          initialColor: _selectedWallet!.color,
          onSelected: (newIcon, newColor) {
            setState(() {
              _selectedWallet!.icon = newIcon;
              _selectedWallet!.color = newColor;
            });
          },
        );
      },
    );
  }

  void _openAddWalletDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddWalletDialog(),
    );
  }

  String _formatCurrency(double amount) {
    final String str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    buffer.write(' \$');
    return buffer.toString();
  }

  Widget _buildGreenCircleIcon(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.verde.withOpacity(0.12),
          border: Border.all(
            color: AppColors.verde.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.verde.solid,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildFormRow({
    required String label,
    bool isEditable = false,
    TextEditingController? controller,
    TextInputType? keyboardType,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Expanded(
              child: isEditable
                  ? TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: AppFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.negro.withOpacity(0.6),
                      ),
                      decoration: InputDecoration(
                        hintText: label,
                        hintStyle: AppFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.negro.withOpacity(0.35),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Text(
                      label,
                      style: AppFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.negro.withOpacity(0.35),
                      ),
                    ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _selectWalletForTransfer({required bool isOrigin}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TransferSelectorBottomSheet(
          isOrigin: isOrigin,
          otherSelectedWallet: isOrigin ? _transferDestWallet : _transferOriginWallet,
          onSelected: (wallet) {
            setState(() {
              if (isOrigin) {
                _transferOriginWallet = wallet;
              } else {
                _transferDestWallet = wallet;
              }
            });
          },
        );
      },
    );
  }

  Future<void> _executeTransfer() async {
    if (_transferOriginWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una billetera de origen.')),
      );
      return;
    }
    if (_transferDestWallet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una billetera de destino.')),
      );
      return;
    }

    final amountStr = _transferAmountController.text.trim();
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un monto válido mayor a 0.')),
      );
      return;
    }

    if (amount > _transferOriginWallet!.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saldo insuficiente en la billetera de origen.')),
      );
      return;
    }

    final provider = Provider.of<WalletsProvider>(context, listen: false);
    final success = await provider.createTransfer(
      originWalletId: _transferOriginWallet!.id,
      destWalletId: _transferDestWallet!.id,
      amount: amount,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _transferOriginWallet = null;
        _transferDestWallet = null;
        _transferAmountController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Transferencia realizada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Error al realizar la transferencia.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletsProvider = Provider.of<WalletsProvider>(context);
    final wallets = walletsProvider.wallets;

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.negro.solid),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title and Add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Billeteras',
                            style: AppFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.negro.solid,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${wallets.length})',
                            style: AppFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.negro.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _openAddWalletDialog,
                        icon: Icon(
                          Icons.add_rounded,
                          color: AppColors.verde.solid,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Wallets Vertical List
                  if (walletsProvider.isLoading && wallets.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.0),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D764)),
                        ),
                      ),
                    )
                  else if (wallets.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Text(
                          'No tienes billeteras registradas.',
                          style: AppFonts.montserrat(
                            fontSize: 16,
                            color: AppColors.negro.withOpacity(0.5),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: wallets.map((wallet) {
                        return WalletListItem(
                          title: wallet.name,
                          balanceText: _formatCurrency(wallet.balance),
                          icon: wallet.icon,
                          isActive: _selectedWallet?.id == wallet.id,
                          activeColor: wallet.color,
                          onTap: () => _onWalletTapped(wallet),
                        );
                      }).toList(),
                    ),

                  // Percentage Progress Bar
                  PercentageBar(wallets: wallets),

                  const SizedBox(height: 8),

                  // Dynamic Bottom Panel: Transacción vs Edición
                  if (_selectedWallet == null) ...[
                    // MODO TRANSACCIÓN
                    _buildFormRow(
                      label: _transferOriginWallet != null 
                          ? 'Origen: ${_transferOriginWallet!.name} (${_formatCurrency(_transferOriginWallet!.balance)})' 
                          : 'Origen',
                      trailing: _buildGreenCircleIcon(
                        _transferOriginWallet != null ? Icons.close_rounded : Icons.search_rounded, 
                        () {
                          if (_transferOriginWallet != null) {
                            setState(() {
                              _transferOriginWallet = null;
                            });
                          } else {
                            _selectWalletForTransfer(isOrigin: true);
                          }
                        }
                      ),
                      onTap: () => _selectWalletForTransfer(isOrigin: true),
                    ),
                    _buildFormRow(
                      label: _transferDestWallet != null 
                          ? 'Destino: ${_transferDestWallet!.name} (${_formatCurrency(_transferDestWallet!.balance)})' 
                          : 'Destino',
                      trailing: _buildGreenCircleIcon(
                        _transferDestWallet != null ? Icons.close_rounded : Icons.search_rounded, 
                        () {
                          if (_transferDestWallet != null) {
                            setState(() {
                              _transferDestWallet = null;
                            });
                          } else {
                            _selectWalletForTransfer(isOrigin: false);
                          }
                        }
                      ),
                      onTap: () => _selectWalletForTransfer(isOrigin: false),
                    ),
                    _buildFormRow(
                      label: 'Monto',
                      isEditable: true,
                      controller: _transferAmountController,
                      keyboardType: TextInputType.number,
                      trailing: Icon(
                        Icons.assignment_outlined,
                        color: AppColors.negro.withOpacity(0.3),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Boton(
                      text: walletsProvider.isLoading ? 'Transfiriendo...' : 'Transferir',
                      backgroundColor: walletsProvider.isLoading 
                          ? AppColors.negro.withOpacity(0.3) 
                          : AppColors.negro.solid,
                      textStyle: AppFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: AppColors.blanco.solid,
                      ),
                      onPressed: () {
                        if (!walletsProvider.isLoading) {
                          _executeTransfer();
                        }
                      },
                      width: double.infinity,
                      height: 48,
                    ),
                  ] else ...[
                    // MODO EDICIÓN
                    _buildFormRow(
                      label: 'Nombre',
                      isEditable: true,
                      controller: _nameController,
                      trailing: _buildGreenCircleIcon(Icons.close_rounded, _cancelEdits),
                    ),
                    _buildFormRow(
                      label: 'Saldo inicial',
                      isEditable: true,
                      controller: _balanceController,
                      keyboardType: TextInputType.number,
                      trailing: _buildGreenCircleIcon(Icons.check_rounded, _saveEdits),
                    ),
                    // Fila de acciones extra (Icono/Color y Eliminar)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _openCustomizer,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _selectedWallet!.color.withValues(alpha: 0.12),
                                border: Border.all(
                                  color: _selectedWallet!.color,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                _selectedWallet!.icon,
                                color: _selectedWallet!.color,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          IconButton(
                            onPressed: () => _deleteWallet(_selectedWallet!),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red[400],
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Spacing for bottom area
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
