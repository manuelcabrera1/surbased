import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/organization/application/widgets/organization_form.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../category/application/provider/category_provider.dart';


class OrganizationEditPage extends StatefulWidget {
  const OrganizationEditPage({super.key});

  @override
  State<OrganizationEditPage> createState() => OrganizationEditPageState();
}

class OrganizationEditPageState extends State<OrganizationEditPage> {

  

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
                          onPressed: () => {
                            Navigator.pop(context),
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          t.organization_edit_page_title,
                          maxLines: 2,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: t.organization_edit_page_title.length > 20 ? 25 : 30,
                          ),
                        ),
                      ],
                    ),
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: OrganizationForm(isEditing: true)
                  )
                ],
              ),
          ),
      ),
    );
  }
}
