import 'package:flutter/material.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';
import 'package:alza/features/wallets/models/transfer_model.dart';
import 'package:alza/features/wallets/services/wallets_service.dart';
import 'package:alza/app/style/app_colors.dart';

class WalletsProvider extends ChangeNotifier {
  final WalletsService _service = WalletsService();

  List<Wallet> _wallets = [];
  List<Wallet> get wallets => _wallets;

  List<Transfer> _transfers = [];
  List<Transfer> get transfers => _transfers;

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

  /// Verifica y configura las billeteras iniciales.
  /// Si la lista está vacía, crea la billetera "Efectivo" automáticamente.
  /// Retorna true si se creó una nueva billetera por defecto.
  Future<bool> checkAndSetupWallets() async {
    debugPrint('[WALLETS PROVIDER] Cargando billeteras del backend...');
    final success = await fetchWallets();
    if (success) {
      debugPrint('[WALLETS PROVIDER] Billeteras reales encontradas: ${_wallets.length}');
      if (_wallets.isEmpty) {
        debugPrint('[WALLETS PROVIDER] No se encontraron billeteras. Creando "Efectivo" automáticamente...');
        final createSuccess = await createWallet(
          name: 'Efectivo',
          balance: 0.0,
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.verde.solid,
        );
        return createSuccess;
      }
    } else {
      debugPrint('[WALLETS PROVIDER] ERROR al obtener billeteras: $errorMessage');
    }
    return false;
  }

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
      // Forzamos el icono y color seleccionados por si el backend no los devuelve
      final newWallet = response.data!;
      newWallet.icon = icon;
      newWallet.color = color;
      
      _wallets.add(newWallet);
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

  /// Carga el historial de transferencias desde el backend.
  Future<bool> fetchTransfers() async {
    _setLoading(true);
    _setError(null);

    final response = await _service.getTransfers();
    if (response.success && response.data != null) {
      _transfers = response.data!;
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Realiza una transferencia e interactúa con el backend para actualizar balances localmente.
  Future<bool> createTransfer({
    required String originWalletId,
    required String destWalletId,
    required double amount,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.createTransfer(
      originWalletId: originWalletId,
      destWalletId: destWalletId,
      amount: amount,
    );

    if (response.success && response.data != null) {
      // Agregar la transferencia exitosa al listado local
      _transfers.insert(0, response.data!);
      
      // Volver a cargar las billeteras para actualizar los saldos reales
      await fetchWallets();
      
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }
}
