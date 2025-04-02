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

    if (authProvider.userRole == null || surveyProvider.isLoading || organizationProvider.isLoading
    || organizationProvider.organization == null || organizationProvider.organization!.surveys == null) {
      return;
    }

    switch(authProvider.userRole) {
      case 'admin':
        tabTitles = [
          Tab(text: AppLocalizations.of(context)!.scope_private),
          Tab(text: AppLocalizations.of(context)!.scope_organization),
          Tab(text: AppLocalizations.of(context)!.scope_public),
        ];
        tabViews = [
          SurveyList(surveys: surveyProvider.surveysOwned),
          SurveyList(surveys: organizationProvider.organization!.surveys!),
          SurveyList(surveys: surveyProvider.publicSurveys),
        ];
      case 'researcher':
        tabTitles = [
          Tab(text: AppLocalizations.of(context)!.surveys_owned),
          Tab(text: AppLocalizations.of(context)!.surveys_assigned),
        ];
        tabViews = [
          SurveyList(surveys: surveyProvider.surveysOwned),
          SurveyList(surveys: authProvider.surveysAssigned),
        ];
      case 'participant':
        tabTitles = [
          Tab(text: AppLocalizations.of(context)!.surveys_assigned),
          Tab(text: AppLocalizations.of(context)!.organization),
        ];
        tabViews = [
          SurveyList(surveys: authProvider.surveysAssigned),
          SurveyList(surveys: organizationProvider.organization!.surveys!),
        ];
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
                  AppLocalizations.of(context)!.surveys_page_title,
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
