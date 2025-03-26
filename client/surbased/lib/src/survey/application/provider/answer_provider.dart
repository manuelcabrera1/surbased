import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:surbased/src/survey/domain/answer_model.dart';
import 'package:surbased/src/survey/domain/option_model.dart';
import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/survey/infrastructure/survey_service.dart';

class AnswerProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  final List<Answer> _answers = [];
  String? _error;
  bool _isLoading = false;
  Answer? _currentSurveyBeingAnswered;
  final List<String> _questionsToBeAnswered = [];

  List<Answer> get answers => _answers;
  String? get error => _error;
  bool get isLoading => _isLoading;
  Answer? get currentSurveyBeingAnswered => _currentSurveyBeingAnswered;
  List<String> get questionsToBeAnswered => _questionsToBeAnswered;

  void addQuestionToBeAnswered(String questionId) {
    _questionsToBeAnswered.add(questionId);
    notifyListeners();
  }

  void clearAllCurrentInfo() {
    _questionsToBeAnswered.clear();
    _currentSurveyBeingAnswered = null;
    notifyListeners();
  }

  void setCurrentSurveyBeingAnswered(Survey survey) {
    _currentSurveyBeingAnswered = Answer(
        questions: survey.questions
            .map((q) => Question(id: q.id, type: q.type, options: [], text: ''))
            .toList());
    notifyListeners();
  }

  void addOptionToQuestion(Question question, Option option) {
    _currentSurveyBeingAnswered!.questions
        .firstWhere((q) => q.id == question.id)
        .options!
        .add(Option(id: option.id));
    notifyListeners();
  }

  void setTextToQuestion(Question question, String text) {
    _currentSurveyBeingAnswered!.questions
        .firstWhere((q) => q.id == question.id)
        .text = text;
    notifyListeners();
  }

  void changeOptionToQuestion(Question question, Option option) {
    _currentSurveyBeingAnswered!.questions
        .firstWhere((q) => q.id == question.id)
        .options!
        .clear();
    _currentSurveyBeingAnswered!.questions
        .firstWhere((q) => q.id == question.id)
        .options!
        .add(Option(id: option.id));
    notifyListeners();
  }

  void removeOptionFromQuestion(Question question, Option option) {
    _currentSurveyBeingAnswered!.questions
        .firstWhere((q) => q.id == question.id)
        .options!
        .removeWhere((o) => o.id == option.id);
    notifyListeners();
  }

  void clearCurrentSurveyBeingAnswered() {
    _currentSurveyBeingAnswered = null;
    notifyListeners();
  }

  Future<bool> registerSurveyAnswers(String surveyId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final areSurveyAnswersRegistered = await _surveyService
          .registerSurveyAnswers(surveyId, _currentSurveyBeingAnswered!, token);
      if (areSurveyAnswersRegistered['success']) {
        _answers.add(_currentSurveyBeingAnswered!);
        _currentSurveyBeingAnswered = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = areSurveyAnswersRegistered['data'];
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
