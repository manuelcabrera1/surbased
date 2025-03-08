import 'package:surbased/src/survey/domain/option_model.dart';

class Question {
  final int? number;
  final String description;
  final bool multipleAnswer;
  final bool required;
  final bool hasCorrectAnswer;
  final String? id;
  final String? surveyId;
  final List<Option> options;

  Question({
    this.number,
    required this.description,
    required this.multipleAnswer,
    required this.required,
    required this.hasCorrectAnswer,
    this.id,
    this.surveyId,
    required this.options,
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

  Map<String, dynamic> toJson() => {
        "description": description,
        "multiple_answer": multipleAnswer,
        "required": required,
        "has_correct_answer": hasCorrectAnswer,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
      };
}
