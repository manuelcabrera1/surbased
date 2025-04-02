import 'dart:convert';

Tag tagFromJson(String str) => Tag.fromJson(json.decode(str));

String tagToJson(Tag data) => json.encode(data.toJson());

class Tag {
  final String name;
  final String? id;

  Tag({
    required this.name,
    this.id,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        name: json["name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        if (id != null) "id": id,
        "name": name,
      };
}
