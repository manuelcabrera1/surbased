import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/app.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/shared/application/provider/lang_provider.dart';
import 'package:surbased/src/shared/application/provider/theme_provider.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/tags_provider.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_answers_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => SurveyProvider()),
    ChangeNotifierProvider(create: (_) => OrganizationProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => CategoryProvider()),
    ChangeNotifierProvider(create: (_) => AnswerProvider()),
    ChangeNotifierProvider(create: (_) => LangProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => SurveyAnswersProvider()),
    ChangeNotifierProvider(create: (_) => TagsProvider()),
  ], child: const App()));
}
