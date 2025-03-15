import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/survey_provider.dart';

class SurveyParticipants extends StatefulWidget {
  const SurveyParticipants({super.key});

  @override
  State<SurveyParticipants> createState() => _SurveyParticipantsState();
}

class _SurveyParticipantsState extends State<SurveyParticipants> {
  @override
  Widget build(BuildContext context) {
    final surveyProvider = Provider.of<SurveyProvider>(context);

    if (surveyProvider.surveyParticipants.isEmpty) {
      return const Center(
        child: Text('No participants assigned yet'),
      );
    }

    return ListView.builder(
      itemCount: surveyProvider.surveyParticipants.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(surveyProvider.surveyParticipants[index].name!),
        subtitle: Text(surveyProvider.surveyParticipants[index].email),
      ),
    );
  }
}
