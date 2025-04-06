import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/widgets/gender_form_field_widget.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/widgets/user_form.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Text(t.create_account,
                      style: theme.textTheme.displayMedium),
                  const SizedBox(height: 30),
                  const UserForm(),
                ]),
          ),
        ),
      ),
    );
  }
}
