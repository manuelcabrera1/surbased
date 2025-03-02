import 'dart:convert';

Organization organizationFromJson(String str) =>
    Organization.fromJson(json.decode(str));

String organizationToJson(Organization data) => json.encode(data.toJson());

class Organization {
  final String name;
  final String id;

  Organization({
    required this.name,
    required this.id,
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
