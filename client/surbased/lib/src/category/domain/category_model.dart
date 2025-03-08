import 'dart:convert';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());

class Category {
  final String name;
  final String organizationId;
  final String id;

  Category({
    required this.name,
    required this.organizationId,
    required this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        organizationId: json["organization_id"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "organization_id": organizationId,
        "id": id,
      };
}
