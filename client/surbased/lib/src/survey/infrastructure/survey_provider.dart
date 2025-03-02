import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/survey/infrastructure/survey_service.dart';

class SurveyProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  List<Survey> _surveys = [];
  bool _isLoading = false;
  String? _error;

  List<Survey> get surveys => _surveys;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getSurveys(
      String userId, String userRole, String token, String? category) async {
    try {
      _error = null;
      _isLoading = true;
      notifyListeners();
      late Map<String, dynamic> getSurveysResponse;

      if (userRole == 'researcher') {
        getSurveysResponse = await _surveyService.getSurveys(
          token,
          category,
        );
      }
      if (userRole == 'participant') {
        getSurveysResponse = await _surveyService.getSurveysParticipant(
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
}
