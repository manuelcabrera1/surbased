import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/app.dart';
import 'package:surbased/src/auth/infrastructure/auth_provider.dart';
import 'package:surbased/src/survey/infrastructure/survey_provider.dart';
import 'package:surbased/src/organization/infrastructure/organization_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => SurveyProvider()),
    ChangeNotifierProvider(create: (_) => OrganizationProvider()),
  ], child: const App()));
}
