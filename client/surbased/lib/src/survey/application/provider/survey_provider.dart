import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/survey/domain/tag_model.dart';
import 'package:surbased/src/survey/infrastructure/survey_service.dart';

import '../../../user/domain/user_model.dart';

class SurveyProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  List<Survey> _publicSurveys = [];
  List<Survey> _highlightedPublicSurveys = [];
  List<Survey> _surveysOwned = [];
  bool _isLoading = false;
  String? _error;
  Survey? _currentSurvey;
  List<Survey> _privateSurveys = [];
  List<Survey> _organizationSurveys = [];
  List<String> _pendingAssignmentsInCurrentSurvey = [];

  List<Survey> get publicSurveys => _publicSurveys;
  List<Survey> get highlightedPublicSurveys => _highlightedPublicSurveys;
  List<Survey> get surveysOwned => _surveysOwned;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Survey? get currentSurvey => _currentSurvey;
  List<Survey> get privateSurveys => _privateSurveys;
  List<Survey> get organizationSurveys => _organizationSurveys;
  List<String> get pendingAssignmentsInCurrentSurvey => _pendingAssignmentsInCurrentSurvey;

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
    _pendingAssignmentsInCurrentSurvey = [];
    notifyListeners();
  }

  void clearCurrentSurvey() {
    _currentSurvey = null;
    _pendingAssignmentsInCurrentSurvey = [];
    notifyListeners();
  }

  bool addOrUpdateSurveyInfo(String name, String? description, DateTime startDate,
      DateTime endDate, String categoryId, String ownerId, List<String> selectedTags) {
    if (_currentSurvey != null) {
      _currentSurvey!.name = name;
      _currentSurvey!.description = description ?? '';
      _currentSurvey!.categoryId = categoryId;
      _currentSurvey!.startDate = startDate;
      _currentSurvey!.endDate = endDate;
      _currentSurvey!.tags = selectedTags.map((tag) => Tag(name: tag)).toList();
      notifyListeners();
      return true;
    } else {
      _currentSurvey = Survey(
        name: name,
        description: description ?? '',
        scope: 'private',
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
      questions: [],
      ownerId: ownerId,
      tags: selectedTags.map((tag) => Tag(name: tag)).toList(),
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

  Future<void> getSurveysByScope(String scope, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _surveyService.getSurveysByScope(scope, token);
      if (response['success']) {
        switch (scope) {
          case 'private':
            _privateSurveys = (response['data']['surveys'] as List<dynamic>).map((x) => Survey.fromJson(x)).toList();

            break;
          case 'organization':
            _organizationSurveys = (response['data']['surveys'] as List<dynamic>).map((x) => Survey.fromJson(x)).toList();

            break;
          case 'public':
            _publicSurveys = (response['data']['surveys'] as List<dynamic>).map((x) => Survey.fromJson(x)).toList();

            break;
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = response['data'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getHighlightedPublicSurveys(String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final getSurveysResponse = await _surveyService.getHighlightedPublicSurveys(
        token,
      );
      
      if (getSurveysResponse['success']) {
        _highlightedPublicSurveys = (getSurveysResponse['data']['surveys'] as List<dynamic>)
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
    if (_isLoading) return;
    
    try {
      _error = null;
      _isLoading = true;
      // Primera notificación para mostrar el estado de carga
      notifyListeners();

      final getSurveyUsersResponse =
          await _surveyService.getUsersAssignedToSurvey(
        surveyId,
        token,
      );

      if (getSurveyUsersResponse['success']) {
        final List<User> newAssignedUsers = (getSurveyUsersResponse['data']['users'] as List<dynamic>)
            .map((s) => User.fromJson(s))
            .toList();
            
        final List<String> newPendingAssignments = 
            List<String>.from(getSurveyUsersResponse['data']['pending_assignments']);

        _currentSurvey!.assignedUsers = newAssignedUsers;
        _pendingAssignmentsInCurrentSurvey = newPendingAssignments;
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
  bool checkIfAllSurveysBelongToAnOrganization(List<Survey> surveys) {
    return surveys.every((survey) => survey.organizationId != null);
  }

  Future<bool> addUserToSurvey(String surveyId, String email, String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final addUserToSurveyResponse =
          await _surveyService.addUserToSurvey(
        surveyId,
        email,
        token,
        "New survey assignment",
        "You have been requested to complete a new survey: ${_currentSurvey!.name}"
      );

      if (addUserToSurveyResponse['success']) {
        _currentSurvey!.assignedUsers!.add(User.fromJson(addUserToSurveyResponse['data']));
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = addUserToSurveyResponse['data'];
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
