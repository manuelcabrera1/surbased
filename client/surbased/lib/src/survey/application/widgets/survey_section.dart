import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'survey_list.dart';

class SurveySection extends StatefulWidget {
  const SurveySection({super.key});

  @override
  State<SurveySection> createState() => _SurveySectionState();
}

class _SurveySectionState extends State<SurveySection> with TickerProviderStateMixin{
  late TabController tabController;
  List<Tab> tabTitles = [];
  List<Widget> tabViews = [];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 1, vsync: this);
    tabController.addListener(_handleTabSelection);

          
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          _configureTabs();
        }
      });
    
  }

  void _handleTabSelection() {
    if (tabController.indexIsChanging) {
      setState(() {});
    }
  }

  void _configureTabs() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;

    if (authProvider.userRole == null || surveyProvider.isLoading || organizationProvider.isLoading) {
      return;
    }

    switch(authProvider.userRole) {
      case 'admin':
      tabViews = [
          SurveyList(surveys: surveyProvider.privateSurveys),
          SurveyList(surveys: surveyProvider.organizationSurveys),
          SurveyList(surveys: surveyProvider.publicSurveys),
        ];
        tabTitles = [
          Tab(text: '${t.scope_private} (${surveyProvider.privateSurveys.length})'),
          Tab(text: '${t.scope_organization} (${surveyProvider.organizationSurveys.length})'),
          Tab(text: '${t.scope_public} (${surveyProvider.publicSurveys.length})'),
        ];
        
        break;
      case 'researcher':
        tabViews = [
          SurveyList(surveys: surveyProvider.surveysOwned),
          SurveyList(surveys: authProvider.surveysAssigned),
        ];
        tabTitles = [
          Tab(text: '${t.surveys_owned} (${surveyProvider.surveysOwned.length})'),
          Tab(text: '${t.surveys_assigned} (${authProvider.surveysAssigned.length})'),
        ];
        break;
      case 'participant':
      tabViews = [
          SurveyList(surveys: authProvider.surveysAssigned),
          SurveyList(surveys: organizationProvider.organization?.surveys ?? []),
        ];
        tabTitles = [
          Tab(text: '${t.surveys_assigned} (${authProvider.surveysAssigned.length})'),
          Tab(text: '${t.organization} (${organizationProvider.organization != null && organizationProvider.organization!.surveys != null 
                                          ? organizationProvider.organization!.surveys!.length 
                                          : 0})'),
        ];
        
        break;
    }

    tabController.dispose(); // Primero liberar el controlador actual
    tabController = TabController(length: tabTitles.length, vsync: this);
    tabController.addListener(_handleTabSelection);
    
    setState(() {}); // Forzar rebuild
  }

  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final t = AppLocalizations.of(context)!;

    if (tabTitles.isEmpty || tabViews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (authProvider.userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }


    if ( authProvider.isLoading || surveyProvider.isLoading || categoryProvider.isLoading || organizationProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  t.surveys_page_title,
                  style: theme.textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 20),
              TabBar(
                dividerHeight: 0,
                controller: tabController,
                tabs: tabTitles,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: tabViews,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
