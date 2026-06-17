import 'package:flutter/material.dart';
import 'package:alza/features/movements/models/category_model.dart';
import 'package:alza/features/movements/models/tag_model.dart';
import 'package:alza/features/movements/models/movement_model.dart';
import 'package:alza/features/movements/services/movements_service.dart';

class MovementsProvider extends ChangeNotifier {
  final MovementsService _service = MovementsService();

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Tag> _tags = [];
  List<Tag> get tags => _tags;

  List<Movement> _movements = [];
  List<Movement> get movements => _movements;

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

  /// Carga la lista de categorías del usuario.
  Future<bool> fetchCategories() async {
    _setLoading(true);
    _setError(null);

    final response = await _service.getCategories();
    if (response.success && response.data != null) {
      _categories = response.data!;
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Crea una nueva categoría.
  Future<Category?> createCategory(String name) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.createCategory(name);
    if (response.success && response.data != null) {
      _categories.add(response.data!);
      _setLoading(false);
      return response.data;
    } else {
      _setError(response.message);
      _setLoading(false);
      return null;
    }
  }

  /// Carga la lista de etiquetas del usuario.
  Future<bool> fetchTags() async {
    _setLoading(true);
    _setError(null);

    final response = await _service.getTags();
    if (response.success && response.data != null) {
      _tags = response.data!;
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Crea una nueva etiqueta.
  Future<Tag?> createTag(String name) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.createTag(name);
    if (response.success && response.data != null) {
      _tags.add(response.data!);
      _setLoading(false);
      return response.data;
    } else {
      _setError(response.message);
      _setLoading(false);
      return null;
    }
  }

  /// Carga el historial de movimientos de transacciones.
  Future<bool> fetchMovements({String? walletId}) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.getTransactions(walletId: walletId);
    if (response.success && response.data != null) {
      _movements = response.data!;
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Crea un nuevo movimiento y lo inserta al principio de la lista local.
  Future<bool> createMovement({
    required String title,
    String? description,
    required double amount,
    required String type,
    required String walletId,
    required String categoryId,
    List<String>? tagIds,
  }) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.createTransaction(
      title: title,
      description: description,
      amount: amount,
      type: type,
      walletId: walletId,
      categoryId: categoryId,
      tagIds: tagIds,
    );

    if (response.success && response.data != null) {
      _movements.insert(0, response.data!);
      _setLoading(false);
      return true;
    } else {
      _setError(response.message);
      _setLoading(false);
      return false;
    }
  }

  /// Obtiene el conteo de movimientos para una billetera.
  Future<int> fetchTransactionCount(String walletId) async {
    final response = await _service.getTransactionCount(walletId);
    if (response.success && response.data != null) {
      return response.data!;
    }
    return 0;
  }

  /// Procesa una imagen de recibo
  Future<Map<String, dynamic>?> processReceipt(String imageUrl) async {
    _setLoading(true);
    _setError(null);

    final response = await _service.processReceipt(imageUrl);
    _setLoading(false);
    
    if (response.success && response.data != null) {
      return response.data;
    } else {
      _setError(response.message);
      return null;
    }
  }
}
