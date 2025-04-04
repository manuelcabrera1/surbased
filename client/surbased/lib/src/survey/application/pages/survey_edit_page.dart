import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../category/application/provider/category_provider.dart';

class SurveyEditPage extends StatefulWidget {
  const SurveyEditPage({super.key});

  @override
  State<SurveyEditPage> createState() => SurveyEditPageState();
}

class SurveyEditPageState extends State<SurveyEditPage> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.survey_edit),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            Navigator.pop(context),
          },
        ),
      ),
      body: const SingleChildScrollView(
        child: SurveyForm(),
      ),
    );
  }
}
