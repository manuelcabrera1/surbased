import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/app.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_invitation_dialog.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_card.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/domain/survey_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
import 'package:surbased/src/utils/category_helpers.dart';
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
  String _sortField = 'endDate';
  bool _isAscending = false;
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  bool _includeFinished = false;

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
              _surveysToShow = widget.surveys.where((survey) => survey.endDate!.isAfter(DateTime.now())).toList();
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

        if (owner != null && mounted) {
          final t = AppLocalizations.of(context)!;
          showDialog(
            context: navigatorKey.currentContext!,
            builder: (context) => SurveyInvitationDialog(
                surveyId: survey.id!,
                surveyName: survey.name,
                inviterName: owner.email,
                notificationTitle: t.survey_invitation_title,
                notificationBody: t.survey_invitation_message(owner.email, survey.name),
                userId: authProvider.user!.id.toString(),
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
      surveyProvider.currentSurvey = survey;
      if (userRole == 'participant') {
        final answerProvider =
            Provider.of<AnswerProvider>(context, listen: false);
        
        if (authProvider.surveysAnswers.any((answer) => answer.surveyId == survey.id)) {
          answerProvider.setCurrentSurveyBeingAnswered(authProvider.surveysAnswers.firstWhere((answer) => answer.surveyId == survey.id));
        } else {
          answerProvider.initializeCurrentSurveyBeingAnswered(survey);
        }
        if (survey.assignmentStatus == 'invited_pending' ||
            survey.assignmentStatus == 'requested_pending') {
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
                
                // Filtrado por texto de búsqueda y categoría
                bool search = survey.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                categoryName.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                (survey.tags != null && survey.tags!.any((tag) => tag.name.toLowerCase().contains(_searchController.text.toLowerCase())))
                || survey.organizationId != null && organizationProvider.getOrganizationName(survey.organizationId!).toLowerCase().contains(_searchController.text.toLowerCase())
                || userProvider.getUserEmail(survey.ownerId).toLowerCase().contains(_searchController.text.toLowerCase());
                
                bool category = _selectedCategory == null || _selectedCategory == survey.categoryId;
                
                // Filtrado por fecha de inicio
                bool startDateMatch = _startDateFilter == null || 
                    !survey.startDate!.isBefore(_startDateFilter!);
                
                // Filtrado por fecha de fin
                bool endDateMatch = _endDateFilter == null || 
                    !survey.endDate!.isAfter(_endDateFilter!);
                
                // Filtrado por cuestionarios finalizados
                bool finishedMatch = _includeFinished || 
                    survey.endDate!.isAfter(DateTime.now());
                
                return search && category && startDateMatch && endDateMatch && finishedMatch;
            })
            .toList();
        
        // Aplicar ordenamiento
        _applySorting();
      });
    }
  }

  void _applySorting() {
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    _surveysToShow.sort((a, b) {
      int result;
      switch (_sortField) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'startDate':
          result = a.startDate!.compareTo(b.startDate!);
          break;
        case 'endDate':
          result = a.endDate!.compareTo(b.endDate!);
          break;
        case 'organization':
          result = organizationProvider.getOrganizationName(a.organizationId!).compareTo(organizationProvider.getOrganizationName(b.organizationId!));
          break;
        case 'questions':
          result = a.questions.length.compareTo(b.questions.length);
          break;
        default:
          result = a.endDate!.compareTo(b.endDate!);
      }
      
      return _isAscending ? result : -result;
    });
  }

  void _showFilterDialog() {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final canFilterByOrganization = surveyProvider.checkIfAllSurveysBelongToAnOrganization(widget.surveys);
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => SurveyListFilterDialog(
        currentSortField: _sortField,
        isAscending: _isAscending,
        startDateFilter: _startDateFilter,
        endDateFilter: _endDateFilter,
        includeFinished: _includeFinished,
        onApplyFilter: (sortField, isAscending, startDate, endDate, includeFinished) {
          setState(() {
            _sortField = sortField;
            _isAscending = isAscending;
            _startDateFilter = startDate;
            _endDateFilter = endDate;
            _includeFinished = includeFinished;
            filterSurveys();
          });
        },
        canFilterByOrganization: canFilterByOrganization,
      ),
    );
  }

  String _getSortFieldName(String field) {
    final t = AppLocalizations.of(context)!;
    switch (field) {
      case 'name':
        return t.list_sort_name;
      case 'startDate':
        return t.list_sort_start_date;
      case 'endDate':
        return t.list_sort_end_date;
      case 'organization':
        return t.list_sort_organization;
      case 'questions':
        return t.list_sort_questions;
      default:
        return t.list_sort_name;
    }
  }

  void sortCategories() {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.categories.sort((a, b) => getCategoryName(context, a.name).compareTo(getCategoryName(context, b.name)));
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

    sortCategories();

    // Aplicar ordenamiento por defecto la primera vez
    if (_surveysToShow.isNotEmpty) {
      _applySorting();
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
                        label: Text(getCategoryName(context, category.name)),
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
        const SizedBox(height: 24),
        Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _showFilterDialog,
                      child: Wrap(children: [
                        Text(t.list_sorted_by, style: theme.textTheme.bodySmall),
                      Text(
                        _getSortFieldName(_sortField) + (_isAscending ? t.list_ascending : t.list_descending),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      ],),
                    )
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
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
