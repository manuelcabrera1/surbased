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

    if (surveyProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
        final user = surveyProvider.currentSurvey!.assignedUsers![index];
        final isPending = surveyProvider.pendingAssignmentsInCurrentSurvey.contains(user.id.toString());

        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.organizationId != null && user.organizationId != authProvider.user!.organizationId)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    t.external_user,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              if (user.organizationId != null && user.organizationId != authProvider.user!.organizationId)
                const SizedBox(width: 30),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              user.name![0],
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(user.name ?? ''),
              if (isPending) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: theme.colorScheme.inversePrimary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(t.survey_invitation_pending),
                          ],
                        ),
                        content: Text(
                          t.survey_invitation_waiting_response(user.email),
                        ),
                        actions: [
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(t.ok),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(
                    Icons.schedule,
                    size: 18,
                    color: theme.colorScheme.inversePrimary,
                  ),
                ),
              ],
            ],
          ),
          subtitle: Text(user.email),
        );
      },
    );
  }
}
