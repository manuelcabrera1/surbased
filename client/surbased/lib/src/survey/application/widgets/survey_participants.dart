import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

    if (surveyProvider.surveyParticipants.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.survey_no_participants_assigned,
          style: theme.textTheme.titleLarge,
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, left: 7),
      shrinkWrap: true,
      itemCount: surveyProvider.surveyParticipants.length,
      itemBuilder: (context, index) {
        return ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          trailing: const Icon(Icons.arrow_forward_ios),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              surveyProvider.surveyParticipants[index].name![0],
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(surveyProvider.surveyParticipants[index].name ?? ''),
          subtitle: Text(surveyProvider.surveyParticipants[index].email),
        );
      },
    );
  }
}
