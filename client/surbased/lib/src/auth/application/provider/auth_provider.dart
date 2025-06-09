import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surbased/src/shared/infrastructure/mail_service.dart';
import 'package:surbased/src/survey/domain/answer_model.dart';
import '../../../survey/domain/survey_model.dart';
import '../../infrastructure/auth_service.dart';
import 'package:surbased/src/user/domain/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final MailService _mailService = MailService();
  bool _isAuthenticated = false;
  String? _token;
  String? _error;
  User? _user;
  final _prefs = SharedPreferences.getInstance();
  bool _isLoading = false;
  List<User> _users = [];
  List<Survey> _surveysAssigned = [];
  int? _resetCode;
  List<Answer> _surveysAnswers = [];
  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get userId => _user?.id;
  String? get userRole => _user?.role;
  List<User> get users => _users;
  List<Survey> get surveysAssigned => _surveysAssigned;
  int? get resetCode => _resetCode;
  List<Answer> get surveysAnswers => _surveysAnswers;

  void clearResetCode() {
    _resetCode = null;
    notifyListeners();
  }

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

  Future<bool> register(String name, String lastname, String role, String organization,
      String email, String password, String birthdate, String gender) async {
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final registerResponse = await _authService.register(name, lastname,
          role, organization, email, password, birthdate, gender);

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

  Future<bool> updateUser(String id, String token, {String? name, String? lastname, String? role, String? organization, String? email,
      String? birthdate, String? gender, bool? isCurrentUser = true}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isUpdated = await _authService.updateUser(
          id, token, name: name, lastname: lastname, role: role, organization: organization, email: email, birthdate: birthdate, gender: gender);
      if (isUpdated['success']) {
        if (isCurrentUser == true) {
          _user = User.fromJson(isUpdated['data']);
        }
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

  Future<bool> updateUserNotifications(
      String id, bool notifications, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isUpdated =
          await _authService.updateUserNotifications(id, notifications, token);
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

  Future<bool> resetUserPassword(
      String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isUpdated =
          await _authService.resetUserPassword(email, password);
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
  

  Future<bool> sendForgotPasswordMail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final isSent = await _mailService.sendForgotPasswordMail(email);
      if (isSent['success']) {
        _resetCode = isSent['data']['reset_code'];
        _isLoading = false;
        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = isSent['data'];
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

  Future<bool> checkToken() async {
    _isLoading = true;
    notifyListeners();
    
    final prefs = await _prefs;
    final token = prefs.getString('token');
    
    if (token == null) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      _token = token;
      final userDataResult = await _authService.getCurrentUser(token);

      if (userDataResult['success']) {
        _user = User.fromJson(userDataResult['data']);
        _isAuthenticated = true;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _token = null;
        _isAuthenticated = false;
        _isLoading = false;
        await prefs.remove('token');
        await prefs.remove('email');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _token = null;
      _isAuthenticated = false;
      _isLoading = false;
      await prefs.remove('token');
      await prefs.remove('email');
      notifyListeners();
      return false;
    }
  }

   Future<List<Survey>> getSurveysAssignedToUser(String userId, String token, {String? category, bool? isCurrentUser= true}) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final getSurveysResponse = await _authService.getSurveysAssignedToUser(
        userId,
        token,
        category: category,
      );
        
      if (getSurveysResponse['success']) {
        List<Survey> surveys = (getSurveysResponse['data']['surveys'] as List<dynamic>)
            .map((s) => Survey.fromJson(s))
            .toList();

        if (isCurrentUser == true) {
          _surveysAssigned = surveys;
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
        return surveys;
      } else {
        _error = getSurveysResponse['error'];
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<List<Answer>> getSurveysAnswers(String userId, String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final getSurveysResponse = await _authService.getSurveysAnswers(
        userId,
        token,
      );
        
      if (getSurveysResponse['success']) {
        List<Answer> answers = (getSurveysResponse['data']['answers'] as List<dynamic>)
            .map((s) => Answer.fromJson(s))
            .toList();

        _surveysAnswers = answers;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return answers;
      } else {
        _error = getSurveysResponse['error'];
        _isLoading = false;
        notifyListeners();
        return [];
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<bool> acceptSurveyAssignment(String userId, String surveyId, String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      if (user == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final getSurveysResponse = await _authService.acceptSurveyAssignment(
        userId,
        surveyId,
        token,
      );
        
      if (getSurveysResponse['success']) {
        _surveysAssigned.add(Survey.fromJson(getSurveysResponse['data']));
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = getSurveysResponse['data'];
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

  Future<bool> rejectSurveyAssignment(String userId, String surveyId, String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      if (user == null) {
        _error = 'Not authenticated';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final getSurveysResponse = await _authService.rejectSurveyAssignment(
        userId,
        surveyId,
        token,
      );
        
      if (getSurveysResponse['success']) {
        _surveysAssigned.removeWhere((survey) => survey.id == surveyId);
        _error = null;
        _isLoading = false;
        notifyListeners();  
        return true;
      } else {
        _error = getSurveysResponse['data'];
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

  Future<bool> deleteUser(String id, String? password, String token, {bool isCurrentUser = true}) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final isDeleted = await _authService.deleteUser(id, password, token);

      if (isDeleted['success']) {
        if (isCurrentUser) {
          await _clearAuthState();
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = isDeleted['data'];
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
