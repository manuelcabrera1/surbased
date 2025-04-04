import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Category categoryFromJson(String str) => Category.fromJson(json.decode(str));

String categoryToJson(Category data) => json.encode(data.toJson());


class Category {
  final String name;
  final String id;

  Category({
    required this.name,
    required this.id,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        name: json["name"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "id": id,
      };

  static String getCategoryName(BuildContext context, String name) {
    switch (name) {
      case "Education":
        return AppLocalizations.of(context)!.category_education;
      case "Social":
        return AppLocalizations.of(context)!.category_social;
      case "Health":
        return AppLocalizations.of(context)!.category_health;
      case "Science":
        return AppLocalizations.of(context)!.category_science;
      case "Business":
        return AppLocalizations.of(context)!.category_business;
      case "Politics":
        return AppLocalizations.of(context)!.category_politics;
      case "Technology":
        return AppLocalizations.of(context)!.category_technology;
      case "Sport":
        return AppLocalizations.of(context)!.category_sport;
      case "Environment":
        return AppLocalizations.of(context)!.category_environment;
      case "Entertainment":
        return AppLocalizations.of(context)!.category_entertainment;
      case "Economics and Finances":
        return AppLocalizations.of(context)!.category_economics;
      default:
        return name;
    }
  }
}
