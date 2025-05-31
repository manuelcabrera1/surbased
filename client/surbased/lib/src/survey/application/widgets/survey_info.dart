import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/utils/category_helpers.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';

class SurveyInfo extends StatelessWidget {
  const SurveyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final survey = surveyProvider.currentSurvey;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final t = AppLocalizations.of(context)!;
    if (survey == null) {
      return Center(
          child: Text(
        t.survey_not_selected_error,
        style: theme.textTheme.titleLarge,
      ));
    }

    if (surveyProvider.isLoading || categoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final category = categoryProvider.getCategoryById(survey.categoryId);
    String scopeLabel = '';
    IconData scopeIcon = Icons.lock_outline;
    String? organizationName;
    switch (survey.scope) {
      case 'private':
        scopeLabel = t.scope_private;
        scopeIcon = Icons.lock_outline;
        break;
      case 'public':
        scopeLabel = t.scope_public;
        scopeIcon = Icons.public;
        break;
      case 'organization':
        scopeLabel = t.scope_organization;
        if (survey.organizationId != null) {
          organizationName = organizationProvider.getOrganizationName(survey.organizationId!);
          scopeIcon = Icons.business_center;
        }
        break;
      default:
        scopeLabel = survey.scope;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera visual
            Text(
              survey.name,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  getCategoryIcon(category.name),
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  getCategoryName(context, category.name),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // Etiquetas (tags) debajo de la categoría
            if (survey.tags != null && survey.tags!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...survey.tags!.map((tag) {
                    final index = survey.tags!.indexOf(tag);
                    final color = const [
                      Color(0xFFE8F5E9), // green.shade50
                      Color(0xFFFFF3E0), // orange.shade50
                      Color(0xFFF3E5F5), // purple.shade50
                      Color(0xFFE3F2FD), // blue.shade50
                      Color(0xFFFFEBEE), // red.shade50
                      Color(0xFFE0F2F1), // teal.shade50
                      Color(0xFFFCE4EC), // pink.shade50
                      Color(0xFFE8EAF6), // indigo.shade50
                    ][index % 8];
                    return Padding(
                      padding: const EdgeInsets.only(right: 2, bottom: 4),
                      child: Chip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        label: Text(
                          tag.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: color.computeLuminance() > 0.5 
                                ? Colors.black87 
                                : Colors.white,
                            fontSize: 11,
                          ),
                        ),
                        backgroundColor: color,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }),
                ],
              ),
            ],
            if (survey.description != null && survey.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                survey.description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Sección Detalles
            Text(
              t.survey_general_information,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.dividerColor.withOpacity(0.10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: theme.colorScheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        t.survey_start_date(dateFormat.format(survey.startDate!)),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: theme.colorScheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        t.survey_end_date(dateFormat.format(survey.endDate!)),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(scopeIcon, color: theme.colorScheme.primary, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        scopeLabel,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (organizationName != null && organizationName.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.business_outlined, color: theme.colorScheme.primary, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          organizationName,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ]
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Preguntas
            Text(
              t.survey_questions(survey.questions.length),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: survey.questions.length,
              itemBuilder: (context, index) {
                final question = survey.questions[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        radius: 16,
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (question.type != null && question.type!.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      question.type!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                Expanded(
                                  child: Text(
                                    question.description ?? 'No description',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoRow(
  BuildContext context,
  String label,
  String value,
) {
  final theme = Theme.of(context);

  return Align(
    alignment: Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    ),
  );
}

