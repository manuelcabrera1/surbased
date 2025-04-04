import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/user/application/widgets/user_settings_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout() async {
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final organizationProvider =
          Provider.of<OrganizationProvider>(context, listen: false);
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);

      //clean all providers
      organizationProvider.clearState();
      surveyProvider.clearState();
      categoryProvider.clearState();
      await authProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final organizationProvider = Provider.of<OrganizationProvider>(context);

    final accountSettings = {
      t.edit_profile_page_title: () {
        Navigator.pushNamed(context, AppRoutes.userEditInfo);
      },
      t.edit_password_page_title: () {
        Navigator.pushNamed(context, AppRoutes.userEditPassword);
      },
      t.notifications_page_title: () {
        Navigator.pushNamed(context, AppRoutes.userNotifications);
      },
      t.security_page_title: () {
        Navigator.pushNamed(context, AppRoutes.userSecurity);
      },
    };
    final appearanceSettings = {
      t.theme_page_title: () {
        Navigator.pushNamed(context, AppRoutes.userTheme);
      },
      t.accessibility_page_title: () {
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
                    child: Text(t.profile_page_title, 
                                style: theme.textTheme.displayMedium),
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
                    title: t.account_settings, items: accountSettings),
                const SizedBox(height: 20),
                UserSettingsSection(
                    title: t.appearance, items: appearanceSettings),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: TextButton(
                        onPressed: _logout,
                        child: Text(t.logout,
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
