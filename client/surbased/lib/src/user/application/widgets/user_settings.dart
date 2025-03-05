import 'package:flutter/material.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({
    super.key,
    required this.title,
    required this.onPressed,
  });

  final String title;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
        onTap: () => onPressed(),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 0, top: 0),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.tertiary,
              fontSize: 18,
            ),
          ),
        ),
        visualDensity: VisualDensity.comfortable,
        dense: true,
        trailing: const Icon(Icons.arrow_forward_ios_rounded));
  }
}
