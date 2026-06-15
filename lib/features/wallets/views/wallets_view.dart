import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/bg/bg.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';
import 'package:alza/features/wallets/models/transfer_model.dart';
import 'package:alza/features/wallets/providers/wallets_provider.dart';
import 'package:alza/features/home/views/components/wallet_list_item.dart';
import 'package:alza/features/home/views/components/percentage_bar.dart';
import 'package:alza/features/home/views/components/wallet_edit_sheet.dart';
import 'package:alza/features/home/views/components/custom_bottom_nav.dart';
import 'package:alza/shared/components/ui/button.dart';
import 'package:alza/shared/components/ui/text_box.dart';

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
    final TextEditingController balanceCtrl = TextEditingController(text: '0');
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false, // Obligatorio: no se puede descartar tocando fuera
      builder: (context) {
        return PopScope(
          canPop: false, // Obligatorio: no se puede retroceder con el botón atrás del sistema
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: AppColors.negro.solid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: AppColors.verde.solid.withOpacity(0.5), width: 1.5),
                ),
                title: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.verde.solid,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Configura tu Billetera',
                      style: AppFonts.montserrat(
                        color: AppColors.verde.solid,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Las billeteras representan tus diferentes fuentes de dinero (efectivo, bancos, tarjetas, etc.).',
                      style: AppFonts.montserrat(
                        color: AppColors.blanco.solid.withOpacity(0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hemos creado una billetera por defecto llamada "${wallet.name}". Por favor, confirma o ingresa su saldo inicial:',
                      style: AppFonts.montserrat(
                        color: AppColors.blanco.solid.withOpacity(0.7),
                        fontSize: 13,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    CajaTexto(
                      hintText: 'Ej. 50000',
                      controller: balanceCtrl,
                      backgroundColor: AppColors.blanco.withOpacity(0.1),
                      hintStyle: AppFonts.montserrat(
                        fontSize: 14,
                        color: AppColors.blanco.withOpacity(0.4),
                      ),
                      textStyle: AppFonts.montserrat(
                        fontSize: 16,
                        color: AppColors.blanco.solid,
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMessage!,
                        style: AppFonts.montserrat(
                          color: Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ]
                  ],
                ),
                actionsAlignment: MainAxisAlignment.center,
                actions: [
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : Boton(
                          text: 'Confirmar Saldo',
                          backgroundColor: AppColors.verde.solid,
                          textStyle: AppFonts.montserrat(
                            fontWeight: FontWeight.bold,
                            color: AppColors.blanco.solid,
                          ),
                          onPressed: () async {
                            final balanceStr = balanceCtrl.text.trim();
                            final balance = double.tryParse(balanceStr);
                            if (balance == null) {
                              setDialogState(() {
                                errorMessage = 'Por favor ingresa un número válido';
                              });
                              return;
                            }
                            
                            setDialogState(() {
                              isLoading = true;
                              errorMessage = null;
                            });
                            
                            final provider = Provider.of<WalletsProvider>(context, listen: false);
                            debugPrint('[WALLETS VIEW] Actualizando saldo de billetera default a: $balance');
                            final success = await provider.updateWallet(
                              wallet.id,
                              name: wallet.name,
                              balance: balance,
                              icon: wallet.icon,
                              color: wallet.color,
                            );
                            
                            if (success) {
                              debugPrint('[WALLETS VIEW] Saldo inicial confirmado con éxito.');
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('¡Saldo inicial confirmado con éxito!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              debugPrint('[WALLETS VIEW] ERROR al actualizar el saldo: ${provider.errorMessage}');
                              setDialogState(() {
                                isLoading = false;
                                errorMessage = provider.errorMessage ?? 'Error al guardar el saldo';
                              });
                            }
                          },
                          width: double.infinity,
                          height: 48,
                        ),
                ],
              );
            },
          ),
        );
      },
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
    final nameCtrl = TextEditingController();
    final balanceCtrl = TextEditingController();
    IconData selectedIcon = Icons.account_balance_wallet_outlined;
    Color selectedColor = AppColors.verde.solid;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.blanco.solid,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Text(
                'Nueva Billetera',
                style: AppFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.negro.solid,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la billetera',
                      hintText: 'Ej. Ahorros',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: balanceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Saldo inicial',
                      hintText: 'Ej. 200000',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ícono y Color:',
                        style: AppFonts.montserrat(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) {
                              return WalletEditSheet(
                                initialIcon: selectedIcon,
                                initialColor: selectedColor,
                                onSelected: (newIcon, newColor) {
                                  setDialogState(() {
                                    selectedIcon = newIcon;
                                    selectedColor = newColor;
                                  });
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectedColor.withOpacity(0.15),
                            border: Border.all(color: selectedColor, width: 2),
                          ),
                          child: Icon(
                            selectedIcon,
                            color: selectedColor,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.red[400]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final balanceStr = balanceCtrl.text.trim();
                    if (name.isEmpty) return;

                    final balance = double.tryParse(balanceStr) ?? 0.0;

                    final provider = Provider.of<WalletsProvider>(context, listen: false);
                    Navigator.pop(context);

                    final success = await provider.createWallet(
                      name: name,
                      balance: balance,
                      icon: selectedIcon,
                      color: selectedColor,
                    );

                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.errorMessage ?? 'Error al crear la billetera.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Billetera creada con éxito.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.negro.solid,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Crear',
                    style: TextStyle(color: AppColors.blanco.solid),
                  ),
                ),
              ],
            );
          },
        );
      },
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
          color: AppColors.verde.solid.withOpacity(0.12),
          border: Border.all(
            color: AppColors.verde.solid.withOpacity(0.4),
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
                        color: AppColors.negro.solid.withOpacity(0.6),
                      ),
                      decoration: InputDecoration(
                        hintText: label,
                        hintStyle: AppFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.negro.solid.withOpacity(0.35),
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
                        color: AppColors.negro.solid.withOpacity(0.35),
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
    final provider = Provider.of<WalletsProvider>(context, listen: false);
    final list = provider.wallets.where((w) {
      if (isOrigin) {
        return _transferDestWallet == null || w.id != _transferDestWallet!.id;
      } else {
        return _transferOriginWallet == null || w.id != _transferOriginWallet!.id;
      }
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.blanco.solid,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isOrigin ? 'Selecciona Billetera Origen' : 'Selecciona Billetera Destino',
                style: AppFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.negro.solid,
                ),
              ),
              const SizedBox(height: 16),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No hay billeteras disponibles.',
                    style: AppFonts.montserrat(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final wallet = list[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: wallet.color.withOpacity(0.12),
                          child: Icon(wallet.icon, color: wallet.color),
                        ),
                        title: Text(
                          wallet.name,
                          style: AppFonts.montserrat(
                            fontWeight: FontWeight.w600,
                            color: AppColors.negro.solid,
                          ),
                        ),
                        subtitle: Text(
                          _formatCurrency(wallet.balance),
                          style: AppFonts.montserrat(
                            color: Colors.grey[600],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            if (isOrigin) {
                              _transferOriginWallet = wallet;
                            } else {
                              _transferDestWallet = wallet;
                            }
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
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
                              color: AppColors.negro.solid.withOpacity(0.4),
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
                            color: AppColors.negro.solid.withOpacity(0.5),
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
                        color: AppColors.negro.solid.withOpacity(0.3),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Boton(
                      text: walletsProvider.isLoading ? 'Transfiriendo...' : 'Transferir',
                      backgroundColor: walletsProvider.isLoading 
                          ? AppColors.negro.solid.withOpacity(0.3) 
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
                                color: _selectedWallet!.color.withOpacity(0.12),
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
