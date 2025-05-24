import 'package:flutter/material.dart';
import 'package:surbased/src/category/infrastructure/category_service.dart';

import '../../domain/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearState() {
    _isLoading = false;
    _error = null;
    _categories = [];
    notifyListeners();
  }

  Future<void> getCategories(String? organizationId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final categoriesResponse =
          await _categoryService.getCategories(organizationId, token);

      if (categoriesResponse['success']) {
        _categories =
            (categoriesResponse['data'] as List<dynamic>)
                .map((c) => Category.fromJson(c))
                .toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        _isLoading = false;
        _error = categoriesResponse['data'];
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Category getCategoryById(String id) {
    return _categories.firstWhere(
      (c) => c.id == id,
      orElse: () => Category(
        id: '',
        name: '',
      ),
    );
  }
}
