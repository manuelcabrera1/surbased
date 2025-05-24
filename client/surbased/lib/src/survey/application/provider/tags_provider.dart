import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/tag_model.dart';
import 'package:surbased/src/survey/infrastructure/tag_service.dart';

class TagsProvider extends ChangeNotifier {
  final TagService _tagService = TagService();
  List<Tag> _tags = [];
  bool _isLoading = false;
  String? _error;

  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getTags(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      final response = await _tagService.getTags(token);
      if (response['success']) {
        _tags = (response['data'] as List<dynamic>).map((x) => Tag.fromJson(x)).toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        _error = response['data'];
        _isLoading = false;
        notifyListeners();
      }
    } catch(e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
    
  }
  
  
}

