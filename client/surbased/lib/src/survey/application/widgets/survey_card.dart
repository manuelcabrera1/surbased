import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';

class SurveyCard extends StatelessWidget {
  final Survey survey;
  final VoidCallback onTap;
  final String userRole;
  final Category category;
  static const int _maxVisibleTags = 5;

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

  // Lista de colores para las tags
  static const List<Color> _tagColors = [
    Color(0xFFE8F5E9), // green.shade50
    Color(0xFFFFF3E0), // orange.shade50
    Color(0xFFF3E5F5), // purple.shade50
    Color(0xFFE3F2FD), // blue.shade50
    Color(0xFFFFEBEE), // red.shade50
    Color(0xFFE0F2F1), // teal.shade50
    Color(0xFFFCE4EC), // pink.shade50
    Color(0xFFE8EAF6), // indigo.shade50
  ];

  Widget _buildTagChip(BuildContext context, String text, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 2, bottom: 4),
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        label: Text(
          text,
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
  }

  Widget _buildStatusLabel(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        t.survey_status_pending,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;

    final isSurveyAvailable = survey.startDate.isBefore(
                                DateTime.now().add(const Duration(days: 1))) &&
                            survey.endDate.isAfter(DateTime.now());

    final isSurveyNotStarted = survey.startDate.isAfter(DateTime.now());

    return Card(
      elevation: 4,
      child: Stack(
        children: [
          InkWell(
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
                  if (userRole == 'admin') ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          survey.organizationId != null 
                              ? Icons.business_outlined 
                              : Icons.person_outline,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            survey.organizationId != null 
                                ? organizationProvider.getOrganizationName(survey.organizationId!)
                                : userProvider.getUserEmail(survey.ownerId),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        isSurveyAvailable
                            ? Icons.calendar_month_outlined
                            : isSurveyNotStarted
                                ? Icons.lock_outline
                                : Icons.check_circle_outline,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isSurveyAvailable
                            ? t.survey_end_date(
                                _formatDate(survey.endDate))
                            : isSurveyNotStarted
                                ? t.survey_start_date(
                                _formatDate(survey.startDate))
                                : t.survey_end_date(
                                _formatDate(survey.endDate)),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                  if (survey.tags != null && survey.tags!.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Tags:', 
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        ...survey.tags!.take(_maxVisibleTags).map((tag) {
                          final index = survey.tags!.indexOf(tag);
                          final color = _tagColors[index % _tagColors.length];
                          return _buildTagChip(context, tag.name, color);
                        }),
                        if (survey.tags!.length > _maxVisibleTags)
                          _buildTagChip(
                            context,
                            '+${survey.tags!.length - _maxVisibleTags}',
                            theme.colorScheme.tertiaryContainer,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (survey.assignmentStatus == 'pending')
            Positioned(
              top: 0,
              right: 0,
              child: _buildStatusLabel(context),
            ),
        ],
      ),
    );
  }
}
