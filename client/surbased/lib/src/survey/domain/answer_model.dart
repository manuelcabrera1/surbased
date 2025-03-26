import 'dart:convert';

import 'package:surbased/src/survey/domain/question_model.dart';

Answer answerFromJson(String str) => Answer.fromJson(json.decode(str));

String answerToJson(Answer data) => json.encode(data.toJson());

class Answer {
  final String? surveyId;
  final String? userId;
  final String? username;
  final List<Question> questions;

  Answer({
    this.surveyId,
    this.userId,
    this.username,
    required this.questions,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        surveyId: json["survey_id"],
        userId: json["user_id"],
        username: json["username"],
        questions: List<Question>.from(
            json["questions"].map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (surveyId != null) json["survey_id"] = surveyId;
    if (userId != null) json["user_id"] = userId;
    if (username != null) json["username"] = username;
    json["questions"] = List<dynamic>.from(questions.map((x) => x.toJson()));
    return json;
  }
}
