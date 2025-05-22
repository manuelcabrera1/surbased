import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';

class SurveyAccessRequestDialog extends StatelessWidget {
  final Survey survey;

  const SurveyAccessRequestDialog({
    super.key,
    required this.survey,
  });

  Future<void> _handleOnPressed(BuildContext context) async {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;

    try {
      if (authProvider.token != null) {
        if (authProvider.token != null) {

          final result = await surveyProvider.requestSurveyAccess(survey.id!, authProvider.user!.id, authProvider.user!.email, authProvider.token!);
          if (result && context.mounted) {
            Navigator.pop(context);
          } else {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(surveyProvider.error ?? t.survey_request_access_error),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.survey_request_access_title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              survey.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(Icons.help_outline),
                  const SizedBox(width: 8),
                  Text(
                  'Número de preguntas: ${survey.questions.length}',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.start,
                ),
                ]
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(Icons.calendar_month),
                  const SizedBox(width: 8),
                  Text(
                    'Fecha de inicio: ${survey.startDate.day}/${survey.startDate.month}/${survey.startDate.year}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined),
                  const SizedBox(width: 8),
                  Text(
                    'Fecha de fin: ${survey.endDate.day}/${survey.endDate.month}/${survey.endDate.year}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (survey.description != null && survey.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Descripción: ${survey.description!}',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              t.survey_request_access_content,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 36),
              ),
              onPressed: () => _handleOnPressed(context),
              child: Text(t.request),
            ),
            const SizedBox(height: 2),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(200, 36),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(t.cancel),
            ),
          ],
        ),
      ),
    );
  }
} 