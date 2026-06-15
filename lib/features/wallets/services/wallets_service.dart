import 'package:alza/core/network/api_response.dart';
import 'package:alza/core/network/api_service.dart';
import 'package:alza/features/wallets/models/wallet_model.dart';
import 'package:alza/features/wallets/models/transfer_model.dart';
import 'package:flutter/material.dart';

class WalletsService {
  final ApiService _apiService = ApiService();

  /// Obtiene todas las billeteras del usuario autenticado.
  Future<ApiResponse<List<Wallet>>> getWallets() async {
    final response = await _apiService.getWallets();
    if (response.success && response.data != null) {
      try {
        final walletsList = (response.data as List)
            .map((item) => Wallet.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Wallet>>(
          success: true,
          message: response.message,
          data: walletsList,
        );
      } catch (e) {
        return ApiResponse<List<Wallet>>(
          success: false,
          message: 'Error al procesar los datos de las billeteras: $e',
        );
      }
    }
    return ApiResponse<List<Wallet>>(
      success: false,
      message: response.message,
    );
  }

  /// Obtiene los detalles de una billetera por su ID.
  Future<ApiResponse<Wallet>> getWalletById(String walletId) async {
    final response = await _apiService.getWalletById(walletId);
    if (response.success && response.data != null) {
      try {
        return ApiResponse<Wallet>(
          success: true,
          message: response.message,
          data: Wallet.fromJson(response.data!),
        );
      } catch (e) {
        return ApiResponse<Wallet>(
          success: false,
          message: 'Error al procesar los datos de la billetera: $e',
        );
      }
    }
    return ApiResponse<Wallet>(
      success: false,
      message: response.message,
    );
  }

  /// Crea una nueva billetera en el backend.
  Future<ApiResponse<Wallet>> createWallet({
    required String name,
    required double balance,
    required IconData icon,
    required Color color,
  }) async {
    final payload = {
      'name': name,
      'balance': balance,
    };

    final response = await _apiService.createWallet(payload);
    if (response.success && response.data != null) {
      try {
        return ApiResponse<Wallet>(
          success: true,
          message: response.message,
          data: Wallet.fromJson(response.data!),
        );
      } catch (e) {
        return ApiResponse<Wallet>(
          success: false,
          message: 'Error al procesar la billetera creada: $e',
        );
      }
    }
    return ApiResponse<Wallet>(
      success: false,
      message: response.message,
    );
  }

  /// Actualiza una billetera en el backend.
  Future<ApiResponse<Wallet>> updateWallet(
    String walletId, {
    String? name,
    double? balance,
    IconData? icon,
    Color? color,
  }) async {
    final Map<String, dynamic> payload = {};
    if (name != null) payload['name'] = name;
    if (balance != null) payload['balance'] = balance;

    final response = await _apiService.updateWallet(walletId, payload);
    if (response.success && response.data != null) {
      try {
        return ApiResponse<Wallet>(
          success: true,
          message: response.message,
          data: Wallet.fromJson(response.data!),
        );
      } catch (e) {
        return ApiResponse<Wallet>(
          success: false,
          message: 'Error al procesar la billetera actualizada: $e',
        );
      }
    }
    return ApiResponse<Wallet>(
      success: false,
      message: response.message,
    );
  }

  /// Elimina una billetera del backend.
  Future<ApiResponse<void>> deleteWallet(String walletId) async {
    final response = await _apiService.deleteWallet(walletId);
    return ApiResponse<void>(
      success: response.success,
      message: response.message,
    );
  }

  /// Realiza una transferencia de dinero entre billeteras.
  Future<ApiResponse<Transfer>> createTransfer({
    required String originWalletId,
    required String destWalletId,
    required double amount,
  }) async {
    final payload = {
      'origin_wallet_id': originWalletId,
      'dest_wallet_id': destWalletId,
      'amount': amount,
    };

    final response = await _apiService.createTransfer(payload);
    if (response.success && response.data != null) {
      try {
        return ApiResponse<Transfer>(
          success: true,
          message: response.message,
          data: Transfer.fromJson(response.data!),
        );
      } catch (e) {
        return ApiResponse<Transfer>(
          success: false,
          message: 'Error al procesar los datos de la transferencia: $e',
        );
      }
    }
    return ApiResponse<Transfer>(
      success: false,
      message: response.message,
    );
  }

  /// Obtiene el historial de transferencias.
  Future<ApiResponse<List<Transfer>>> getTransfers() async {
    final response = await _apiService.getTransfers();
    if (response.success && response.data != null) {
      try {
        final transfersList = (response.data as List)
            .map((item) => Transfer.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Transfer>>(
          success: true,
          message: response.message,
          data: transfersList,
        );
      } catch (e) {
        return ApiResponse<List<Transfer>>(
          success: false,
          message: 'Error al procesar el listado de transferencias: $e',
        );
      }
    }
    return ApiResponse<List<Transfer>>(
      success: false,
      message: response.message,
    );
  }
}
