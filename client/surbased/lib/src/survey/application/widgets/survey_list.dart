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
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Solo cargar las encuestas una vez
    if (!_isInitialized) {
      _isInitialized = true;

      // Usar addPostFrameCallback para asegurarnos de que el build ha terminado
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.isAuthenticated &&
              authProvider.userId != null &&
              authProvider.userRole != null &&
              authProvider.token != null) {
            final surveyProvider =
                Provider.of<SurveyProvider>(context, listen: false);
            surveyProvider.getSurveys(
              authProvider.userId!,
              authProvider.userRole!,
              authProvider.token!,
              null,
            );
          }
        }
      });
    }
  }

  void disponse() {
    super.dispose();
    _isInitialized = false;
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
        : SafeArea(
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
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: surveyProvider.surveys.length,
                      itemBuilder: (context, index) => SurveyCard(
                        userRole: userRole,
                        survey: surveyProvider.surveys[index],
                        onTap: () => userRole == 'researcher'
                            ? Navigator.pushNamed(
                                context, AppRoutes.surveyDetail,
                                arguments: surveyProvider.surveys[index])
                            : Navigator.pushNamed(
                                context, AppRoutes.surveyComplete,
                                arguments: surveyProvider.surveys[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
