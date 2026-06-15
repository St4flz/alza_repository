import 'package:dio/dio.dart';
import 'package:alza/core/network/dio_client.dart';
import 'package:alza/core/network/api_response.dart';
import 'package:alza/core/config/env_config.dart';

/// Servicio centralizado de comunicación con el Backend.
///
/// Todas las peticiones HTTP y endpoints del proyecto se definen aquí de forma
/// unificada. Para cambiar la URL de conexión, edita el valor de `API_BASE_URL` en tu `.env`.
class ApiService {
  final Dio _dio = DioClient().dio;

  /// Ruta base del backend con sufijo `/api/v1/` dinámico y seguro.
  static String get baseUrl {
    final base = EnvConfig.apiBaseUrl;
    if (base.isEmpty) return '';
    final sanitizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return '$sanitizedBase/api/v1';
  }

  // =========================================================================
  // 1. ENDPOINTS CENTRALIZADOS (AGREGA O EDITA TUS ENDPOINTS AQUÍ)
  // =========================================================================

  /// Endpoint de ejemplo para obtener el perfil del usuario autenticado.
  /// (El backend obtiene el `user_id` del token JWT automáticamente).
  Future<ApiResponse<Map<String, dynamic>>> getUserProfile() async {
    return _request<Map<String, dynamic>>(
      method: 'GET',
      path: '/user/profile',
    );
  }

  /// Endpoint para obtener la lista de billeteras del usuario.
  Future<ApiResponse<List<dynamic>>> getWallets() async {
    return _request<List<dynamic>>(
      method: 'GET',
      path: '/wallets',
    );
  }

  /// Endpoint para crear una nueva billetera.
  Future<ApiResponse<Map<String, dynamic>>> createWallet(Map<String, dynamic> data) async {
    return _request<Map<String, dynamic>>(
      method: 'POST',
      path: '/wallets',
      data: data,
    );
  }

  /// Endpoint para obtener el detalle de una billetera específica.
  Future<ApiResponse<Map<String, dynamic>>> getWalletById(String walletId) async {
    return _request<Map<String, dynamic>>(
      method: 'GET',
      path: '/wallets/$walletId',
    );
  }

  /// Endpoint para actualizar los datos de una billetera.
  Future<ApiResponse<Map<String, dynamic>>> updateWallet(String walletId, Map<String, dynamic> data) async {
    return _request<Map<String, dynamic>>(
      method: 'PATCH',
      path: '/wallets/$walletId',
      data: data,
    );
  }

  /// Endpoint para eliminar una billetera.
  Future<ApiResponse<Map<String, dynamic>>> deleteWallet(String walletId) async {
    return _request<Map<String, dynamic>>(
      method: 'DELETE',
      path: '/wallets/$walletId',
    );
  }

  /// Endpoint para eliminar la cuenta de usuario y todos sus datos relacionados.
  Future<ApiResponse<Map<String, dynamic>>> deleteUserAccount() async {
    return _request<Map<String, dynamic>>(
      method: 'DELETE',
      path: '/users/me',
    );
  }

  /// Endpoint para realizar una transferencia de saldo entre billeteras.
  Future<ApiResponse<Map<String, dynamic>>> createTransfer(Map<String, dynamic> data) async {
    return _request<Map<String, dynamic>>(
      method: 'POST',
      path: '/transfers',
      data: data,
    );
  }

  /// Endpoint para obtener las transferencias del usuario.
  Future<ApiResponse<List<dynamic>>> getTransfers() async {
    return _request<List<dynamic>>(
      method: 'GET',
      path: '/transfers',
    );
  }

  /// Obtiene el listado de categorías del usuario.
  Future<ApiResponse<List<dynamic>>> getCategories() async {
    return _request<List<dynamic>>(
      method: 'GET',
      path: '/categories',
    );
  }

  /// Crea una nueva categoría.
  Future<ApiResponse<Map<String, dynamic>>> createCategory(Map<String, dynamic> data) async {
    return _request<Map<String, dynamic>>(
      method: 'POST',
      path: '/categories',
      data: data,
    );
  }

  /// Obtiene el listado de etiquetas (tags) del usuario.
  Future<ApiResponse<List<dynamic>>> getTags() async {
    return _request<List<dynamic>>(
      method: 'GET',
      path: '/tags',
    );
  }

  /// Crea una nueva etiqueta.
  Future<ApiResponse<Map<String, dynamic>>> createTag(Map<String, dynamic> data) async {
    return _request<Map<String, dynamic>>(
      method: 'POST',
      path: '/tags',
      data: data,
    );
  }

  /// Obtiene el listado de movimientos/transacciones.
  Future<ApiResponse<List<dynamic>>> getTransactions({Map<String, dynamic>? queryParameters}) async {
    return _request<List<dynamic>>(
      method: 'GET',
      path: '/transactions',
      queryParameters: queryParameters,
    );
  }

  /// Crea un nuevo movimiento/transacción.
  Future<ApiResponse<Map<String, dynamic>>> createTransaction(Map<String, dynamic> data) async {
    return _request<Map<String, dynamic>>(
      method: 'POST',
      path: '/transactions',
      data: data,
    );
  }

  /// Obtiene el conteo de movimientos para una billetera en particular.
  Future<ApiResponse<Map<String, dynamic>>> getTransactionCount(String walletId) async {
    return _request<Map<String, dynamic>>(
      method: 'GET',
      path: '/transactions/count',
      queryParameters: {'wallet_id': walletId},
    );
  }

  // =========================================================================
  // 2. MÉTODOS DE PETICIÓN AUXILIARES GENÉRICOS (NO MODIFICAR)
  // =========================================================================

  /// Método genérico centralizado para formatear peticiones, adjuntar rutas
  /// y parsear respuestas automáticamente al formato estándar `ApiResponse<T>`.
  Future<ApiResponse<T>> _request<T>({
    required String method,
    required String path,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    try {
      final String fullUrl = path.startsWith('http') ? path : '$baseUrl$path';

      final response = await _dio.request(
        fullUrl,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      if (response.data is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(
          response.data as Map<String, dynamic>,
          (json) => json as T,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: 'El servidor retornó un formato de datos inesperado.',
        );
      }
    } on DioException catch (e) {
      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(
          responseData,
          (json) => json as T,
        );
      }
      return ApiResponse<T>(
        success: false,
        message: e.message ?? 'Ocurrió un error al conectar con el servidor.',
      );
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
      );
    }
  }
}
