import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/widgets/user_not_registered_dialog.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
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
  final _participantController = TextEditingController();


  void _addParticipant() async {
    if (_formKey.currentState!.validate()) {  
      final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final t = AppLocalizations.of(context)!;
      try {
        if (authProvider.token != null) {
          if (surveyProvider.currentSurvey!.assignedUsers != null && 
              surveyProvider.currentSurvey!.assignedUsers!.any((p) => p.email == _participantController.text)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.user_already_assigned),
                ),
              );
            }
            return;
          }

          final user = await userProvider.getUserByEmail(_participantController.text, authProvider.token!);
          bool success = false;
          if (user == null && mounted) {
            showDialog(
              context: context,
              builder: (context) => UserNotRegisteredDialog(
                userEmail: _participantController.text,
              ),
            );
          } else {
              success = await surveyProvider.addUserToSurvey(
              surveyProvider.currentSurvey!.id!,
              _participantController.text,
              authProvider.token!,
            );
          }
          
          if (success) {
            if (mounted) {
              _participantController.clear();
              Navigator.pop(context);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(surveyProvider.error!),
                ),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _participantController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final t = AppLocalizations.of(context)!;
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
              children: [
                Column(
                  children: [
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                            t.add_user,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _participantController,
                          decoration: InputDecoration(
                            hintText: t.user_assign_hint_text,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return t.input_error_required;
                            }
                            return null;
                          },
                        ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                      onPressed:  _addParticipant,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text('Agregar usuario'),
                    ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
