import 'package:surbased/src/survey/domain/option_model.dart';

class Question {
  final int? number;
  final String? description;
  final String? type;
  final bool? required;
  final String? id;
  final String? surveyId;
  final List<Option>? options;
  String? text;

  Question({
    this.number,
    this.description,
    this.type,
    this.required,
    this.id,
    this.surveyId,
    this.options,
    this.text,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        number: json["number"],
        description: json["description"],
        type: json["type"],
        required: json["required"],
        id: json["id"],
        surveyId: json["survey_id"],
        options: json["options"] == null 
            ? [] 
            : List<Option>.from(json["options"].map((x) => Option.fromJson(x))),
        text: json["text"],
      );

  Map<String, dynamic> toJson() {
     final Map<String, dynamic> json = {};
     if (id != null) json["id"] = id;
     if (surveyId != null) json["survey_id"] = surveyId;
     if (number != null) json["number"] = number;
     if (description != null) json["description"] = description;
     if (type != null) json["type"] = type;
     if (required != null) json["required"] = required;
     if (options != null) {
       json["options"] = List<dynamic>.from(options!.map((x) => x.toJson()));
     }
     if (text != null) json["text"] = text;
     return json;
   }
}
