import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';

class SurveyInvitationDialog extends StatefulWidget {

  final String surveyId;
  final String surveyName;
  final String inviterName;
  final String notificationTitle;
  final String notificationBody;
  final String userId;
  const SurveyInvitationDialog({
    super.key,
    required this.surveyId,
    required this.surveyName,
    required this.inviterName,
    required this.notificationTitle,
    required this.notificationBody,
    required this.userId,
  });

  @override
  State<SurveyInvitationDialog> createState() => _SurveyInvitationDialogState();
}

class _SurveyInvitationDialogState extends State<SurveyInvitationDialog> {

  Future<void> rejectSurveyAssignment(String userId, String surveyId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final result = await authProvider.rejectSurveyAssignment(userId, surveyId, authProvider.token!);
      if (result &&mounted) {
        Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error!)),
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

  Future<void> acceptSurveyAssignment(String userId, String surveyId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      final result = await authProvider.acceptSurveyAssignment(userId, surveyId, authProvider.token!);
      if (result &&mounted) {
        Navigator.pop(context);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error!)),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.notificationTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.notificationBody,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 36),
              ),
              onPressed: () async {
                await acceptSurveyAssignment(widget.userId, widget.surveyId);
              },
              child: Text(t.survey_invitation_accept),
            ),
            const SizedBox(height: 2),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 36),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
              onPressed: () async {
                await rejectSurveyAssignment(widget.userId, widget.surveyId);
              },
              child: Text(t.survey_invitation_reject),
            ),
            const SizedBox(height: 2),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(200, 36),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.survey_invitation_not_now),
            ),
          ],
        ),
      ),
    );
  }
} 