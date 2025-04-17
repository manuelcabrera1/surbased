import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/shared/application/provider/firebase_provider.dart';
class UserNotificationsPage extends StatefulWidget {
  const UserNotificationsPage({super.key});

  @override
  State<UserNotificationsPage> createState() => _UserNotificationsPageState();
}

class _UserNotificationsPageState extends State<UserNotificationsPage> {





  Future<void> _handleNotificationsChange(bool value) async {
    try{
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final firebaseProvider = Provider.of<FirebaseProvider>(context, listen: false);
 

      if (await Permission.notification.status.isDenied) {
        await openAppSettings();
        return;
      }

      if (value) {
        final success = await firebaseProvider.sendFcmToken(authProvider.token!, authProvider.user!.id);
        if (!success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.notifications_error)),
            );
          }
           return;
        }
      }
      final updated = await authProvider.updateUserNotifications(authProvider.user!.id, value, authProvider.token!);
      if (!updated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.notifications_error)),
          );          
        }
        return;
      }
      firebaseProvider.notificationsEnabled = value;
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
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final firebaseProvider = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.notifications_page_title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Idioma
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(t.notifications_page_title),
              trailing: Switch(
                value: firebaseProvider.notificationsEnabled,
                onChanged: _handleNotificationsChange,
                activeColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
