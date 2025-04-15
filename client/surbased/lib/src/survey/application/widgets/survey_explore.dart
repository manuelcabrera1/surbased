import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/pages/survey_access_request_dialog.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/provider/tags_provider.dart';
import 'package:surbased/src/survey/application/widgets/highlighted_survey_card.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/survey/application/widgets/public_survey_card.dart';
import 'package:surbased/src/survey/application/widgets/category_card.dart';

class SurveyExplore extends StatefulWidget {
  const SurveyExplore({super.key});

  @override
  State<SurveyExplore> createState() => _SurveyExploreState();
}

class _SurveyExploreState extends State<SurveyExplore> {
  final _searchController = SearchController();
  List<Survey> _surveysToShow = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //_loadInitialData();
    });
  }


  void filterSurveys() {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

    if (mounted) {
      setState(() {
        _surveysToShow = surveyProvider.publicSurveys.where((survey) {
          String categoryName = categoryProvider.getCategoryById(survey.categoryId).name;
          bool search = survey.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          categoryName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          (survey.tags?.any((tag) => tag.name.toLowerCase().contains(_searchController.text.toLowerCase())) ?? false);
          return search;
        }).toList();
      });
    }
  }

  int _getSurveyCountForCategory(String categoryId) {
    final surveyProvider = Provider.of<SurveyProvider>(context);
    return surveyProvider.publicSurveys.where((survey) => 
      survey.categoryId == categoryId
    ).length;
  }

  Future<void> _handleOnTap(Survey survey) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    if (mounted && authProvider.userRole != null) {
      final userRole = authProvider.userRole;
      if (userRole == 'participant') {
        final answerProvider =
            Provider.of<AnswerProvider>(context, listen: false);

        if (authProvider.surveysAssigned.any((e) => e.id == survey.id)) {
          surveyProvider.currentSurvey = survey;
          answerProvider.setCurrentSurveyBeingAnswered(survey);
          Navigator.pushNamed(context, AppRoutes.surveyComplete);
        } else {
          showDialog(
            context: context,
            builder: (context) => SurveyAccessRequestDialog(survey: survey),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final t = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  t.explore_page_title,
                  style: theme.textTheme.displayMedium
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        flex: 1,
                        child: SizedBox(
                          height: 48,
                          child: SearchBar(
                            controller: _searchController,
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 10)
                            ),
                            leading: Icon(
                              Icons.search,
                              color: theme.colorScheme.onSurfaceVariant
                            ),
                            trailing: [
                              if (_searchController.text != '')
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _surveysToShow = surveyProvider.publicSurveys;
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                )
                            ],
                            onChanged: (value) {
                              if (_searchController.text != '') {
                                filterSurveys();
                              } else {
                                setState(() {
                                  _surveysToShow = surveyProvider.publicSurveys;
                                });
                              }
                            },
                            onSubmitted: (value) {
                              filterSurveys();
                            },
                            hintText: t.surveys_searchbar_placeholder,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Contenido principal
            if (_searchController.text.isEmpty) ...[
              Expanded(
                child: surveyProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          // Sección de encuestas destacadas
                          if (surveyProvider.highlightedPublicSurveys.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                'Encuestas destacadas',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: surveyProvider.highlightedPublicSurveys.length,
                                itemBuilder: (context, index) {
                                  final survey = surveyProvider.highlightedPublicSurveys[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 300,
                                      child: HighlightedSurveyCard(
                                        survey: survey,
                                        onTap: () => _handleOnTap(survey),
                                        category: categoryProvider.getCategoryById(survey.categoryId),
                                        responseCount: survey.responseCount ?? 0,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          // Sección de categorías
                          if (categoryProvider.categories.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(
                                'Categorías',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: categoryProvider.categories.length,
                                itemBuilder: (context, index) {
                                  final category = categoryProvider.categories[index];
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CategoryCard(
                                      category: category,
                                      onTap: () {
                                        // TODO: Navegar a la página de encuestas por categoría
                                      },
                                      surveyCount: _getSurveyCountForCategory(category.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                          // Grid de todas las encuestas
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'Todas las encuestas (${surveyProvider.publicSurveys.length})',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                              childAspectRatio: 0.95,
                              mainAxisSpacing: 2,
                            ),
                            itemCount: surveyProvider.publicSurveys.length,
                            itemBuilder: (context, index) {
                              final survey = surveyProvider.publicSurveys[index];
                              return PublicSurveyCard(
                                survey: survey,
                                onTap: () => _handleOnTap(survey),
                                category: categoryProvider.getCategoryById(survey.categoryId),
                                responseCount: survey.responseCount ?? 0,
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ] else ...[
              // Resultados de búsqueda
              Expanded(
                child: _surveysToShow.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron encuestas',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          childAspectRatio: 0.85,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                        itemCount: _surveysToShow.length,
                        itemBuilder: (context, index) {
                          final survey = _surveysToShow[index];
                          return PublicSurveyCard(
                            survey: survey,
                            onTap: () => _handleOnTap(survey),
                            category: categoryProvider.getCategoryById(survey.categoryId),
                            responseCount: survey.responseCount ?? 0,
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}