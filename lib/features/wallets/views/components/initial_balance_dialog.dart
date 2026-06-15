import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alza/app/style/app_colors.dart';
import 'package:alza/app/style/app_fonts.dart';
import 'package:alza/shared/components/ui/button.dart';
import 'package:alza/shared/components/ui/text_box.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';
import 'package:alza/features/wallets/providers/wallets_provider.dart';

class InitialBalanceDialog extends StatefulWidget {
  final Wallet wallet;
  const InitialBalanceDialog({super.key, required this.wallet});

  @override
  State<InitialBalanceDialog> createState() => _InitialBalanceDialogState();
}

class _InitialBalanceDialogState extends State<InitialBalanceDialog> {
  final TextEditingController _balanceCtrl = TextEditingController(text: '0');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _balanceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitBalance() async {
    final balanceStr = _balanceCtrl.text.trim();
    final balance = double.tryParse(balanceStr);
    if (balance == null) {
      setState(() {
        _errorMessage = 'Por favor ingresa un número válido';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    final provider = Provider.of<WalletsProvider>(context, listen: false);
    debugPrint('[INITIAL BALANCE DIALOG] Actualizando saldo de billetera default a: $balance');
    final success = await provider.updateWallet(
      widget.wallet.id,
      name: widget.wallet.name,
      balance: balance,
      icon: widget.wallet.icon,
      color: widget.wallet.color,
    );
    
    if (!mounted) return;
    
    if (success) {
      debugPrint('[INITIAL BALANCE DIALOG] Saldo inicial confirmado con éxito.');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Saldo inicial confirmado con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      debugPrint('[INITIAL BALANCE DIALOG] ERROR al actualizar el saldo: ${provider.errorMessage}');
      setState(() {
        _isLoading = false;
        _errorMessage = provider.errorMessage ?? 'Error al guardar el saldo';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Obligatorio: no se puede retroceder con el botón atrás del sistema
      child: AlertDialog(
        backgroundColor: AppColors.negro.solid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: AppColors.verde.withOpacity(0.5), width: 1.5),
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
                color: AppColors.blanco.withOpacity(0.9),
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Hemos creado una billetera por defecto llamada "${widget.wallet.name}". Por favor, confirma o ingresa su saldo inicial:',
              style: AppFonts.montserrat(
                color: AppColors.blanco.withOpacity(0.7),
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CajaTexto(
              hintText: 'Ej. 50000',
              controller: _balanceCtrl,
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
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
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
          _isLoading
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
                  onPressed: _submitBalance,
                  width: double.infinity,
                  height: 48,
                ),
        ],
      ),
    );
  }
}
