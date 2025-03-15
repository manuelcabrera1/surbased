import 'package:flutter/material.dart';

class OrganizationUsersFilterDialog extends StatelessWidget {
  const OrganizationUsersFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Text('Filter', style: theme.textTheme.displaySmall),
          ),
          const SizedBox(height: 16),
          Text('Sort by',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}
