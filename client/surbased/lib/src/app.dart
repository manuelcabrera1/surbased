import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/config/app_theme.dart';
import 'package:surbased/src/shared/application/provider/accessibility_provider.dart';
import 'package:surbased/src/shared/application/provider/lang_provider.dart';
import 'package:surbased/src/shared/application/provider/theme_provider.dart';

class App extends StatelessWidget {
  final bool isAuthenticated;
  const App({super.key, required this.isAuthenticated});
  

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final langProvider = Provider.of<LangProvider>(context);
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    
    double textScaleFactor = 1.0;
    switch (accessibilityProvider.textSize) {
      case 'small':
        textScaleFactor = 0.9;
        break;
      case 'medium':
        textScaleFactor = 1.0;
        break;
      case 'large':
        textScaleFactor = 1.2;
        break;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Surbased',
      initialRoute: isAuthenticated ? AppRoutes.home : AppRoutes.login,
      routes: AppRoutes.routes,
      theme: AppTheme.theme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: langProvider.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalizations.delegate,
      ],
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child!,
        );
      },
    );
  }
}







