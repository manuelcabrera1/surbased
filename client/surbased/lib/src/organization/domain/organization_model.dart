import 'dart:convert';

import 'package:surbased/src/user/domain/user_model.dart';

Organization organizationFromJson(String str) =>
    Organization.fromJson(json.decode(str));

String organizationToJson(Organization data) => json.encode(data.toJson());

class Organization {
  final String name;
  final String id;
  List<User>? users;

  Organization({
    required this.name,
    required this.id,
    this.users,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
        name: json["name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };
}
