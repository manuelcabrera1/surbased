import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/organization/application/widgets/organization_section.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/shared/application/provider/firebase_provider.dart';
import 'package:surbased/src/shared/application/widgets/create_resource_dialog.dart';
import 'package:surbased/src/shared/application/widgets/custom_navigation_bar_widget.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/provider/tags_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_create_dialog.dart';
import 'package:surbased/src/survey/application/widgets/survey_events_calendar.dart';
import 'package:surbased/src/survey/application/widgets/survey_section.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
import 'package:surbased/src/user/application/widgets/user_list.dart';
import 'package:surbased/src/user/application/widgets/user_profile.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../organization/application/widgets/organization_list.dart';
import '../../../survey/application/widgets/survey_explore.dart';
import '../../../survey/application/widgets/survey_invitation_dialog.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _refreshData();
      _checkForInvitation();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _refreshTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_startPeriodicRefresh
    _checkForInvitation();
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      if (index == 0 || index == 1 || index == 2 || (index == 3 && authProvider.userRole == 'admin')) {
        _refreshData();
      }

      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _checkForInvitation() {
    final message = ModalRoute.of(context)?.settings.arguments;
    if (message != null && message is RemoteMessage) {
      if (message.data['type'] == 'survey_invitation') {
        showDialog(
          context: context,
          builder: (context) => SurveyInvitationDialog(
            surveyId: message.notification?.body ?? '',
            surveyName: message.notification?.title ?? '',
            inviterName: message.notification?.title ?? '',
            notificationTitle: message.notification?.title ?? '',
            notificationBody: message.notification?.body ?? '',
            userId: message.data['user_id'],
          ),
        );
      }
    }
  }

  void _refreshParticipantData() async {
    try {
      final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final organizationProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        await authProvider.getSurveysAssignedToUser(
                  authProvider.userId!,
                  authProvider.token!,
                );
        
        await surveyProvider.getSurveysByScope(
                'public',
                authProvider.token!,
              );
        await surveyProvider.getHighlightedPublicSurveys(
                authProvider.token!,
              );
        if (authProvider.user!.organizationId != null) {
          await organizationProvider.getCurrentOrganization(
            authProvider.user!.organizationId!,
            authProvider.token!,
          );

          await organizationProvider.getSurveysInOrganization(
          authProvider.token!,
        );
        await authProvider.getSurveysAnswers(
          authProvider.userId!,
          authProvider.token!,
        );      
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _refreshResearcherData() async {
    try {
      final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final organizationProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        await authProvider.getSurveysAssignedToUser(
                  authProvider.userId!,
                  authProvider.token!,
                );

        if (authProvider.user!.organizationId != null) {
          await surveyProvider.getSurveysByOwner(
            authProvider.user!.id,
            authProvider.token!,
          );
          
          await organizationProvider.getCurrentOrganization(
            authProvider.user!.organizationId!,
            authProvider.token!,
          );

          await organizationProvider.getSurveysInOrganization(
            authProvider.token!,
          );

          await organizationProvider.getUsersInOrganization(
            authProvider.token!,
          );
          

        }

      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _refreshAdminData() async {
    try {
      final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final surveyProvider =
              Provider.of<SurveyProvider>(context, listen: false);
          final organizationProvider =
              Provider.of<OrganizationProvider>(context, listen: false);
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      await surveyProvider.getSurveysByScope(
        'private',
        authProvider.token!,
      );
      await surveyProvider.getSurveysByScope(
        'organization',
        authProvider.token!,
      );
      
      await surveyProvider.getSurveysByScope(
              'public',
              authProvider.token!,
            );
      await userProvider.getUsers(authProvider.token!, null, null);
      await organizationProvider.getOrganizations(authProvider.token ?? '');
      
    }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _refreshData() async {
    try {
      final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
      final categoryProvider =
              Provider.of<CategoryProvider>(context, listen: false);
      final tagProvider =
              Provider.of<TagsProvider>(context, listen: false);
      final firebaseProvider =
              Provider.of<FirebaseProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        if (authProvider.user!.allowNotifications != null && authProvider.user!.allowNotifications != firebaseProvider.notificationsEnabled) {
          await authProvider.updateUserNotifications(authProvider.user!.id, firebaseProvider.notificationsEnabled, authProvider.token!);
        }
        
        await categoryProvider.getCategories(null, authProvider.token!);
        await tagProvider.getTags(authProvider.token ?? '');
        switch (authProvider.userRole) {
          case 'participant':
            _refreshParticipantData();
          break;
        case 'researcher':
          _refreshResearcherData();
          break;
        case 'admin':
          _refreshAdminData();
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.userRole;

    if (!authProvider.isAuthenticated || role == null || authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Páginas para participantes
    final participantPages = [
      const SurveySection(),
      const SurveyExplore(),
      const SurveyEventsCalendar(),
      const UserProfile()
    ];

    // Páginas para investigadores
    final researcherPages = [
      const SurveySection(),
      const SurveyEventsCalendar(),
      const SizedBox(),
      const OrganizationSection(),
      const UserProfile()
    ];

    // Páginas para administradores
    final adminPages = [
      const SurveySection(),
      const UserList(),
      const SizedBox(),
      const OrganizationList(),
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
      floatingActionButton: role == 'researcher' || role == 'admin'
          ? FloatingActionButton(
              heroTag: '${widget.hashCode}',
              shape: const CircleBorder(),
              onPressed: () {
                if (role == 'researcher') {
                  showDialog(
                    context: context,
                    builder: (context) => const SurveyCreateDialog(),
                  );
                } else if (role == 'admin') {
                  showDialog(
                    context: context,
                    builder: (context) => const CreateResourceDialog(),
                  );
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
