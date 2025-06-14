import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/app.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/shared/application/provider/firebase_provider.dart';
import 'package:surbased/src/shared/application/provider/lang_provider.dart';
import 'package:surbased/src/shared/application/provider/theme_provider.dart';
import 'package:surbased/src/shared/infrastructure/firebase_service.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/tags_provider.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_answers_provider.dart';
import 'package:surbased/src/shared/application/provider/accessibility_provider.dart';
import 'package:firebase_core/firebase_core.dart'; 
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  await dotenv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FlutterDownloader.initialize();

  final firebaseProvider = FirebaseProvider();
  await firebaseProvider.initNotifications();

  final authProvider = AuthProvider();
  final themeProvider = ThemeProvider();
  final langProvider = LangProvider();  
  final accessibilityProvider = AccessibilityProvider();
  
  final isAuthenticated = await authProvider.checkToken();

  
  runApp(
    MultiProvider(providers: [
    ChangeNotifierProvider.value(value: authProvider),
    ChangeNotifierProvider.value(value: themeProvider),
    ChangeNotifierProvider.value(value: langProvider),
    ChangeNotifierProvider.value(value: accessibilityProvider),
    ChangeNotifierProvider(create: (_) => SurveyProvider()),
    ChangeNotifierProvider(create: (_) => OrganizationProvider()),
    ChangeNotifierProvider(create: (_) => CategoryProvider()),
    ChangeNotifierProvider(create: (_) => AnswerProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => SurveyAnswersProvider()),
    ChangeNotifierProvider(create: (_) => TagsProvider()),
    ChangeNotifierProvider(create: (_) => firebaseProvider),
  ], child: App(isAuthenticated: isAuthenticated)));
}
