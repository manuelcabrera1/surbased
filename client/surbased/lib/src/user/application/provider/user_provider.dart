import 'package:flutter/material.dart';
import 'package:surbased/src/user/infrastructure/user_service.dart';

import '../../domain/user_model.dart';

class UserProvider with ChangeNotifier {

  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<User> get users => _users;
  


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

  Future<User?> getUserByEmail(String email, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userResponse = await _userService.getUserByEmail(email, token);
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

  String getUserEmail(String userId) {
    if (_users.isEmpty) {
      return '';
    }
    return _users.firstWhere((user) => user.id == userId).email;
  }

  Future<void> getUsers(String token, String? org, String? role) async {
    _error = null;
    _isLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> getUsersResponse = await _userService.getUsers(token, org, role);
    
      if (getUsersResponse['success']) {
        _users = (getUsersResponse['data'] as List<dynamic>)
            .map((user) => User.fromJson(user))
            .toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        _isLoading = false;
        _error = getUsersResponse['data'];
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}

