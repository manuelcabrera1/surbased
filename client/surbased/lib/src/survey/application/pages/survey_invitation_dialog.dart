import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyInvitationDialog extends StatelessWidget {
  final String surveyId;
  final String surveyName;
  final String inviterName;

  const SurveyInvitationDialog({
    super.key,
    required this.surveyId,
    required this.surveyName,
    required this.inviterName,
  });

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.survey_invitation_title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.survey_invitation_message(inviterName, surveyName),
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 36),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (authProvider.token != null) {
                authProvider.acceptSurveyAssignment(surveyId, authProvider.token!);
              }
            },
            child: Text(t.survey_invitation_accept),
          ),
          const SizedBox(height: 2),
          TextButton(
            style: TextButton.styleFrom(
              minimumSize: const Size(200, 36),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              if (authProvider.token != null) {
                authProvider.rejectSurveyAssignment(surveyId, authProvider.token!);
              }
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
    );
  }
} 