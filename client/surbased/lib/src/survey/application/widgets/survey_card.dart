import 'package:flutter/material.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyCard extends StatelessWidget {
  final Survey survey;
  final VoidCallback onTap;
  final String userRole;
  final Category category;

  const SurveyCard({
    super.key,
    required this.survey,
    required this.onTap,
    required this.userRole,
    required this.category,
  });

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isSurveyAvailable = survey.startDate.isBefore(
                                DateTime.now().add(const Duration(days: 1))) &&
                            (survey.endDate == null || survey.endDate!.isAfter(DateTime.now()));

    return Card(
      child: InkWell(
        onTap: userRole == 'participant'
            ? survey.startDate.isBefore(DateTime.now())
                ? onTap
                : null
            : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                survey.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.question_answer_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    survey.questions.length > 1
                        ? '${survey.questions.length} preguntas'
                        : '1 pregunta',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                ],
                  ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    isSurveyAvailable
                        ? Icons.calendar_month_outlined
                        : Icons.lock_outline,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isSurveyAvailable && survey.endDate != null
                        ? AppLocalizations.of(context)!.survey_end_date(
                            _formatDate(survey.endDate!))
                        : AppLocalizations.of(context)!.survey_start_date(
                            _formatDate(survey.startDate)),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
