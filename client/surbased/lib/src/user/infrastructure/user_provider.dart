import 'package:flutter/material.dart';
import 'package:surbased/src/user/domain/user_model.dart';
import 'package:surbased/src/user/infrastructure/user_service.dart';

class UserProvider with ChangeNotifier {
  final _userService = UserService();
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<User?> updateUser(String id, String name, String lastname,
      String email, String birthdate, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isUpdated = await _userService.updateUser(
          id, name, lastname, email, birthdate, token);
      if (isUpdated['success']) {
        _isLoading = false;
        _error = null;
        notifyListeners();
        return User.fromJson(isUpdated['data']);
      } else {
        _isLoading = false;
        _error = isUpdated['data'];
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

  Future<bool> updateUserPassword(
      String id, String password, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isUpdated =
          await _userService.updateUserPassword(id, password, token);
      if (isUpdated['success']) {
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = isUpdated['data'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
