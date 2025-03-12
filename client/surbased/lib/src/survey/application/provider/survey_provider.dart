import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/survey/infrastructure/survey_service.dart';

import '../../../user/domain/user_model.dart';

class SurveyProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  List<Survey> _surveys = [];
  bool _isLoading = false;
  String? _error;
  Survey? _currentSurvey;
  List<User> _surveyParticipants = [];

  List<Survey> get surveys => _surveys;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Survey? get currentSurvey => _currentSurvey;
  List<User> get surveyParticipants => _surveyParticipants;

  set currentSurvey(Survey? value) {
    _currentSurvey = value;
    notifyListeners();
  }

  void clearState() {
    _isLoading = false;
    _error = null;
    _surveys = [];
    _currentSurvey = null;
    notifyListeners();
  }

  void clearCurrentSurvey() {
    _currentSurvey = null;
    notifyListeners();
  }

  bool addSurveyInfo(String name, String? description, DateTime startDate,
      DateTime? endDate, String categoryId, String researcherId) {
    _currentSurvey = Survey(
      name: name,
      description: description ?? '',
      categoryId: categoryId,
      startDate: startDate,
      endDate: endDate,
      questions: [],
      researcherId: researcherId,
    );
    notifyListeners();
    return true;
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

  Future<bool> createSurvey(String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final response = await _surveyService.createSurvey(
        _currentSurvey!.toJson(),
        token,
      );

      if (response['success']) {
        _surveys.add(_currentSurvey!);
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

  Future<void> getSurveys(String userId, String userRole, String token,
      String? org, String? category) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();
      late Map<String, dynamic> getSurveysResponse;

      if (userRole == 'admin') {
        getSurveysResponse = await _surveyService.getSurveys(
          token,
          org,
          category,
        );
      }

      if (userRole == 'admin' || userRole == 'researcher') {
        getSurveysResponse = await _surveyService.getSurveys(
          token,
          null,
          category,
        );
      }
      if (userRole == 'participant') {
        getSurveysResponse = await _surveyService.getParticipantSurveys(
          userId,
          token,
          category,
        );
      }

      if (getSurveysResponse['success']) {
        _surveys = (getSurveysResponse['data']['surveys'] as List<dynamic>)
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

  Future<void> getSurveyParticipants(String surveyId, String token) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();

      final getSurveyParticipantsResponse =
          await _surveyService.getSurveyParticipants(
        surveyId,
        token,
      );

      if (getSurveyParticipantsResponse['success']) {
        _surveyParticipants =
            (getSurveyParticipantsResponse['data']['users'] as List<dynamic>)
                .map((s) => User.fromJson(s))
                .toList();
        _error = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _error = getSurveyParticipantsResponse['data'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
