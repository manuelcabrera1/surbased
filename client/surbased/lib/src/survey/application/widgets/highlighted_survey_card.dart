import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/utils/category_helpers.dart';

class HighlightedSurveyCard extends StatelessWidget {
  final Survey survey;
  final Category? category;
  final VoidCallback onTap;
  final int responseCount;
  static const int _maxVisibleTags = 5;

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


  const HighlightedSurveyCard({
    super.key,
    required this.survey,
    required this.category,
    required this.onTap,
    required this.responseCount,
  });

  

  @override
  Widget build(BuildContext context) {

    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      width: 300,
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Text(
                  survey.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Categoría
                if (category != null)
                  Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        getCategoryName(context, category!.name),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                // Información adicional
                if (survey.tags != null && survey.tags!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    '${t.tags}:', 
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                const Spacer(),
                Row(
                  children: [
                    // Respuestas
                    Icon(
                      Icons.people_outline,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      responseCount > 1
                          ? t.public_survey_responses(responseCount.toString())
                          : responseCount == 1
                              ? t.public_survey_response
                              : t.public_survey_no_responses,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    // Fecha
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(survey.startDate),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}