import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    // Items de navegación para participantes
    final participantItems = [
      NavigationDestination(
        icon: const Icon(Icons.list_alt),
        label: AppLocalizations.of(context)!.surveys_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.explore),
        label: AppLocalizations.of(context)!.explore_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month),
        label: AppLocalizations.of(context)!.calendar_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person),
        label: AppLocalizations.of(context)!.profile_page_title,
      ),
    ];

    // Items de navegación para investigadores
    final researcherItems = [
      NavigationDestination(
        icon: const Icon(Icons.dashboard),
        label: AppLocalizations.of(context)!.dashboard_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.calendar_month),
        label: AppLocalizations.of(context)!.calendar_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.business),
        label: AppLocalizations.of(context)!.organization,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person),
        label: AppLocalizations.of(context)!.profile_page_title,
      ),
    ];

    // Items de navegación para administradores
    final adminItems = [
      NavigationDestination(
        icon: const Icon(Icons.admin_panel_settings),
        label: AppLocalizations.of(context)!.panel_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.people),
        label: AppLocalizations.of(context)!.users_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.business),
        label: AppLocalizations.of(context)!.organizations_page_title,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person),
        label: AppLocalizations.of(context)!.profile_page_title,
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
    );
  }
}
