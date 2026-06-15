import 'package:flutter/material.dart';
import 'package:alza/features/wallets/models/wallet_model.dart' as model;

class HomeProvider extends ChangeNotifier {
  List<model.Wallet> _realWallets = [];
  List<model.Wallet> get wallets => _realWallets;

  void setRealWallets(List<model.Wallet> wallets) {
    // Avoid redundant calls and rebuild loops
    bool changed = _realWallets.length != wallets.length;
    if (!changed) {
      for (int i = 0; i < wallets.length; i++) {
        if (_realWallets[i].id != wallets[i].id || 
            _realWallets[i].balance != wallets[i].balance ||
            _realWallets[i].name != wallets[i].name) {
          changed = true;
          break;
        }
      }
    }
    if (changed) {
      debugPrint('[HOME PROVIDER] Sincronizando ${_realWallets.length} -> ${wallets.length} billeteras reales.');
      _realWallets = List.from(wallets);
      notifyListeners();
    }
  }

  String _selectedWalletId = '';
  String get selectedWalletId => _selectedWalletId;

  String get selectedWalletName {
    final selected = selectedWallet;
    return selected?.name ?? '';
  }

  void selectWallet(String walletName) {
    if (_realWallets.isEmpty) return;
    try {
      final wallet = _realWallets.firstWhere((w) => w.name == walletName);
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
      return _realWallets.firstWhere((w) => w.id == _selectedWalletId);
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
    final sum = _realWallets.fold<double>(0.0, (prev, element) => prev + element.balance);
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
