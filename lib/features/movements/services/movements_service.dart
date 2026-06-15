import 'package:alza/core/network/api_response.dart';
import 'package:alza/core/network/api_service.dart';
import 'package:alza/features/movements/models/category_model.dart';
import 'package:alza/features/movements/models/tag_model.dart';
import 'package:alza/features/movements/models/movement_model.dart';

class MovementsService {
  final ApiService _apiService = ApiService();

  /// Obtiene todas las categorías del usuario.
  Future<ApiResponse<List<Category>>> getCategories() async {
    final response = await _apiService.getCategories();
    if (response.success && response.data != null) {
      try {
        final list = (response.data as List)
            .map((item) => Category.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Category>>(
          success: true,
          message: response.message,
          data: list,
        );
      } catch (e) {
        return ApiResponse<List<Category>>(
          success: false,
          message: 'Error al procesar las categorías: $e',
        );
      }
    }
    return ApiResponse<List<Category>>(
      success: false,
      message: response.message,
    );
  }

  /// Crea una nueva categoría.
  Future<ApiResponse<Category>> createCategory(String name) async {
    final response = await _apiService.createCategory({'name': name});
    if (response.success && response.data != null) {
      try {
        return ApiResponse<Category>(
          success: true,
          message: response.message,
          data: Category.fromJson(response.data!),
        );
      } catch (e) {
        return ApiResponse<Category>(
          success: false,
          message: 'Error al procesar la categoría creada: $e',
        );
      }
    }
    return ApiResponse<Category>(
      success: false,
      message: response.message,
    );
  }

  /// Obtiene todas las etiquetas (tags) del usuario.
  Future<ApiResponse<List<Tag>>> getTags() async {
    final response = await _apiService.getTags();
    if (response.success && response.data != null) {
      try {
        final list = (response.data as List)
            .map((item) => Tag.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Tag>>(
          success: true,
          message: response.message,
          data: list,
        );
      } catch (e) {
        return ApiResponse<List<Tag>>(
          success: false,
          message: 'Error al procesar las etiquetas: $e',
        );
      }
    }
    return ApiResponse<List<Tag>>(
      success: false,
      message: response.message,
    );
  }

  /// Crea una nueva etiqueta (tag).
  Future<ApiResponse<Tag>> createTag(String name) async {
    final response = await _apiService.createTag({'name': name});
    if (response.success && response.data != null) {
      try {
        return ApiResponse<Tag>(
          success: true,
          message: response.message,
          data: Tag.fromJson(response.data!),
        );
      } catch (e) {
        return ApiResponse<Tag>(
          success: false,
          message: 'Error al procesar la etiqueta creada: $e',
        );
      }
    }
    return ApiResponse<Tag>(
      success: false,
      message: response.message,
    );
  }

  /// Obtiene todos los movimientos/transacciones.
  Future<ApiResponse<List<Movement>>> getTransactions({String? walletId}) async {
    final Map<String, dynamic> query = {};
    if (walletId != null && walletId.isNotEmpty) {
      query['wallet_id'] = walletId;
    }
    query['limit'] = 50;

    final response = await _apiService.getTransactions(queryParameters: query);
    if (response.success && response.data != null) {
      try {
        final list = (response.data as List)
            .map((item) => Movement.fromJson(item as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Movement>>(
          success: true,
          message: response.message,
          data: list,
        );
      } catch (e) {
        return ApiResponse<List<Movement>>(
          success: false,
          message: 'Error al procesar los movimientos: $e',
        );
      }
    }
    return ApiResponse<List<Movement>>(
      success: false,
      message: response.message,
    );
  }

  /// Crea un nuevo movimiento en base de datos.
  Future<ApiResponse<Movement>> createTransaction({
    required String title,
    String? description,
    required double amount,
    required String type,
    required String walletId,
    required String categoryId,
    List<String>? tagIds,
  }) async {
    final payload = {
      'title': title,
      if (description != null) 'description': description,
      'amount': amount,
      'type': type,
      'wallet_id': walletId,
      'category_id': categoryId,
      'tag_ids': tagIds ?? [],
    };

    final response = await _apiService.createTransaction(payload);
    if (response.success && response.data != null) {
      try {
        return ApiResponse<Movement>(
          success: true,
          message: response.message,
          data: Movement.fromJson(response.data!),
        );
      } catch (e) {
        return ApiResponse<Movement>(
          success: false,
          message: 'Error al procesar el movimiento creado: $e',
        );
      }
    }
    return ApiResponse<Movement>(
      success: false,
      message: response.message,
    );
  }

  /// Obtiene el conteo de movimientos asociados a una billetera.
  Future<ApiResponse<int>> getTransactionCount(String walletId) async {
    final response = await _apiService.getTransactionCount(walletId);
    if (response.success && response.data != null) {
      try {
        final count = (response.data!['count'] as num).toInt();
        return ApiResponse<int>(
          success: true,
          message: response.message,
          data: count,
        );
      } catch (e) {
        return ApiResponse<int>(
          success: false,
          message: 'Error al procesar el conteo de transacciones: $e',
        );
      }
    }
    return ApiResponse<int>(
      success: false,
      message: response.message,
    );
  }
}
