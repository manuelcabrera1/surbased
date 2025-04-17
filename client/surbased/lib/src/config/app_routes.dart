import 'package:flutter/material.dart';
import 'package:surbased/src/auth/application/pages/enter_reset_code_page.dart';
import 'package:surbased/src/auth/application/pages/reset_password_page.dart';
import 'package:surbased/src/auth/application/pages/send_forgot_password_mail_page.dart';
import 'package:surbased/src/auth/application/pages/login_page.dart';
import 'package:surbased/src/auth/application/pages/register_page.dart';
import 'package:surbased/src/organization/application/pages/organization_create_page.dart';
import 'package:surbased/src/organization/application/pages/organization_details.dart';
import 'package:surbased/src/shared/application/pages/home_page.dart';
import 'package:surbased/src/survey/application/pages/survey_add_questions_page.dart';
import 'package:surbased/src/survey/application/pages/survey_complete_page.dart';
import 'package:surbased/src/survey/application/pages/survey_create_page.dart';
import 'package:surbased/src/survey/application/pages/survey_details_page.dart';
import 'package:surbased/src/survey/application/pages/survey_edit_page.dart';
import 'package:surbased/src/user/application/pages/user_accessibility_page.dart';
import 'package:surbased/src/user/application/pages/user_create_page.dart';
import 'package:surbased/src/user/application/pages/user_details_page.dart';
import 'package:surbased/src/user/application/pages/user_edit_info_page.dart';
import 'package:surbased/src/user/application/pages/user_edit_password_page.dart';
import 'package:surbased/src/user/application/pages/user_notifications_page.dart';
import 'package:surbased/src/user/application/pages/user_security_page.dart';
import 'package:surbased/src/user/application/pages/user_theme_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String register = '/register';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String enterResetCode = '/enter-reset-code';
  static const String resetPassword = '/reset-password';
  static const String surveyDetails = '/survey/details';
  static const String surveyComplete = '/survey/complete';
  static const String surveyCreate = '/survey/create';
  static const String surveyEdit = '/survey/edit';
  static const String surveyAddQuestions = '/survey/create/questions';
  static const String userEditInfo = '/user/edit/info';
  static const String userEditPassword = '/user/edit/password';
  static const String userNotifications = '/user/notifications';
  static const String userSecurity = '/user/security';
  static const String userTheme = '/user/theme';
  static const String userAccessibility = '/user/accessibility';
  static const String userDetails = '/user/details';
  static const String organizationDetails = '/organization/details';
  static const String userCreate = '/user/create';  
  static const String organizationCreate = '/organization/create';
  static Map<String, WidgetBuilder> routes = {
    register: (_) => const RegisterPage(),
    login: (_) => const LoginPage(),
    home: (_) => const HomePage(),
    forgotPassword: (_) => const SendForgotPasswordMailPage(),
    enterResetCode: (context) => EnterResetCodePage(email: ModalRoute.of(context)!.settings.arguments as String),
    resetPassword: (context) => ResetPasswordPage(email: ModalRoute.of(context)!.settings.arguments as String),
    surveyDetails: (_) => const SurveyDetailsPage(),
    surveyComplete: (_) => const SurveyCompletePage(),
    surveyCreate: (context) => SurveyCreatePage(isGeneratingWithAI: ModalRoute.of(context)?.settings.arguments == true),
    surveyEdit: (_) => const SurveyEditPage(),
    userEditInfo: (_) => const UserEditInfoPage(),
    userEditPassword: (_) => const UserEditPasswordPage(),
    userNotifications: (_) => const UserNotificationsPage(),
    userSecurity: (_) => const UserSecurityPage(),
    userTheme: (_) => const UserThemePage(),
    userAccessibility: (_) => const UserAccessibilityPage(),
    userDetails: (context) => UserDetailsPage(userId: ModalRoute.of(context)!.settings.arguments as String),
    surveyAddQuestions: (_) => const SurveyAddQuestionsPage(),
    organizationDetails: (_) => const OrganizationDetails(),
    userCreate: (_) => const UserCreatePage(),
    organizationCreate: (_) => const OrganizationCreatePage(),
    //researcherHome: (_) => const ResearcherHomePage(),
    //adminHome: (_) => const AdminHomePage(),
  };
}
