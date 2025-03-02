import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/infrastructure/auth_provider.dart';

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
      const NavigationDestination(
        icon: Icon(Icons.list_alt),
        label: 'Surveys',
      ),
      const NavigationDestination(
        icon: Icon(Icons.calendar_month),
        label: 'Calendar',
      ),
      const NavigationDestination(
        icon: Icon(Icons.history),
        label: 'History',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    // Items de navegación para investigadores
    final researcherItems = [
      const NavigationDestination(
        icon: Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      const NavigationDestination(
        icon: Icon(Icons.add_chart),
        label: 'Create',
      ),
      const NavigationDestination(
        icon: Icon(Icons.analytics),
        label: 'Results',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    // Items de navegación para administradores
    final adminItems = [
      const NavigationDestination(
        icon: Icon(Icons.admin_panel_settings),
        label: 'Panel',
      ),
      const NavigationDestination(
        icon: Icon(Icons.people),
        label: 'Users',
      ),
      const NavigationDestination(
        icon: Icon(Icons.business),
        label: 'Organizations',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person),
        label: 'Profile',
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
