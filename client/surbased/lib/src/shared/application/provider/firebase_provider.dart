import 'package:flutter/material.dart';
import 'package:surbased/src/shared/infrastructure/firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';

class FirebaseProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _notificationsEnabled = false;
  String? _error;
  final FirebaseService _firebaseService = FirebaseService();
  String? _token;

  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get notificationsEnabled => _notificationsEnabled;

  set notificationsEnabled(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  Future<void> initNotifications() async {
    _token = await _firebaseService.initNotifications();
    
    if (await Permission.notification.status.isDenied) {
      _notificationsEnabled = false;
    } else {
      _notificationsEnabled = true;
    }
    notifyListeners();
  }

  Future<bool> sendFcmToken(String jwtToken, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _firebaseService.sendFcmToken(jwtToken, userId, _token!);
      if (response['success']) {
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
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


  Future<bool> deleteFcmToken(String jwtToken, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {

      final response = await _firebaseService.deleteFcmToken(jwtToken, userId, _token!);
      if (response['success']) {
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
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

}

