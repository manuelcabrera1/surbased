import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/organization_provider.dart';
import 'package:surbased/src/shared/application/custom_navigation_bar_widget.dart';
import 'package:surbased/src/survey/application/pages/survey_create_page.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_events_calendar.dart';
import 'package:surbased/src/survey/application/widgets/survey_list.dart';
import 'package:surbased/src/user/application/widgets/user_profile.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    //_startPeriodicRefresh();
  }

  @override
  void dispose() {
    super.dispose();
    _refreshTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    // Refrescar datos cada 5 minutos (ajustable según necesidades)
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  Future<void> _onDestinationSelected(int index) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      if (index == 0 || index == 1) {
        _refreshData();
      }

      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _refreshData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final organizationProvider =
          Provider.of<OrganizationProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        surveyProvider.getSurveys(
          authProvider.userId!,
          authProvider.userRole!,
          authProvider.token!,
          null,
          null,
        );

        categoryProvider.getCategories(null, authProvider.token!);

        if (authProvider.user!.organizationId != null) {
          organizationProvider.getOrganizationById(
            authProvider.user!.organizationId!,
            authProvider.token!,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.userRole;

    // Si el usuario no está autenticado o el rol es null, mostramos un indicador de carga
    if (!authProvider.isAuthenticated || role == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Páginas para participantes
    final participantPages = [
      const SurveyList(),
      const SurveyEventsCalendar(),
      const UserProfile(),
      const UserProfile()
    ];

    // Páginas para investigadores
    final researcherPages = [
      const SurveyList(),
      const SurveyEventsCalendar(),
      const UserProfile(),
      const UserProfile()
    ];

    // Páginas para administradores
    final adminPages = [
      const SurveyList(),
      const SurveyCreatePage(),
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
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}
