import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const ICON_SIZE = 30.0;

class CustomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const CustomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.userRole;
    final t = AppLocalizations.of(context)!;

    // Items de navegación para participantes
    final participantItems = [
      NavigationDestination(
        icon: const Icon(Icons.home, size: ICON_SIZE),
        label: t.surveys_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.explore, size: ICON_SIZE),
        label: t.explore_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month, size: ICON_SIZE),
        label: t.calendar_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person, size: ICON_SIZE),
        label: t.profile_page_title,
      ),
    ];

    // Items de navegación para investigadores
    final researcherItems = [
      NavigationDestination(
          icon: const Icon(Icons.home, size: ICON_SIZE),
          label: t.dashboard_page_title,
      ),
      NavigationDestination(
          icon: const Icon(Icons.calendar_month, size: ICON_SIZE),
          label: t.calendar_page_title, 
      ),
      const SizedBox(),
      NavigationDestination(
          icon: const Icon(Icons.business, size: ICON_SIZE),
          label: t.organizations_page_title,
      ),
         NavigationDestination(
          icon: const Icon(Icons.person, size: ICON_SIZE),
          label: t.profile_page_title,
        ),

    ];

    // Items de navegación para administradores
    final adminItems = [
      NavigationDestination(
          icon: const Icon(Icons.assignment_outlined, size: ICON_SIZE),
          label: t.surveys_page_title,
      ),
      NavigationDestination(
          icon: const Icon(Icons.people, size: ICON_SIZE),
          label: t.users_page_title, 
      ),
      const SizedBox(),
      NavigationDestination(
          icon: const Icon(Icons.business, size: ICON_SIZE),
          label: t.organizations_page_title,
      ),
         NavigationDestination(
          icon: const Icon(Icons.person, size: ICON_SIZE),
          label: t.profile_page_title,
        ),

    ];

    // Seleccionar los items según el rol
    final items = switch (role) {
      'participant' => participantItems,
      'researcher' => researcherItems,
      'admin' => adminItems,
      _ => participantItems, // Por defecto, mostrar items de participante
    };

    return NavigationBar(
      selectedIndex: currentIndex,
      destinations: items,
      onDestinationSelected: onDestinationSelected,
      height: 70,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
    );
  }
}
