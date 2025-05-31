import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
import 'package:surbased/src/utils/category_helpers.dart';

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

  Widget _buildStatusLabel(BuildContext context, String status, {Color? backgroundColor, Color? textColor}) {
    final theme = Theme.of(context);
    final statusColor = backgroundColor ?? Colors.red.shade700;
    final labelTextColor = textColor ?? Colors.red.shade700;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        status,
        style: theme.textTheme.labelSmall?.copyWith(
          color: labelTextColor,
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final isSurveyAnswered = authProvider.surveysAnswers.any((answer) => answer.surveyId == survey.id);
    final isSurveyAvailable = survey.startDate!.isBefore(
                                DateTime.now().add(const Duration(days: 1))) &&
                            survey.endDate!.isAfter(DateTime.now());
    final isSurveyNotStarted = survey.startDate!.isAfter(DateTime.now());
    final isSurveyFinished = survey.endDate!.isBefore(DateTime.now());
    final isSurveyPending = survey.assignmentStatus == 'invited_pending' && survey.endDate!.isAfter(DateTime.now());

    // NUEVO DISEÑO DE TARJETA
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.cardColor, // fondo blanco o azul muy claro
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.12), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: userRole == 'participant'
              ? survey.startDate!.isBefore(DateTime.now())
                  ? onTap
                  : null
              : onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Título y badge de estado
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            survey.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        if (isSurveyPending)
                          _buildStatusLabel(
                            context,
                            t.survey_status_pending,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
                            textColor: theme.colorScheme.primary,
                          ),
                        if (isSurveyFinished)
                          _buildStatusLabel(
                            context,
                            t.survey_status_ended,
                            backgroundColor: theme.colorScheme.surfaceTint.withOpacity(0.3),
                            textColor: theme.colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                    // Categoría debajo del título
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          getCategoryIcon(category.name),
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            getCategoryName(context, category.name),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Preguntas y fecha en la misma línea
                    Row(
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          survey.questions.length > 1
                              ? '${survey.questions.length} ${t.questions}'
                              : '1 ${t.question}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          isSurveyAvailable
                              ? Icons.calendar_month_outlined
                              : isSurveyNotStarted
                                  ? Icons.lock_outline
                                  : Icons.check_circle_outline,
                          size: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isSurveyAvailable
                              ? t.survey_end_date(_formatDate(survey.endDate!))
                              : isSurveyNotStarted
                                  ? t.survey_start_date(_formatDate(survey.startDate!))
                                  : t.survey_end_date(_formatDate(survey.endDate!)),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        if (isSurveyAnswered) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle_outline,
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    if (userRole == 'admin') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            survey.organizationId != null
                                ? Icons.business_outlined
                                : Icons.person_outline,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              survey.organizationId != null
                                  ? organizationProvider.getOrganizationName(survey.organizationId!)
                                  : userProvider.getUserEmail(survey.ownerId),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (survey.tags != null && survey.tags!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
