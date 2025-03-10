import 'package:surbased/src/survey/domain/option_model.dart';

class Question {
  final int? number;
  final String? description;
  final bool? multipleAnswer;
  final bool? required;
  final bool? hasCorrectAnswer;
  final String? id;
  final String? surveyId;
  final List<Option>? options;

  Question({
    this.number,
    this.description,
    this.multipleAnswer,
    this.required,
    this.hasCorrectAnswer,
    this.id,
    this.surveyId,
    this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        number: json["number"],
        description: json["description"],
        multipleAnswer: json["multiple_answer"],
        required: json["required"],
        hasCorrectAnswer: json["has_correct_answer"],
        id: json["id"],
        surveyId: json["survey_id"],
        options:
            List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (id != null) json["id"] = id;
    if (surveyId != null) json["survey_id"] = surveyId;
    if (number != null) json["number"] = number;
    if (description != null) json["description"] = description;
    if (multipleAnswer != null) json["multiple_answer"] = multipleAnswer;
    if (required != null) json["required"] = required;
    if (hasCorrectAnswer != null) json["has_correct_answer"] = hasCorrectAnswer;
    if (options != null) {
      json["options"] = List<dynamic>.from(options!.map((x) => x.toJson()));
    }

    return json;
  }
}
