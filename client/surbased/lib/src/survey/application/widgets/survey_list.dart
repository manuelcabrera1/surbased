import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/infrastructure/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/widgets/survey_card.dart';
import 'package:surbased/src/survey/infrastructure/survey_provider.dart';

class SurveyList extends StatefulWidget {
  const SurveyList({super.key});

  @override
  State<SurveyList> createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    surveyProvider.getSurveys(authProvider.userId!, authProvider.userRole!,
        authProvider.token!, null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);

    final userRole = authProvider.userRole!;

    if (surveyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return surveyProvider.surveys.isEmpty
        ? Center(
            child: Text(
              'No surveys found',
              style: theme.textTheme.bodyMedium,
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25, top: 60, bottom: 30),
                child: Text(
                  'Surveys',
                  style: theme.textTheme.displayMedium,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: surveyProvider.surveys.length,
                  itemBuilder: (context, index) => SurveyCard(
                    survey: surveyProvider.surveys[index],
                    onTap: () => userRole == 'researcher'
                        ? Navigator.pushNamed(context, AppRoutes.surveyDetail,
                            arguments: surveyProvider.surveys[index])
                        : Navigator.pushNamed(context, AppRoutes.surveyComplete,
                            arguments: surveyProvider.surveys[index]),
                  ),
                ),
              ),
            ],
          );
  }
}
