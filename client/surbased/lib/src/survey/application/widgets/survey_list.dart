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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'survey_list_filter_dialog.dart';

class SurveyList extends StatefulWidget {
  const SurveyList({super.key});

  @override
  State<SurveyList> createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  final _searchController = SearchController();
  String _searchQuery = '';
  List<Survey> _surveysToShow = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      if (surveyProvider.surveys.isNotEmpty) {
        setState(() {
          _surveysToShow = surveyProvider.surveys;
        });
      }
    }
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

  void filterSurveys() {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);

    if (mounted) {
      setState(() {
        _surveysToShow = surveyProvider.surveys
            .where((survey) =>
                survey.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const SurveyListFilterDialog(),
    );
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
                  AppLocalizations.of(context)!.surveys_page_title,
                  style: theme.textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 48,
                        child: SearchBar(
                          controller: _searchController,
                          padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 10)),
                          leading: Icon(Icons.search,
                              color: theme.colorScheme.onSurfaceVariant),
                          trailing: [
                            if (_searchQuery != '')
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _surveysToShow = surveyProvider.surveys;
                                  });
                                },
                                icon: const Icon(Icons.close),
                              )
                          ],
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            if (_searchQuery != '') {
                              filterSurveys();
                            } else {
                              setState(() {
                                _surveysToShow = surveyProvider.surveys;
                              });
                            }
                          },
                          onSubmitted: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            filterSurveys();
                          },
                          hintText: AppLocalizations.of(context)!
                              .surveys_searchbar_placeholder,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _showFilterDialog,
                      icon: const Icon(Icons.filter_list_outlined, size: 30),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              if (surveyProvider.surveys.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.surveys_error_no_surveys,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _surveysToShow.length,
                  itemBuilder: (context, index) => SurveyCard(
                    userRole: userRole,
                    survey: _surveysToShow[index],
                    category: categoryProvider
                        .getCategoryById(_surveysToShow[index].categoryId),
                    onTap: () => _handleOnTap(_surveysToShow[index]),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
