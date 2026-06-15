import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/features/wallets/providers/wallets_provider.dart';
import 'package:alza/features/wallets/views/components/wallet_edit_sheet.dart';

class AddWalletDialog extends StatefulWidget {
  const AddWalletDialog({super.key});

  @override
  State<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends State<AddWalletDialog> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _balanceCtrl = TextEditingController();
  IconData _selectedIcon = Icons.account_balance_wallet_outlined;
  Color _selectedColor = AppColors.verde.solid;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final balanceStr = _balanceCtrl.text.trim();
    if (name.isEmpty) return;

    final balance = double.tryParse(balanceStr) ?? 0.0;
    final provider = Provider.of<WalletsProvider>(context, listen: false);
    
    // Close dialog
    Navigator.pop(context);

    // Call service to create
    final success = await provider.createWallet(
      name: name,
      balance: balance,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    // Use a context check to show the snackbar safely
    if (success) {
      debugPrint('[ADD WALLET DIALOG] Billetera creada con éxito.');
    } else {
      debugPrint('[ADD WALLET DIALOG] ERROR al crear la billetera: ${provider.errorMessage}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nombre de la billetera',
              hintText: 'Ej. Ahorros',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _balanceCtrl,
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
                        initialIcon: _selectedIcon,
                        initialColor: _selectedColor,
                        onSelected: (newIcon, newColor) {
                          setState(() {
                            _selectedIcon = newIcon;
                            _selectedColor = newColor;
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
                    color: _selectedColor.withValues(alpha: 0.15),
                    border: Border.all(color: _selectedColor, width: 2),
                  ),
                  child: Icon(
                    _selectedIcon,
                    color: _selectedColor,
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
          onPressed: _submit,
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
  }
}
