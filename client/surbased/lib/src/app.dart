import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/config/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Surbased',
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
      theme: AppTheme.theme(),
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'EN')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate, 
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
//PARA LAS TRADUCCIONES, LOS PASOS SON LOS SIGUIENTES:
//1. creamos la carpeta de assets, se llama assets para que flutter lo reconozca
//2. creamos la carpeta de traducciones, se llama translations para que flutter lo reconozca
//3. creamos el archivo de traducciones en la carpeta de traducciones, se llama messages.dart
//4. creamos el archivo de traducciones en la carpeta de traducciones, se llama messages_all.dart
//5. creamos el archivo de traducciones en la carpeta de traducciones, se llama messages_es.dart
//6. creamos el archivo de traducciones en la carpeta de traducciones, se llama messages_en.dart
//7. creamos el archivo de traducciones en la carpeta de traducciones, se llama messages_es_ES.dart
//8. creamos el archivo de traducciones en la carpeta de traducciones, se llama messages_en_US.dart







