import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/shared/application/provider/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserThemePage extends StatefulWidget {
  const UserThemePage({super.key});

  @override
  State<UserThemePage> createState() => _UserThemePageState();
}

class _UserThemePageState extends State<UserThemePage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.theme_page_title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
             ListTile(
              leading:  Icon(
                          themeProvider.isDarkMode
                              ? Icons.dark_mode
                              : Icons.light_mode,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
              title: Text(
                          themeProvider.isDarkMode
                              ? t.theme_dark
                              : t.theme_light,
                          style: theme.textTheme.titleLarge,
                        ),
              trailing:  Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
            ),

            const SizedBox(height: 24),

            // Explicación del tema
            Text(
              t.theme_helper,
              style: theme.textTheme.bodyMedium,
            ),


          ],
        ),
      ),
    );
  }
}
