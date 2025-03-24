import 'dart:convert';

import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:surbased/src/user/domain/user_model.dart';

Survey surveyFromJson(String str) => Survey.fromJson(json.decode(str));

String surveyToJson(Survey data) => json.encode(data.toJson());

class Survey {
  String name;
  String categoryId;
  String ownerId;
  final String? id;
  String? description;
  String? scope;
  DateTime startDate;
  DateTime? endDate;
  final List<Question> questions;
  List<User>? assignedUsers;

  Survey({
    required this.name,
    required this.categoryId,
    required this.ownerId,
    this.id,
    this.description,
    this.scope,
    required this.startDate,
    this.endDate,
    required this.questions,
    this.assignedUsers,
  });


  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
        name: json["name"],
        categoryId: json["category_id"],
        ownerId: json["owner_id"],
        id: json["id"],
        description: json["description"] ?? '',
        scope: json["scope"],
        startDate: DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] != null ? DateTime.parse(json["end_date"]) : null,
        questions: List<Question>.from(
            json["questions"].map((x) => Question.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "category_id": categoryId,
        "owner_id": ownerId,
        "description": description,
        "scope": scope,
        "start_date":
            "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}",
        "end_date": endDate != null
            ? "${endDate?.year.toString().padLeft(4, '0')}-${endDate?.month.toString().padLeft(2, '0')}-${endDate?.day.toString().padLeft(2, '0')}"
            : null,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
      };
}
