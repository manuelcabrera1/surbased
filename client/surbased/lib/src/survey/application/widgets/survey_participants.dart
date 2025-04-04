import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import '../provider/survey_provider.dart';

class SurveyParticipants extends StatefulWidget {
  const SurveyParticipants({super.key});

  @override
  State<SurveyParticipants> createState() => _SurveyParticipantsState();
}

class _SurveyParticipantsState extends State<SurveyParticipants> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final t = AppLocalizations.of(context)!;

    if (surveyProvider.currentSurvey == null || 
    surveyProvider.currentSurvey!.assignedUsers == null || 
    surveyProvider.currentSurvey!.assignedUsers!.isEmpty) {
      return Center(
        child: Text(
          t.survey_no_participants_assigned,
          style: theme.textTheme.titleLarge,
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, left: 7),
      shrinkWrap: true,
      itemCount: surveyProvider.currentSurvey!.assignedUsers!.length,
      itemBuilder: (context, index) {
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          trailing: 
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (surveyProvider.currentSurvey!.assignedUsers![index].organizationId != null
              && surveyProvider.currentSurvey!.assignedUsers![index].organizationId != authProvider.user!.organizationId)
                Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(t.external_user,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              surveyProvider.currentSurvey!.assignedUsers![index].name![0],
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(surveyProvider.currentSurvey!.assignedUsers![index].name ?? ''),
          subtitle: Text(surveyProvider.currentSurvey!.assignedUsers![index].email),
        );
      },
    );
  }
}
