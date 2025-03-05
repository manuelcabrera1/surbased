import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../infrastructure/auth_service.dart';
import 'package:surbased/src/user/domain/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;
  String? _token;
  String? _error;
  User? _user;
  final _prefs = SharedPreferences.getInstance();
  bool _isLoading = false;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get userId => _user?.id;
  String? get userRole => _user?.role;

  Future<bool> login(String email, String password) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final loginResponse = await _authService.login(email, password);

      if (loginResponse['success']) {
        _token = loginResponse['data']['access_token'];

        final getUserResponse = await _authService.getCurrentUser(_token!);

        if (getUserResponse['success']) {
          _user = User.fromJson(getUserResponse['data']);
          _isAuthenticated = true;
          _error = null;
          _isLoading = false;
          final prefs = await _prefs;
          prefs.setString('token', _token!);
          prefs.setString('email', _user!.email);
          notifyListeners();
          return true;
        } else {
          _error = getUserResponse['data'];
          _isAuthenticated = false;
          _token = null;
          _isLoading = false;
          notifyListeners();
          return false;
        }
      } else {
        _error = loginResponse['data'];
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _token = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String lastname, String organization,
      String email, String password, String birthdate, String gender) async {
    _error = null;
    _isLoading = true;
    String defaultRole = 'participant';
    notifyListeners();

    try {
      final registerResponse = await _authService.register(name, lastname,
          organization, email, password, defaultRole, birthdate, gender);

      if (registerResponse['success']) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = registerResponse['data'];
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _clearAuthState();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw Exception(_error);
    }
  }

  Future<void> _clearAuthState() async {
    _isAuthenticated = false;
    _token = null;
    _user = null;
    _error = null;
    _isLoading = false;

    final prefs = await _prefs;
    await prefs.clear();
  }

  void refreshUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> updateUser(String id, String name, String lastname, String email,
      String birthdate, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isUpdated = await _authService.updateUser(
          id, name, lastname, email, birthdate, token);
      if (isUpdated['success']) {
        _user = User.fromJson(isUpdated['data']);
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

  Future<bool> updateUserPassword(
      String id, String password, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isUpdated =
          await _authService.updateUserPassword(id, password, token);
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
