import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SurveySavePublishDialog extends StatefulWidget {
  const SurveySavePublishDialog({super.key});

  @override
  State<SurveySavePublishDialog> createState() => _SurveySavePublishDialogState();
}

class _SurveySavePublishDialogState extends State<SurveySavePublishDialog> {

  late String _selectedScope = 'Private';

    Future<void> _createSurvey() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    try {
      if (surveyProvider.currentSurvey!.questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.please_add_question)),
          );
        }
        return;
      }

      if (_selectedScope == '') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.please_select_scope)),
          );
        }
        return;
      }


      
      String scope = _selectedScope.toLowerCase();

      print(organizationProvider.organization!.id);
      print(scope);
      
      bool success = scope == 'organization' ? await surveyProvider.createSurvey(
        authProvider.token!,
        scope,
        organizationId: organizationProvider.organization!.id,
      ) : await surveyProvider.createSurvey(
        authProvider.token!,
        scope,
      );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(AppLocalizations.of(context)!.survey_saved)),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(surveyProvider.error!)),
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
    final Map<String, String> scopeOptions = {
    AppLocalizations.of(context)!.scope_private: AppLocalizations.of(context)!.scope_private_explanation,
    AppLocalizations.of(context)!.scope_organization: AppLocalizations.of(context)!.scope_organization_explanation,
    AppLocalizations.of(context)!.scope_public: AppLocalizations.of(context)!.scope_public_explanation,
  };
    return AlertDialog(
        title: Text(AppLocalizations.of(context)!.survey_save_publish),
        content: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context)!.survey_publish_explanation),
               const SizedBox(height: 10),
               ...scopeOptions.entries.map((entry) => RadioListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                title: Text(entry.key, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
                subtitle: Text(entry.value, style: Theme.of(context).textTheme.bodyMedium),
                value: entry.key,
                groupValue: _selectedScope,
                onChanged: (String? value) => setState(() => _selectedScope = value!),
               )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => _createSurvey(),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      );
  }
}
