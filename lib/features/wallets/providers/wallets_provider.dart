import 'package:flutter/material.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';
import 'package:alza/features/wallets/services/wallets_service.dart';

class WalletsProvider extends ChangeNotifier {
  final WalletsService _service = WalletsService();

  List<Wallet> _wallets = [];
  List<Wallet> get wallets => _wallets;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  /// Carga la lista de billeteras desde el backend.
  Future<bool> fetchWallets() async {
    _setLoading(true);
    _setError(null);

    final response = await _service.getWallets();
    if (response.success && response.data != null) {
      _wallets = response.data!;
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Crea una billetera en el backend e incrementa el listado local.
  Future<bool> createWallet({
    required String name,
    required double balance,
    required IconData icon,
    required Color color,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.createWallet(
      name: name,
      balance: balance,
      icon: icon,
      color: color,
    );

    if (response.success && response.data != null) {
      _wallets.add(response.data!);
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Actualiza los datos de una billetera y actualiza el listado local.
  Future<bool> updateWallet(
    String id, {
    String? name,
    double? balance,
    IconData? icon,
    Color? color,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.updateWallet(
      id,
      name: name,
      balance: balance,
      icon: icon,
      color: color,
    );

    if (response.success && response.data != null) {
      final index = _wallets.indexWhere((w) => w.id == id);
      if (index != -1) {
        _wallets[index] = response.data!;
      }
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Elimina una billetera y actualiza el listado local.
  Future<bool> deleteWallet(String id) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.deleteWallet(id);
    if (response.success) {
      _wallets.removeWhere((w) => w.id == id);
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Método de soporte para insertar localmente (ej: acción de Deshacer eliminación)
  /// Si el backend lo requiere, se podría recrear la billetera en su lugar.
  void insertWalletLocally(int index, Wallet wallet) {
    if (index >= 0 && index <= _wallets.length) {
      _wallets.insert(index, wallet);
      notifyListeners();
    }
  }
}
