import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/infrastructure/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/infrastructure/organization_provider.dart';
import 'package:surbased/src/user/application/widgets/user_settings_section.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _isInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.user != null &&
              authProvider.user!.organizationId != null &&
              authProvider.token != null) {
            final organizationProvider =
                Provider.of<OrganizationProvider>(context, listen: false);
            organizationProvider.getOrganizationById(
              authProvider.user!.organizationId!,
              authProvider.token!,
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _isInitialized = false;
  }

  Future<void> _logout() async {
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider =
          Provider.of<OrganizationProvider>(context, listen: false);
      organizationProvider.clearState();
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final organizationProvider = Provider.of<OrganizationProvider>(context);

    final accountSettings = {
      'Edit Profile': () {
        Navigator.pushNamed(context, AppRoutes.userEditInfo);
      },
      'Change Password': () {
        Navigator.pushNamed(context, AppRoutes.userEditPassword);
      },
      'Notifications': () {
        Navigator.pushNamed(context, AppRoutes.userNotifications);
      },
      'Security': () {
        Navigator.pushNamed(context, AppRoutes.userSecurity);
      },
    };
    final appearanceSettings = {
      'Theme': () {
        Navigator.pushNamed(context, AppRoutes.userTheme);
      },
      'Accessibility': () {
        Navigator.pushNamed(context, AppRoutes.userAccessibility);
      },
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child:
                        Text('Profile', style: theme.textTheme.displayMedium),
                  ),
                ),
                const SizedBox(height: 35),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.account_circle,
                        size: 130,
                      ),
                      const SizedBox(height: 8),
                      user != null && user.name != null
                          ? Text(
                              user.name!,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),
                      if (organizationProvider.isLoading)
                        const CircularProgressIndicator(strokeWidth: 2)
                      else if (organizationProvider.organization != null)
                        Text(
                          organizationProvider.organization?.name ?? '',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      //const SizedBox(height: 4),
                      user != null
                          ? Text(
                              user.email,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                UserSettingsSection(
                    title: 'Account Settings', items: accountSettings),
                const SizedBox(height: 20),
                UserSettingsSection(
                    title: 'Appearance', items: appearanceSettings),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextButton(
                        onPressed: _logout,
                        child: Text('Logout',
                            style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold))),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
