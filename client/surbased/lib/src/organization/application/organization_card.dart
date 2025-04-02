import 'package:flutter/material.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:surbased/src/organization/domain/organization_model.dart';

class OrganizationCard extends StatelessWidget {
  final Organization organization;
  final VoidCallback onTap;

  const OrganizationCard({
    super.key,
    required this.organization,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Icono de la categoría
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 30,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    organization.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Divider(thickness: 0.5, color: theme.colorScheme.surfaceTint),
              // Número de encuestas
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${organization.usersCount}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.quiz,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${organization.surveysCount}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 