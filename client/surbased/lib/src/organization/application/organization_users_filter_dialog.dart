import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class OrganizationUsersFilterDialog extends StatelessWidget {
  const OrganizationUsersFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(t.filter, style: theme.textTheme.displaySmall),
          ),
          const SizedBox(height: 16),
          Text(t.sort_by,
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}
