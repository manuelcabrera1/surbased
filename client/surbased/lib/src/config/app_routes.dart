import 'package:flutter/material.dart';
import 'package:surbased/src/auth/application/pages/login_page.dart';
import 'package:surbased/src/auth/application/pages/register_page.dart';
import 'package:surbased/src/shared/application/home_page.dart';
import 'package:surbased/src/survey/application/pages/survey_complete_page.dart';
import 'package:surbased/src/survey/application/pages/survey_create_page.dart';
import 'package:surbased/src/survey/application/pages/survey_detail_page.dart';
import 'package:surbased/src/user/application/pages/user_accessibility_page.dart';
import 'package:surbased/src/user/application/pages/user_edit_info_page.dart';
import 'package:surbased/src/user/application/pages/user_edit_password_page.dart';
import 'package:surbased/src/user/application/pages/user_notifications_page.dart';
import 'package:surbased/src/user/application/pages/user_security_page.dart';
import 'package:surbased/src/user/application/pages/user_theme_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String register = '/register';
  static const String login = '/login';
  static const String surveyDetail = '/survey/detail';
  static const String surveyComplete = '/survey/complete';
  static const String surveyCreate = '/survey/create';
  static const String userEditInfo = '/user/edit/info';
  static const String userEditPassword = '/user/edit/password';
  static const String userNotifications = '/user/notifications';
  static const String userSecurity = '/user/security';
  static const String userTheme = '/user/theme';
  static const String userAccessibility = '/user/accessibility';

  static Map<String, WidgetBuilder> routes = {
    register: (_) => const RegisterPage(),
    login: (_) => const LoginPage(),
    home: (_) => const HomePage(),
    surveyDetail: (_) => const SurveyDetailPage(),
    surveyComplete: (_) => const SurveyCompletePage(),
    surveyCreate: (_) => const SurveyCreatePage(),
    userEditInfo: (_) => const UserEditInfoPage(),
    userEditPassword: (_) => const UserEditPasswordPage(),
    userNotifications: (_) => const UserNotificationsPage(),
    userSecurity: (_) => const UserSecurityPage(),
    userTheme: (_) => const UserThemePage(),
    userAccessibility: (_) => const UserAccessibilityPage(),
    //researcherHome: (_) => const ResearcherHomePage(),
    //adminHome: (_) => const AdminHomePage(),
  };
}
