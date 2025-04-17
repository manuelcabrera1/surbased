import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/config/app_routes.dart';

class CreateResourceDialog extends StatelessWidget {
  const CreateResourceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.create_resource_title,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildOption(
              context,
              icon: Icons.business_outlined,
              title: t.create_organization,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.organizationCreate);
              },
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              icon: Icons.assignment_outlined,
              title: t.create_survey,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.surveyCreate);
              },
            ),
            const SizedBox(height: 12),
            _buildOption(
              context,
              icon: Icons.person_add_outlined,
              title: t.create_user,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.userCreate);
              },
            ),
            const SizedBox(height: 25),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

  