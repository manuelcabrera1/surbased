import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/pages/survey_complete_page.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_card.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';

class SurveyList extends StatefulWidget {
  const SurveyList({super.key});

  @override
  State<SurveyList> createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _handleOnTap(Survey survey) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (mounted && authProvider.userRole != null) {
      final userRole = authProvider.userRole;
      if (userRole == 'participant') {
        final answerProvider =
            Provider.of<AnswerProvider>(context, listen: false);
        answerProvider.setCurrentSurveyBeingAnswered(survey);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurveyCompletePage(
              survey: survey,
            ),
          ),
        );
      } else {
        final surveyProvider =
            Provider.of<SurveyProvider>(context, listen: false);
        surveyProvider.currentSurvey = survey;

        if (mounted) {
          Navigator.pushNamed(context, AppRoutes.surveyDetail);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);

    if (authProvider.userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userRole = authProvider.userRole!;

    if (surveyProvider.isLoading || categoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Surveys',
                  style: theme.textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 30),
              if (surveyProvider.surveys.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No surveys found'),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: surveyProvider.surveys.length,
                  itemBuilder: (context, index) => SurveyCard(
                    userRole: userRole,
                    survey: surveyProvider.surveys[index],
                    category: categoryProvider.getCategoryById(
                        surveyProvider.surveys[index].categoryId),
                    onTap: () => _handleOnTap(surveyProvider.surveys[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
