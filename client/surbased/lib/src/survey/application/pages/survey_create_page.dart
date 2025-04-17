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
  final bool isGeneratingWithAI;
  const SurveyCreatePage({super.key, this.isGeneratingWithAI = false});

  @override
  State<SurveyCreatePage> createState() => SurveyCreatePageState();
}

class SurveyCreatePageState extends State<SurveyCreatePage> {
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
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                          child: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.isGeneratingWithAI ? t.survey_create_page_title_ai : t.survey_create_page_title,
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.isGeneratingWithAI) ...[
                    const SizedBox(height: 20),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), 
                    child: Text('Complete the following fields to generate the survey. You can edit it later.', style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),)),
                  ],
                  SurveyForm(isGeneratingWithAI: widget.isGeneratingWithAI),
                ],
              ),
          ),
      ),
    );
  }
}
