import 'package:flutter/material.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final int surveyCount;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.surveyCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Card(
      color: theme.colorScheme.primaryContainer,
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icono de la categoría
              const SizedBox(height: 5),
              Center(
                  child: Icon(
                    Icons.category_outlined,
                    size: 30,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              const SizedBox(height: 12),
              // Nombre de la categoría
              Text(
                Category.getCategoryName(context, category.name),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              // Número de encuestas
              const SizedBox(height: 4),
              Text(
                surveyCount == 1 
                    ? t.category_survey_count_one
                    : t.category_survey_count(surveyCount),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 