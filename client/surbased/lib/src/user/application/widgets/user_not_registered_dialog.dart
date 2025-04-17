import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';

class UserNotRegisteredDialog extends StatelessWidget {
  final String userEmail;

  const UserNotRegisteredDialog({
    super.key,
    required this.userEmail,
  });

  void _sendInvitation(BuildContext context) async {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    try {
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await surveyProvider.sendSurveyInvitationMail(
            userEmail,
            surveyProvider.currentSurvey!.name,
            authProvider.token!,
      );
      if (success) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.invitation_sent),
              backgroundColor: theme.colorScheme.primary,
            ),
        );
        }
      } else {

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.invitation_error),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.invitation_error),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        t.user_not_registered,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        t.user_not_registered_description,
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () => _sendInvitation(context),
          child: Text(t.send_invitation),
        ),
      ],
    );
  }
} 