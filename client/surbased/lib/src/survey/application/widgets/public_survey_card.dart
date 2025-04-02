import 'package:flutter/material.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/category/domain/category_model.dart';

class PublicSurveyCard extends StatelessWidget {
  final Survey survey;
  final Category? category;
  final VoidCallback onTap;
  final int responseCount;
  static const int _maxVisibleTags = 2;

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color.computeLuminance() > 0.5 
              ? Colors.black87 
              : Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  const PublicSurveyCard({
    super.key,
    required this.survey,
    required this.category,
    required this.onTap,
    required this.responseCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                survey.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: survey.name.length > 20 ? 16 : 17,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Categoría
              if (category != null)
                Row(
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category!.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              if (survey.tags != null && survey.tags!.isNotEmpty) ...[
                const SizedBox(height: 10),
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
              const Spacer(),
              // Información adicional
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Respuestas
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$responseCount respuestas',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Fecha
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
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
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}