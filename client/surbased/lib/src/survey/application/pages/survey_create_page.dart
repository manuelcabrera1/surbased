import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../category/application/provider/category_provider.dart';


class SurveyCreatePage extends StatefulWidget {
  const SurveyCreatePage({super.key});

  @override
  State<SurveyCreatePage> createState() => SurveyCreatePageState();
}

class SurveyCreatePageState extends State<SurveyCreatePage> {
  @override
  Widget build(BuildContext context) {
    final surveyProvider = Provider.of<SurveyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.survey_new),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => {
            Navigator.pop(context),
            surveyProvider.clearCurrentSurvey(),
          },
        ),
      ),
      body: const SingleChildScrollView(
        child: SurveyForm(),
      ),
    );
  }
}
