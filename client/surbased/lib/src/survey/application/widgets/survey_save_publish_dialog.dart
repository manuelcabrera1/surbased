import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class SurveySavePublishDialog extends StatefulWidget {
  final bool isEditing;
  const SurveySavePublishDialog({super.key, this.isEditing = false});

  @override
  State<SurveySavePublishDialog> createState() => _SurveySavePublishDialogState();
}

class _SurveySavePublishDialogState extends State<SurveySavePublishDialog> {

  late String _selectedScope = 'Private';

    Future<void> _createSurvey() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;
    try {
      if (surveyProvider.currentSurvey!.questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.please_add_question)),
          );
        }
        return;
      }

      if (_selectedScope == '') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.please_select_scope)),
          );
        }
        return;
      }
      
      String scope = _selectedScope.toLowerCase();


      bool success = false;

      if (widget.isEditing) {
        success = await surveyProvider.updateSurvey(
          authProvider.token!,
          scope,
          organizationId: scope == 'organization' ? organizationProvider.organization!.id : null,
        );
      } else {
        success = await surveyProvider.createSurvey(
          authProvider.token!,
          scope,
          organizationId: scope == 'organization' ? organizationProvider.organization!.id : null
        );
      }
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(t.survey_saved)),
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
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
        title: Text(t.survey_save_publish),
        content: Padding(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.survey_publish_explanation),
               const SizedBox(height: 10),
               RadioListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                title: Text(t.scope_private, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
                subtitle: Text(t.scope_private_explanation, style: Theme.of(context).textTheme.bodyMedium),
                value: 'private',
                groupValue: _selectedScope,
                onChanged: (String? value) => setState(() => _selectedScope = value!),
               ),
               RadioListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                title: Text(t.scope_organization, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
                subtitle: Text(t.scope_organization_explanation, style: Theme.of(context).textTheme.bodyMedium),
                value: 'organization',
                groupValue: _selectedScope,
                onChanged: (String? value) => setState(() => _selectedScope = value!),
               ),
               RadioListTile(
                visualDensity: VisualDensity.compact,
                contentPadding: EdgeInsets.zero,
                title: Text(t.scope_public, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w400)),
                subtitle: Text(t.scope_public_explanation, style: Theme.of(context).textTheme.bodyMedium),
                value: 'public',
                groupValue: _selectedScope,
                onChanged: (String? value) => setState(() => _selectedScope = value!),
               )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => _createSurvey(),
            child: Text(t.save),
          ),
        ],
      );
  }
}
