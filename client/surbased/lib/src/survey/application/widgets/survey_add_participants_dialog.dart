import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/survey_provider.dart';

class SurveyAddParticipantsDialog extends StatefulWidget {
  const SurveyAddParticipantsDialog({super.key});

  @override
  State<SurveyAddParticipantsDialog> createState() =>
      _SurveyAddParticipantsDialogState();
}

class _SurveyAddParticipantsDialogState
    extends State<SurveyAddParticipantsDialog> {
  final _formKey = GlobalKey<FormState>();
  List<String> _participantsInOrganization = [];

  @override
  Widget build(BuildContext context) {
    final surveyProvider = Provider.of<SurveyProvider>(context);

    if (surveyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (surveyProvider.surveyParticipants.isNotEmpty) {
      _participantsInOrganization =
          surveyProvider.surveyParticipants.map((p) => p.email).toList();
    }

    return Dialog.fullscreen(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Participants',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add),
                          label: const Text('Add Participant'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      _participantsInOrganization.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Autocomplete<String>(optionsBuilder:
                                  (TextEditingValue currentValue) {
                                return _participantsInOrganization
                                    .where((String participant) {
                                  return participant.toLowerCase().contains(
                                      currentValue.text.toLowerCase());
                                }).toList();
                              }),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  label: const Text('Add Participant'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
