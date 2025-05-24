import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/answer_model.dart';
import 'package:surbased/src/survey/infrastructure/survey_service.dart';

class SurveyAnswersProvider extends ChangeNotifier {
  final SurveyService _surveyService = SurveyService();
  List<Answer> _answers = [];
  String? _error;
  bool _isLoading = false;
  Map<String, dynamic> _statistics = {};

  List<Answer> get answers => _answers;
  String? get error => _error;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get statistics => _statistics;

  Future<void> loadSurveyAnswers(String surveyId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _surveyService.getSurveyAnswers(surveyId, token);
      if (result['success']) {
        _answers = (result['data'] as List)
            .map((answer) => Answer.fromJson(answer))
            .toList();
        _calculateStatistics();
      } else {
        _error = result['data'];
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStatistics() {
    _statistics = {
      'total_answers': _answers.length,
      'questions': {},
      'demographics': {
        'gender': {},
        'age_groups': {},
        'organization': {},
      },
    };

    // Calcular estadísticas por pregunta
    for (var answer in _answers) {
      for (var question in answer.questions) {
        if (!_statistics['questions'].containsKey(question.id)) {
          _statistics['questions'][question.id] = {
            'type': question.type,
            'description': question.description,
            'options': {},
            'total_responses': 0,
          };
        }

        _statistics['questions'][question.id]['total_responses']++;

        if (question.type == 'open') {
          // Para preguntas abiertas, usamos el texto como clave
          final textResponse = question.text ?? 'Sin respuesta';
          if (!_statistics['questions'][question.id]['options'].containsKey(textResponse)) {
            _statistics['questions'][question.id]['options'][textResponse] = {
              'text': textResponse,
              'count': 0,
              'percentage': 0,
            };
          }
          _statistics['questions'][question.id]['options'][textResponse]['count']++;
        } else {
          // Para preguntas con opciones
          if (question.options != null) {
            for (var option in question.options!) {
              if (!_statistics['questions'][question.id]['options'].containsKey(option.id)) {
                _statistics['questions'][question.id]['options'][option.id] = {
                  'description': option.description,
                  'points': option.points,
                  'count': 0,
                  'percentage': 0,
                };
              }
              _statistics['questions'][question.id]['options'][option.id]['count']++;
            }
          }
        }
      }
    }

    // Calcular porcentajes para todas las preguntas
    for (var questionId in _statistics['questions'].keys) {
      final questionData = _statistics['questions'][questionId];
      final totalResponses = questionData['total_responses'];

      for (var optionId in questionData['options'].keys) {
        final count = questionData['options'][optionId]['count'];
        questionData['options'][optionId]['percentage'] = 
            (count / totalResponses * 100).toStringAsFixed(1);
      }
    }
  }
} 