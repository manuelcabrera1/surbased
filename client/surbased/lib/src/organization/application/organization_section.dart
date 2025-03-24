import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/organization/application/organization_users.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/organization/application/organization_users_filter_dialog.dart';
import 'package:surbased/src/user/domain/user_model.dart';

import '../../survey/application/widgets/survey_list.dart';

class OrganizationSection extends StatefulWidget {
  const OrganizationSection({super.key});

  @override
  State<OrganizationSection> createState() => _OrganizationSectionState();
}

  class _OrganizationSectionState extends State<OrganizationSection> with TickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);

    if (authProvider.isLoading || organizationProvider.isLoading || organizationProvider.organization == null) {
      return const Center(child: CircularProgressIndicator());
    }
    

    return SafeArea(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Text(
                AppLocalizations.of(context)!.organization,
                style: theme.textTheme.displayMedium,
              ),
            ),
            const SizedBox(height: 20),
            TabBar(
                dividerHeight: 0,
                controller: tabController,
                tabs: [
                  Tab(text: AppLocalizations.of(context)!.surveys_page_title),
                  Tab(text: AppLocalizations.of(context)!.users_page_title),
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
      );
  }
}
