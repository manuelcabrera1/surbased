import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    
    final theme = Theme.of(context);

    return SizedBox(
      width: 300,
      height: 200,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
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
                        size: 25,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category!.name,
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
                  '${AppLocalizations.of(context)!.tags}:', 
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
              ] else ...[
                const Spacer(),
              ],
                Row(
                  children: [
                    // Respuestas
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          responseCount > 1
                              ? AppLocalizations.of(context)!.public_survey_responses(responseCount.toString())
                              : responseCount == 1
                                  ? AppLocalizations.of(context)!.public_survey_response
                                  : AppLocalizations.of(context)!.public_survey_no_responses,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Fecha
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(survey.startDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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