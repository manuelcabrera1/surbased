import 'dart:convert';

import 'package:surbased/src/survey/domain/question_model.dart';

Answer answerFromJson(String str) => Answer.fromJson(json.decode(str));

String answerToJson(Answer data) => json.encode(data.toJson());

class Answer {
  final String? surveyId;
  final List<Question> questions;

  Answer({
    this.surveyId,
    required this.questions,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        surveyId: json["survey_id"],
        questions: List<Question>.from(
            json["questions"].map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (surveyId != null) json["survey_id"] = surveyId;
    json["questions"] = List<dynamic>.from(questions.map((x) => x.toJson()));
    return json;
  }
}
