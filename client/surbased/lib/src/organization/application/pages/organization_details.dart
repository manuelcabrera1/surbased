import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/organization/application/widgets/organization_section.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/organization/application/widgets/organization_users.dart';
import 'package:surbased/src/survey/application/widgets/survey_list.dart';

class OrganizationDetails extends StatefulWidget {
  const OrganizationDetails({super.key});

  @override
  State<OrganizationDetails> createState() => _OrganizationDetailsState();
}

class _OrganizationDetailsState extends State<OrganizationDetails> with TickerProviderStateMixin{
  late TabController tabController;
  @override
  void initState(){
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getOrganizationData();
    });
    
  }

  void _handleTabSelection(){
    if (tabController.indexIsChanging) {
      setState(() {});
    }
  }
  

  @override
  void dispose(){
    tabController.dispose();
    super.dispose();
  }

  Future<void> _getOrganizationData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

    try {
      await organizationProvider.getSurveysInOrganization(
            authProvider.token!,
          );

          await organizationProvider.getUsersInOrganization(
            authProvider.token!,
          );
      
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;


    return Scaffold(
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Row(
                  children: [
                     GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      organizationProvider.organization!.name,
                      style: theme.textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TabBar(
                  dividerHeight: 0,
                  controller: tabController,
                  tabs: [
                    Tab(text: t.surveys_page_title),
                    Tab(text: t.users_page_title),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      SurveyList(surveys: organizationProvider.organization!.surveys ?? []),
                       const OrganizationUsers(),
                    ],
                  ),
                ),
            ],
          ),
        ),
    );
  }
}
