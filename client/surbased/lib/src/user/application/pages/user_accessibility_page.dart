import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/shared/application/provider/lang_provider.dart';
import 'package:surbased/src/shared/application/provider/accessibility_provider.dart';

class UserAccessibilityPage extends StatelessWidget {
  const UserAccessibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LangProvider>(context);
    final accessibilityProvider = Provider.of<AccessibilityProvider>(context);
    final t = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(t.accessibility_page_title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Idioma
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(t.language),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: langProvider.locale,
                  onChanged: (value) => langProvider.locale = value!,
                  items: AppLocalizations.supportedLocales
                      .map((locale) => DropdownMenuItem<Locale>(
                            value: locale,
                            child: Text(locale.toString()),
                            onTap: () => langProvider.locale = locale,
                          ))
                      .toList(),
                ),
              ),
            ),
            
            // Tamaño del texto
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text(t.text_size),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: accessibilityProvider.textSize,
                  onChanged: (value) => accessibilityProvider.textSize = value!,
                  items: [
                    DropdownMenuItem(
                      value: 'small',
                      child: Text(t.text_size_small),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text(t.text_size_medium),
                    ),
                    DropdownMenuItem(
                      value: 'large',
                      child: Text(t.text_size_large),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
