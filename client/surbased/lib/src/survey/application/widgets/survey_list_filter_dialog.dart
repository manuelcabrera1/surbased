import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SurveyListFilterDialog extends StatefulWidget {
  const SurveyListFilterDialog({super.key});

  @override
  State<SurveyListFilterDialog> createState() => _SurveyListFilterDialogState();
}

class _SurveyListFilterDialogState extends State<SurveyListFilterDialog> {
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
            child: Text(AppLocalizations.of(context)!.filter,
                style: theme.textTheme.displaySmall),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.sort_by,
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}
