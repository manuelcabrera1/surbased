import 'dart:convert';

import 'package:surbased/src/user/domain/user_model.dart';

import '../../survey/domain/survey_model.dart';

Organization organizationFromJson(String str) =>
    Organization.fromJson(json.decode(str));

String organizationToJson(Organization data) => json.encode(data.toJson());

class Organization {
  final String name;
  final String id;
  List<User>? users;
  List<Survey>? surveys;
  int? usersCount;
  int? surveysCount;

  Organization({
    required this.name,
    required this.id,
    this.users,
    this.surveys,
    this.usersCount,
    this.surveysCount,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        name: json["name"],
        id: json["id"],
        usersCount: json["users_count"],
        surveysCount: json["surveys_count"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
        if (usersCount != null) "users_count": usersCount,
        if (surveysCount != null) "surveys_count": surveysCount,
      };
}
