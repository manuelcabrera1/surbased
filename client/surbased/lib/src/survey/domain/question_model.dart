import 'package:surbased/src/survey/domain/option_model.dart';

class Question {
  final int number;
  final String description;
  final bool multipleAnswer;
  final String id;
  final String surveyId;
  final List<Option> options;

  Question({
    required this.number,
    required this.description,
    required this.multipleAnswer,
    required this.id,
    required this.surveyId,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        number: json["number"],
        description: json["description"],
        multipleAnswer: json["multiple_answer"],
        id: json["id"],
        surveyId: json["survey_id"],
        options:
            List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "number": number,
        "description": description,
        "multiple_answer": multipleAnswer,
        "id": id,
        "survey_id": surveyId,
        "options": List<dynamic>.from(options.map((x) => x.toJson())),
      };
}
