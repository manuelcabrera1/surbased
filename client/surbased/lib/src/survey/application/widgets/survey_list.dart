import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/app.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/pages/survey_complete_page.dart';
import 'package:surbased/src/survey/application/pages/survey_invitation_dialog.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_card.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
import 'survey_list_filter_dialog.dart';

class SurveyList extends StatefulWidget {
  final List<Survey> surveys;
  const SurveyList({super.key, required this.surveys});

  @override
  State<SurveyList> createState() => _SurveyListState();
}

class _SurveyListState extends State<SurveyList> {
  final _searchController = SearchController();
  String? _selectedCategory;
  List<Survey> _surveysToShow = [];

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _selectedCategory = null;
    _surveysToShow = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          if (widget.surveys.isNotEmpty) {
            setState(() {
              _surveysToShow = widget.surveys;
            });
          }
        }
    });
  }

  Future<void> _showSurveyInvitationDialog(Survey survey) async {
    if (navigatorKey.currentContext == null) return;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (mounted && authProvider.token != null) {
        final owner = await userProvider.getUserById(survey.ownerId, authProvider.token!);

        if (owner != null) {

          showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => Dialog(
              child: SurveyInvitationDialog(
                surveyId: survey.id!,
                surveyName: survey.name,
                inviterName: owner.email,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleOnTap(Survey survey) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider =
            Provider.of<SurveyProvider>(context, listen: false);

    if (mounted && authProvider.userRole != null) {
      final userRole = authProvider.userRole;
      if (userRole == 'participant') {
        final answerProvider =
            Provider.of<AnswerProvider>(context, listen: false);
        answerProvider.setCurrentSurveyBeingAnswered(survey);
        surveyProvider.currentSurvey = survey;
        if (survey.assignmentStatus == 'pending') {
          _showSurveyInvitationDialog(survey);
        } else {
          Navigator.pushNamed(context, AppRoutes.surveyComplete);
        }
      } else {
        surveyProvider.currentSurvey = survey;

        if (mounted) {

          Navigator.pushNamed(context, AppRoutes.surveyDetails);
          
        }
      }
    }
  }

  void filterSurveys() {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (mounted) {
      setState(() {
        _surveysToShow = widget.surveys
            .where((survey) {
                String categoryName = categoryProvider.getCategoryById(survey.categoryId).name;
                bool search = survey.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                categoryName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                (survey.tags != null && survey.tags!.any((tag) => tag.name.toLowerCase().contains(_searchController.text.toLowerCase())))
                || survey.organizationId != null && organizationProvider.getOrganizationName(survey.organizationId!).toLowerCase().contains(_searchController.text.toLowerCase())
                || userProvider.getUserEmail(survey.ownerId).toLowerCase().contains(_searchController.text.toLowerCase());
                bool category = _selectedCategory == null || _selectedCategory == survey.categoryId;
                return search && category;
            })
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
    final t = AppLocalizations.of(context)!;

    if (authProvider.userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userRole = authProvider.userRole!;

    if (surveyProvider.isLoading || categoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
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
                          const EdgeInsets.symmetric(horizontal: 10)),
                      leading: Icon(Icons.search,
                          color: theme.colorScheme.onSurfaceVariant),
                      trailing: [
                        if (_searchController.text != '')
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _surveysToShow = widget.surveys;
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
                            _surveysToShow = widget.surveys;
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
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list_outlined, size: 30),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 10),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryProvider.categories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(t.categories_all),
                          selected: _selectedCategory == null,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = null);
                            filterSurveys();
                          },
                        ),
                      );
                    }
                    final category = categoryProvider.categories[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(Category.getCategoryName(context, category.name)),
                        selected: _selectedCategory == category.id,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category.id);
                          filterSurveys();
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
            ],
          ),
        ),
        if (widget.surveys.isEmpty || _surveysToShow.isEmpty) ...[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [    
                Center(
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
                        t.surveys_error_no_surveys,
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ] else ...[
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              itemCount: _surveysToShow.length,
              itemBuilder: (context, index) => SurveyCard(
                userRole: userRole,
                survey: _surveysToShow[index],
                category: categoryProvider
                    .getCategoryById(_surveysToShow[index].categoryId),
                onTap: () => _handleOnTap(_surveysToShow[index]),
              ),
            ),
            ),
        ]
      ],
    );
  }
}
