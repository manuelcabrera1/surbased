import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserSecurityPage extends StatefulWidget {
  const UserSecurityPage({super.key});

  @override
  State<UserSecurityPage> createState() => _UserSecurityPageState();
}

class _UserSecurityPageState extends State<UserSecurityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.security_page_title),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const Center(child: Text('User Security Page')));
  }
}
