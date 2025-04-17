import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  final String email;
  final String? name;
  final String? lastname;
  final String role;
  final String id;
  final String? organizationId;
  final DateTime? birthdate;
  final String? gender;
  final int? age;
  final bool? allowNotifications;

  User({
    required this.email,
    this.name,
    this.lastname,
    required this.role,
    required this.id,
    this.organizationId,
    this.birthdate,
    this.gender,
    this.age,
    this.allowNotifications,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        email: json["email"],
        name: json["name"],
        lastname: json["lastname"],
        role: json["role"],
        id: json["id"],
        organizationId: json["organization_id"],
        birthdate: json["birthdate"] != null
            ? DateTime.parse(json["birthdate"])
            : null,
        gender: json["gender"],
        age: json["age"],
        allowNotifications: json["allow_notifications"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "name": name,
        "lastname": lastname,
        "role": role,
        "id": id,
        "organization_id": organizationId,
        "birthdate":
            "${birthdate?.year.toString().padLeft(4, '0')}-${birthdate?.month.toString().padLeft(2, '0')}-${birthdate?.day.toString().padLeft(2, '0')}",
        "gender": gender,
        "age": age,
        "allow_notifications": allowNotifications,
      };
}
