import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/widgets/user_form.dart';
import 'package:surbased/src/user/domain/user_model.dart';
import '../../../category/application/provider/category_provider.dart';

class UserEditPage extends StatefulWidget {
  final User? user;
  const UserEditPage({super.key, this.user});

  @override
  State<UserEditPage> createState() => UserEditPageState();
}

class UserEditPageState extends State<UserEditPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            Navigator.pop(context),
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: UserForm(user: widget.user),
        ),
      ),
    );
  }
}
