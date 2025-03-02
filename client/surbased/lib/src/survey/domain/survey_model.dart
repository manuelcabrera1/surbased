import 'dart:convert';

Survey surveyFromJson(String str) => Survey.fromJson(json.decode(str));

String surveyToJson(Survey data) => json.encode(data.toJson());

class Survey {
  final String name;
  final String categoryId;
  final String researcherId;
  final String id;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;

  Survey({
    required this.name,
    required this.categoryId,
    required this.researcherId,
    required this.id,
    this.description,
    this.startDate,
    this.endDate,
  });

  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
        name: json["name"],
        categoryId: json["category_id"],
        researcherId: json["researcher_id"],
        id: json["id"],
        description: json["description"],
        startDate: DateTime.parse(json["start_date"]),
        endDate:
            json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "category_id": categoryId,
        "researcher_id": researcherId,
        "id": id,
        "description": description,
        "start_date":
            "${startDate?.year.toString().padLeft(4, '0')}-${startDate?.month.toString().padLeft(2, '0')}-${startDate?.day.toString().padLeft(2, '0')}", //una fecha en este formato seria
        "end_date": endDate == null
            ? null
            : "${endDate?.year.toString().padLeft(4, '0')}-${endDate?.month.toString().padLeft(2, '0')}-${endDate?.day.toString().padLeft(2, '0')}",
      };
}
