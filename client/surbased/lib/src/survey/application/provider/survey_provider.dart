import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/survey/infrastructure/survey_service.dart';

import '../../../user/domain/user_model.dart';

class SurveyProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  List<Survey> _publicSurveys = [];
  List<Survey> _surveysOwned = [];
  bool _isLoading = false;
  String? _error;
  Survey? _currentSurvey;

  List<Survey> get publicSurveys => _publicSurveys;
  List<Survey> get surveysOwned => _surveysOwned;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Survey? get currentSurvey => _currentSurvey;

  set currentSurvey(Survey? value) {
    _currentSurvey = value;
    notifyListeners();
  }


  void clearState() {
    _isLoading = false;
    _error = null;
    _publicSurveys = [];
    _surveysOwned = [];
    _currentSurvey = null;
    notifyListeners();
  }

  void clearCurrentSurvey() {
    _currentSurvey = null;
    notifyListeners();
  }

  bool addOrUpdateSurveyInfo(String name, String? description, DateTime startDate,
      DateTime? endDate, String categoryId, String ownerId) {
    if (_currentSurvey != null) {
      _currentSurvey!.name = name;
      _currentSurvey!.description = description ?? '';
      _currentSurvey!.categoryId = categoryId;
      _currentSurvey!.startDate = startDate;
      _currentSurvey!.endDate = endDate;
      notifyListeners();
      return true;
    } else {
      _currentSurvey = Survey(
        name: name,
        description: description ?? '',
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      questions: [],
      ownerId: ownerId,
    );
    notifyListeners();
    return true;
    }
  }


  bool addQuestion(Question question) {
    _currentSurvey!.questions.add(question);
    notifyListeners();
    return true;
  }

  bool updateQuestion(int index, Question question) {
    _currentSurvey!.questions[index] = question;
    notifyListeners();
    return true;
  }

  bool insertQuestion(int index, Question question) {
    _currentSurvey!.questions.insert(index, question);
    notifyListeners();
    return true;
  }

  bool removeQuestion(int index) {
    _currentSurvey!.questions.removeAt(index);
    notifyListeners();
    return true;
  }

  Future<bool> createSurvey(String token, String scope, {String? organizationId}) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      _currentSurvey!.scope = scope;
      _currentSurvey!.organizationId = organizationId;
      
      final response = await _surveyService.createSurvey(
        _currentSurvey!.toJson(),
        token,
      );

      if (response['success']) {
        _surveysOwned.add(_currentSurvey!);
        _isLoading = false;
        _error = null;
        _currentSurvey = null;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = response['data'];
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

  Future<void> getPublicSurveys(String token, {String? category}) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final getSurveysResponse = await _surveyService.getPublicSurveys(
        token,
        category: category,
        );

      if (getSurveysResponse['success']) {
        _publicSurveys = (getSurveysResponse['data']['surveys'] as List<dynamic>)
            .map((s) => Survey.fromJson(s))
            .toList();
        _error = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = getSurveysResponse['error'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSurveysByOwner(String ownerId, String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final getSurveysResponse = await _surveyService.getSurveysByOwner(
        ownerId,
        token,
      );
        
      if (getSurveysResponse['success']) {
        _surveysOwned = (getSurveysResponse['data']['surveys'] as List<dynamic>)
            .map((s) => Survey.fromJson(s))
            .toList();
        _error = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = getSurveysResponse['error'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }




  Future<void> getUsersAssignedToSurvey(String surveyId, String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final getSurveyUsersResponse =
          await _surveyService.getUsersAssignedToSurvey(
        surveyId,
        token,
      );

      if (getSurveyUsersResponse['success']) {
        _currentSurvey!.assignedUsers =
            (getSurveyUsersResponse['data']['users'] as List<dynamic>)
                .map((s) => User.fromJson(s))
                .toList();
        _error = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = getSurveyUsersResponse['data'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeSurvey(String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final response = await _surveyService.removeSurvey(
        _currentSurvey!.id!,
        token,
      );

      if (response['success']) {
        _surveysOwned.removeWhere((survey) => survey.id == _currentSurvey!.id);

        _isLoading = false;
        _error = null;
        _currentSurvey = null;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = response['data'];
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
