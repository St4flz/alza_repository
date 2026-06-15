import 'package:flutter/material.dart';
import 'package:alza/features/wallets/models/wallet_model.dart' as model;
import 'package:alza/features/wallets/providers/wallets_provider.dart';

class HomeProvider extends ChangeNotifier {
  WalletsProvider? _walletsProvider;

  List<model.Wallet> get wallets => _walletsProvider?.wallets ?? [];

  void updateWalletsProvider(WalletsProvider walletsProvider) {
    _walletsProvider = walletsProvider;
  }

  String _selectedWalletId = '';
  String get selectedWalletId => _selectedWalletId;

  String get selectedWalletName {
    final selected = selectedWallet;
    return selected?.name ?? '';
  }

  void selectWallet(String walletName) {
    final list = wallets;
    if (list.isEmpty) return;
    try {
      final wallet = list.firstWhere((w) => w.name == walletName);
      if (_selectedWalletId == wallet.id) {
        _selectedWalletId = '';
      } else {
        _selectedWalletId = wallet.id;
      }
      notifyListeners();
    } catch (_) {
      _selectedWalletId = '';
      notifyListeners();
    }
  }

  void selectWalletById(String walletId) {
    if (_selectedWalletId == walletId) {
      _selectedWalletId = '';
    } else {
      _selectedWalletId = walletId;
    }
    notifyListeners();
  }

  model.Wallet? get selectedWallet {
    if (_selectedWalletId.isEmpty) return null;
    try {
      return wallets.firstWhere((w) => w.id == _selectedWalletId);
    } catch (_) {
      return null;
    }
  }

  String get totalAmount {
    final selected = selectedWallet;
    if (selected != null) {
      return _formatCurrency(selected.balance);
    }
    // Sum of all wallets
    final sum = wallets.fold<double>(0.0, (prev, element) => prev + element.balance);
    return _formatCurrency(sum);
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
    return buffer.toString();
  }

  String get totalTitle {
    return selectedWallet == null ? 'Gran total' : 'Total';
  }

  String get walletsSectionTitle {
    return selectedWallet == null ? 'Billeteras' : 'Billeteras / Transferir';
  }

  int get movementsCount {
    return selectedWallet != null ? 1 : 2; // Keep placeholder logic or adjust
  }
}
