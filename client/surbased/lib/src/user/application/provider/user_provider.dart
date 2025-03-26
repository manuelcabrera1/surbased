import 'package:flutter/material.dart';
import 'package:surbased/src/user/infrastructure/user_service.dart';

import '../../domain/user_model.dart';

class UserProvider with ChangeNotifier {

  final UserService _userService = UserService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  
  


  Future<User?> getUserById(String userId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userResponse = await _userService.getUserById(userId, token);
      if (userResponse['success']) {
        _isLoading = false;
        _error = null;
        notifyListeners();
        return User.fromJson(userResponse['data']);

      } else {
        _error = userResponse['data'];
        _isLoading = false;
        notifyListeners();
        return null;
      }

    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }

  }
}

