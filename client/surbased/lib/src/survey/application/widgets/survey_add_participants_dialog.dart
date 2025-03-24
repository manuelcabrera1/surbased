import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  List<String> _participantsInSurvey = [];
  List<String> _participantsToAdd = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      if (surveyProvider.currentSurvey!.assignedUsers!.isNotEmpty) {
        _participantsInSurvey =
            surveyProvider.currentSurvey!.assignedUsers!.map((p) => p.email).toList();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _participantsInSurvey.clear();
    _participantsToAdd.clear();
  }

  void _addParticipant() {
    setState(() {
      _participantsToAdd.add('');
    });
  }

  void _removeParticipant(String email) {
    setState(() {
      _participantsToAdd.remove(email);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    if (surveyProvider.isLoading || organizationProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.survey_add_participants,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addParticipant,
                          icon: const Icon(Icons.add),
                          label: Text(AppLocalizations.of(context)!.survey_add_new),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...List.generate(
                      _participantsToAdd.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Autocomplete<String>(optionsViewBuilder:
                                  (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 4,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.8,
                                      ),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (context, index) =>
                                            ListTile(
                                          title: Text(
                                            options.elementAt(index),
                                            style: theme.textTheme.bodyLarge,
                                          ),
                                          onTap: () {
                                            onSelected(
                                                options.elementAt(index));
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }, optionsBuilder:
                                  (TextEditingValue currentValue) {
                                return organizationProvider.organization?.users
                                        ?.where((user) =>
                                            !_participantsInSurvey
                                                .contains(user.email) &&
                                            user.role == 'participant')
                                        .map((user) => user.email)
                                        .toList() ??
                                    [];
                              }),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () =>
                                  _removeParticipant(_participantsToAdd[index]),
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
                  label: Text(AppLocalizations.of(context)!.survey_add_participants),
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
