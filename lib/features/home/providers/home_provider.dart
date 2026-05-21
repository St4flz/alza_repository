import 'package:flutter/material.dart';
import 'package:alza/features/home/models/wallet.dart';

class HomeProvider extends ChangeNotifier {
  final List<Wallet> _wallets = const [
    Wallet(
      name: 'Nequi',
      icon: Icons.badge_outlined,
      totalAmount: '200.000',
      movementsCount: 2,
    ),
    Wallet(
      name: 'Efectivo',
      icon: Icons.menu_book,
      totalAmount: '125.000',
      movementsCount: 1,
    ),
    Wallet(
      name: 'Alcancia',
      icon: Icons.savings_outlined,
      totalAmount: '200.000',
      movementsCount: 2,
    ),
  ];

  List<Wallet> get wallets => _wallets;

  String _selectedWalletName = '';
  String get selectedWalletName => _selectedWalletName;

  void selectWallet(String walletName) {
    if (_selectedWalletName == walletName) {
      _selectedWalletName = '';
    } else {
      _selectedWalletName = walletName;
    }
    notifyListeners();
  }

  Wallet? get selectedWallet {
    if (_selectedWalletName.isEmpty) return null;
    return _wallets.firstWhere((w) => w.name == _selectedWalletName);
  }

  String get totalAmount {
    final selected = selectedWallet;
    if (selected != null) {
      return selected.totalAmount;
    }
    // Si no hay billetera seleccionada, el Gran Total es la suma de todas (525.000)
    return '525.000';
  }

  String get totalTitle {
    return selectedWallet == null ? 'Gran total' : 'Total';
  }

  String get walletsSectionTitle {
    return selectedWallet == null ? 'Billeteras' : 'Billeteras / Transferir';
  }

  int get movementsCount {
    return selectedWallet?.movementsCount ?? 2;
  }
}
