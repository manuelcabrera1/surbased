import 'dart:convert';

import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:surbased/src/survey/domain/tag_model.dart';
import 'package:surbased/src/user/domain/user_model.dart';

Survey surveyFromJson(String str) => Survey.fromJson(json.decode(str));

String surveyToJson(Survey data) => json.encode(data.toJson());

class Survey {
  String name;
  String? assignmentStatus;
  int? invitationsRejected;
  String categoryId;
  String ownerId;
  final String? id;
  String? description;
  String scope;
  DateTime? startDate;
  DateTime? endDate;
  final List<Question> questions;
  List<User>? assignedUsers;
  String? organizationId;
  List<Tag>? tags;
  int? responseCount;

  Survey({
    required this.name,
    this.assignmentStatus,
    this.invitationsRejected,
    required this.categoryId,
    required this.ownerId,
    this.id,
    this.description,
    required this.scope,
    required this.startDate,
    required this.endDate,
    required this.questions,
    this.assignedUsers,
    this.organizationId,
    this.tags,
    this.responseCount,
  });

  factory Survey.fromJson(Map<String, dynamic> json) => Survey(
        name: json["name"] ?? '',
        assignmentStatus: json["assignment_status"],
        invitationsRejected: json["invitations_rejected"],
        categoryId: json["category_id"] ?? '',
        ownerId: json["owner_id"] ?? '',
        id: json["id"],
        description: json["description"] ?? '',
        scope: json["scope"] ?? 'private',
        organizationId: json["organization_id"],
        startDate: DateTime.parse(json["start_date"]),
        endDate: DateTime.parse(json["end_date"]),
        questions: json["questions"] == null 
            ? [] 
            : List<Question>.from(json["questions"].map((x) => Question.fromJson(x))),
        tags: json["tags"] == null 
            ? [] 
            : List<Tag>.from(json["tags"].map((x) => Tag.fromJson(x))),
        responseCount: json["response_count"],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json["name"] = name;
    if (assignmentStatus != null) json["assignment_status"] = assignmentStatus;
    if (invitationsRejected != null) json["invitations_rejected"] = invitationsRejected;
    json["category_id"] = categoryId;
    json["owner_id"] = ownerId;
    if (id != null) json["id"] = id;
    if (description != null) json["description"] = description;
    json["scope"] = scope;
    if (organizationId != null) json["organization_id"] = organizationId;
    if (startDate != null) json["start_date"] = '${startDate?.year}-${startDate?.month.toString().padLeft(2, '0')}-${startDate?.day.toString().padLeft(2, '0')}';
    if (endDate != null) json["end_date"] = '${endDate?.year}-${endDate?.month.toString().padLeft(2, '0')}-${endDate?.day.toString().padLeft(2, '0')}';
    json["questions"] = List<dynamic>.from(questions.map((x) => x.toJson()));
    if (assignedUsers != null) json["assigned_users"] = List<dynamic>.from(assignedUsers!.map((x) => x.toJson()));
    if (tags != null) json["tags"] = List<dynamic>.from(tags!.map((x) => x.toJson()));
    if (responseCount != null) json["response_count"] = responseCount;
    return json;
  }
}
