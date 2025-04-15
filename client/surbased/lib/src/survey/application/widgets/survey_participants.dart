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
        final isRequested = surveyProvider.pendingAssignmentsInCurrentSurvey[user.id.toString()] != null &&
            surveyProvider.pendingAssignmentsInCurrentSurvey[user.id.toString()] == 'requested_pending';
        final isInvited = surveyProvider.pendingAssignmentsInCurrentSurvey[user.id.toString()] != null &&
            surveyProvider.pendingAssignmentsInCurrentSurvey[user.id.toString()] == 'invited_pending';

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
              user.name != null ? user.name!.substring(0, 1) : user.email.split('@')[0].substring(0, 1).toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Text(user.name ?? user.email.split('@')[0]),
              if (isRequested || isInvited) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              isRequested ? Icons.person_add : Icons.mail,
                              color: isRequested 
                                ? theme.colorScheme.tertiary 
                                : theme.colorScheme.inversePrimary,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(isRequested 
                              ? t.survey_pending_request 
                              : t.survey_pending_invitation),
                          ],
                        ),
                        content: isRequested
                          ? Text(t.survey_request_message(user.email))
                          : Text(t.survey_invitation_waiting(user.email)),
                        actions: [
                          if (isRequested) ...[
                            OutlinedButton(
                              onPressed: () async {
                                await rejectSurveyAssignment(user.id.toString(), surveyProvider.currentSurvey!.id.toString());
                              },
                              child: Text(t.survey_reject),
                            ),
                            FilledButton(
                              onPressed: () async {
                                await acceptSurveyAssignment(user.id.toString(), surveyProvider.currentSurvey!.id.toString());
                              },
                              child: Text(t.survey_approve),
                            ),
                          ] else
                            FilledButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(t.survey_accept),
                            ),
                        ],
                      ),
                    );
                  },
                  child: Icon(
                    isRequested ? Icons.person_add : Icons.mail,
                    size: 18,
                    color: isRequested 
                      ? theme.colorScheme.tertiary 
                      : theme.colorScheme.inversePrimary,
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
