import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';
import 'package:alza/features/wallets/providers/wallets_provider.dart';

class TransferSelectorBottomSheet extends StatelessWidget {
  final bool isOrigin;
  final Wallet? otherSelectedWallet;
  final Function(Wallet) onSelected;

  const TransferSelectorBottomSheet({
    super.key,
    required this.isOrigin,
    this.otherSelectedWallet,
    required this.onSelected,
  });

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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletsProvider>(context, listen: false);
    final list = provider.wallets.where((w) {
      if (otherSelectedWallet == null) return true;
      return w.id != otherSelectedWallet!.id;
    }).toList();

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
                      backgroundColor: wallet.color.withValues(alpha: 0.12),
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
                      onSelected(wallet);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
