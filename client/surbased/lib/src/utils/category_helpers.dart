import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

 String getCategoryName(BuildContext context, String name) {
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

  IconData getCategoryIcon(String name) {
    switch (name) {
      case "Education":
        return Icons.school;
      case "Social":
        return Icons.group;
      case "Health":
        return Icons.health_and_safety;
      case "Science":
        return Icons.science;
      case "Business":
        return Icons.business_center;
      case "Politics":
        return Icons.public;
      case "Technology":
        return Icons.computer;
      case "Sport":
        return Icons.sports_soccer;
      case "Environment":
        return Icons.eco;
      case "Entertainment":
        return Icons.movie;
      case "Economics and Finances":
        return Icons.monetization_on;
      default:
        return Icons.category;
    }
  }