import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/widgets/user_form.dart';


class UserCreatePage extends StatefulWidget {
  const UserCreatePage({super.key});

  @override
  State<UserCreatePage> createState() => UserCreatePageState();
}

class UserCreatePageState extends State<UserCreatePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Create a New User',
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  const UserForm(),
                ],
              ),
          ),
      ),
    );
  }
}
