import 'package:flutter/material.dart';
import 'package:surbased/src/user/application/widgets/user_settings.dart';

class UserSettingsSection extends StatelessWidget {
  const UserSettingsSection({
    super.key,
    required this.items,
    required this.title,
  });

  final Map<String, Function> items;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 4),
            ...items.entries.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 0, top: 0),
                child: UserSettings(title: t.key, onPressed: t.value))),
          ],
        ),
      ),
    );
  }
}
