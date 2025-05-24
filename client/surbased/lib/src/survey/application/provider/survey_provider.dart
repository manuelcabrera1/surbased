import 'package:flutter/material.dart';
import 'package:surbased/src/shared/infrastructure/lm_service.dart';
import 'package:surbased/src/shared/infrastructure/mail_service.dart';
import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/survey/domain/tag_model.dart';
import 'package:surbased/src/survey/infrastructure/survey_service.dart';

import '../../../user/domain/user_model.dart';

class SurveyProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  final LmService _lmService = LmService();
  final MailService _mailService = MailService();
  List<Survey> _publicSurveys = [];
  List<Survey> _highlightedPublicSurveys = [];
  List<Survey> _surveysOwned = [];
  bool _isLoading = false;
  bool _isGeneratingSummary = false;
  bool _isGeneratingQuestions = false;
  String? _error;
  Survey? _currentSurvey;
  List<Survey> _privateSurveys = [];
  List<Survey> _organizationSurveys = [];
  Map<String, dynamic> _pendingAssignmentsInCurrentSurvey = {};
  int? numberOfSurveysBeingShown;

  List<Survey> get publicSurveys => _publicSurveys;
  List<Survey> get highlightedPublicSurveys => _highlightedPublicSurveys;
  List<Survey> get surveysOwned => _surveysOwned;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Survey? get currentSurvey => _currentSurvey;
  List<Survey> get privateSurveys => _privateSurveys;
  List<Survey> get organizationSurveys => _organizationSurveys;
  Map <String, dynamic> get pendingAssignmentsInCurrentSurvey => _pendingAssignmentsInCurrentSurvey;
  bool get isGeneratingSummary => _isGeneratingSummary;
  bool get isGeneratingQuestions => _isGeneratingQuestions;
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
    _pendingAssignmentsInCurrentSurvey = {};
    notifyListeners();
  }

  void clearCurrentSurvey() {
    _currentSurvey = null;
    _pendingAssignmentsInCurrentSurvey = {};
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

  Future<bool> updateSurvey(String token, String scope, {String? organizationId}) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      _currentSurvey!.scope = scope;
      _currentSurvey!.organizationId = organizationId;
      
      
      final response = await _surveyService.updateSurvey(
        _currentSurvey!.toJson(),
        token,
      );


      if (response['success']) {
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
            _privateSurveys = (response['data'] as List<dynamic>).map((x) => Survey.fromJson(x)).toList();

            break;
          case 'organization':
            _organizationSurveys = (response['data'] as List<dynamic>).map((x) => Survey.fromJson(x)).toList();

            break;
          case 'public':
            _publicSurveys = (response['data'] as List<dynamic>).map((x) => Survey.fromJson(x)).toList();

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
        _highlightedPublicSurveys = (getSurveysResponse['data'] as List<dynamic>)
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
        final surveys = (getSurveysResponse['data'] as List<dynamic>)
            .map((s) => Survey.fromJson(s))
            .toList();
        _surveysOwned = surveys;
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
      notifyListeners();

      final getSurveyUsersResponse =
          await _surveyService.getUsersAssignedToSurvey(
        surveyId,
        token,
      );

      if (getSurveyUsersResponse['success']) {

        final newAssignedUsers = (getSurveyUsersResponse['data']as List<dynamic>)
            .map((s) => User.fromJson(s))
            .toList();
        newAssignedUsers.sort((a, b) => a.name!.compareTo(b.name!));
        final newPendingAssignments = getSurveyUsersResponse['data']['pending_assignments'];
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

  Future<bool> requestSurveyAccess(String surveyId, String userId, String email, String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final requestSurveyAccessResponse =
          await _surveyService.requestSurveyAccess(
        surveyId,
        userId,
        "New survey access request",
        "$email has requested access to your survey: ${_currentSurvey!.name}",
        token,
      );

      if (requestSurveyAccessResponse['success']) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = requestSurveyAccessResponse['data'];
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

  Future<String?> generateSummary(String questionDescription, List<String> options, String locale) async {
    try {
      _error = null;
      _isGeneratingSummary = true;
      notifyListeners();

      final response = await _lmService.sendMessageToGenerateAnswersSummary(questionDescription, options, locale);

      if (response['success']) {
        _isGeneratingSummary = false;
        notifyListeners();
        return response['data'];
      } else {
        _isGeneratingSummary = false;
        _error = response['data'];
        notifyListeners();
        return null;
      }
      
      
    } catch (e) {
      _error = e.toString();
      _isGeneratingSummary = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> generateQuestionsWithAI(String categoryId, String ownerId, String name, String category, List<String> tags, String description, String locale, String numberOfQuestions, DateTime startDate, DateTime endDate) async {
    try {
      _error = null;
      _isGeneratingQuestions = true;
      notifyListeners();
      

      final response = await _lmService.sendMessageToGenerateSurvey(categoryId, ownerId, name, category, tags, description, locale, numberOfQuestions, startDate, endDate);

      if (response['success']) {
        _isGeneratingQuestions = false;
        _error = null;
        _currentSurvey = Survey.fromJson((response['data']) as Map<String, dynamic>);

        notifyListeners();
      } else {
        _isGeneratingQuestions = false;
        _error = response['data'];
        notifyListeners();
      }
      
      
    } catch (e) {
      _error = e.toString();
      _isGeneratingQuestions = false;
      notifyListeners();
    }
  }

  Future<bool> sendSurveyInvitationMail(String email, String surveyName, String token) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _mailService.sendSurveyInvitationMail(email, surveyName, token);

      if (response['success']) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = response['data'];
        notifyListeners();
        return false;
      }
    } catch(e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
