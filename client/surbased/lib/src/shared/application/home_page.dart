import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/pages/login_page.dart';
import 'package:surbased/src/auth/application/pages/register_page.dart';
import 'package:surbased/src/auth/infrastructure/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/shared/application/custom_navigation_bar_widget.dart';
import 'package:surbased/src/survey/application/pages/survey_create_page.dart';
import 'package:surbased/src/survey/application/widgets/survey_list.dart';
import 'package:surbased/src/user/application/user_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.userRole;

    // Páginas para participantes
    final participantPages = [
      const SurveyList(),
      const RegisterPage(),
      const UserProfile(),
      const UserProfile()
    ];

    // Páginas para investigadores
    final researcherPages = [
      const SurveyList(),
      const SurveyCreatePage(),
      const UserProfile(),
      const UserProfile()
    ];

    // Páginas para administradores
    final adminPages = [
      const LoginPage(),
      const RegisterPage(),
      const UserProfile(),
      const UserProfile()
    ];

    // Seleccionar las páginas según el rol
    final pages = switch (role) {
      'participant' => participantPages,
      'researcher' => researcherPages,
      'admin' => adminPages,
      _ => participantPages, // Por defecto, mostrar páginas de participante
    };

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: role == 'researcher' && _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.surveyCreate),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
