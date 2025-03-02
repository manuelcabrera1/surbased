import 'package:flutter/material.dart';
import 'package:surbased/src/auth/application/pages/login_page.dart';
import 'package:surbased/src/auth/application/pages/register_page.dart';
import 'package:surbased/src/shared/application/home_page.dart';
import 'package:surbased/src/survey/application/pages/survey_complete_page.dart';
import 'package:surbased/src/survey/application/pages/survey_create_page.dart';
import 'package:surbased/src/survey/application/pages/survey_detail_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String register = '/register';
  static const String login = '/login';
  static const String surveyDetail = '/survey/detail';
  static const String surveyComplete = '/survey/complete';
  static const String surveyCreate = '/survey/create';

  static Map<String, WidgetBuilder> routes = {
    register: (_) => const RegisterPage(),
    login: (_) => const LoginPage(),
    home: (_) => const HomePage(),
    surveyDetail: (_) => const SurveyDetailPage(),
    surveyComplete: (_) => const SurveyCompletePage(),
    surveyCreate: (_) => const SurveyCreatePage(),
    //researcherHome: (_) => const ResearcherHomePage(),
    //adminHome: (_) => const AdminHomePage(),
  };
}
