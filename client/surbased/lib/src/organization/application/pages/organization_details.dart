import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
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
            organizationId: organizationProvider.selectedOrganization!.id,
            isCurrentOrganization: false,
          );

          await organizationProvider.getUsersInOrganization(
            authProvider.token!,
            organizationId: organizationProvider.selectedOrganization!.id,
            isCurrentOrganization: false,
          );
      
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }


  void _removeOrganization() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

    try {
      if (authProvider.token != null && mounted) {
        final isDeleted = await organizationProvider.deleteOrganization(organizationProvider.selectedOrganization!.id.toString(), authProvider.token!);
        if (isDeleted && mounted) {
          organizationProvider.getOrganizations(authProvider.token!);
          Navigator.popUntil(context, (route) => route.isFirst);

        } else{ 
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(organizationProvider.error!)),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _showRemoveOrganizationDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.organization_remove),
        content: Text(t.organization_remove_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => _removeOrganization(),
            child: Text(t.remove),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => {
            Navigator.pop(context),
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(organizationProvider.selectedOrganization!.name),
        actions: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => {
                          Navigator.pushNamed(context, AppRoutes.organizationEdit)
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(t.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => _showRemoveOrganizationDialog(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.delete,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(t.remove),
                          ],
                        ),
                      ),
                    ])
          ],
          bottom: TabBar(
            dividerHeight: 0,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: theme.colorScheme.surface,
            unselectedLabelColor: theme.colorScheme.surface.withOpacity(0.7),
            indicatorColor: theme.colorScheme.surface,
            controller: tabController,
            tabAlignment: TabAlignment.fill,
            tabs: [
              Tab(text: t.surveys_page_title),
              Tab(text: t.users_page_title),
            ],
          ),
          ),
      body: SafeArea(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const SizedBox(height: 20),
                Expanded(
                  child: TabBarView(
                    controller: tabController,
                    children: [
                      SurveyList(surveys: organizationProvider.selectedOrganization!.surveys ?? []),
                      const OrganizationUsers(isCurrentOrganization: false),
                    ],
                  ),
                ),
            ],
          ),
        ),
    );
  }
}
