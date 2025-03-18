import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/shared/application/provider/lang_provider.dart';

class UserAccessibilityPage extends StatelessWidget {
  const UserAccessibilityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LangProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.accessibility_page_title),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(AppLocalizations.of(context)!.language),
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
            ],
          ),
        ));
  }
}
