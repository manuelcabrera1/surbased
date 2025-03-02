import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/infrastructure/auth_provider.dart';
import 'package:surbased/src/organization/infrastructure/organization_provider.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.userRole != 'admin') {
      final organizationProvider =
          Provider.of<OrganizationProvider>(context, listen: false);

      organizationProvider.getOrganizationById(
        authProvider.user!.organizationId!,
        authProvider.token!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final organizationProvider = Provider.of<OrganizationProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text('Profile', style: theme.textTheme.displayMedium),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_circle,
                      size: 130,
                    ),
                    const SizedBox(height: 8),
                    user!.name != null
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
                    Text(
                      user.email,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              UserSettingsSection(title: 'Account Settings', theme: theme),
              const SizedBox(height: 10),
              UserSettingsSection(title: 'Appearance', theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

class UserSettingsSection extends StatelessWidget {
  const UserSettingsSection({
    super.key,
    required this.theme,
    required this.title,
  });

  final ThemeData theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                )),
            UserSettings(title: 'Personal Information', theme: theme),
            UserSettings(title: 'Password Settings', theme: theme),
            UserSettings(title: 'Notifications', theme: theme),
            UserSettings(title: 'Security', theme: theme),
          ],
        ),
      ),
    );
  }
}

class UserSettings extends StatelessWidget {
  const UserSettings({
    super.key,
    required this.theme,
    required this.title,
  });

  final ThemeData theme;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded));
  }
}
