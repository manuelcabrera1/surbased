import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/widgets/organization_card.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/organization/domain/organization_model.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class OrganizationList extends StatefulWidget {
  const OrganizationList({super.key});

  @override
  State<OrganizationList> createState() => _OrganizationListState();
}

class _OrganizationListState extends State<OrganizationList> {
  final _searchController = SearchController();
  List<Organization> _organizationsToShow = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.isAuthenticated && authProvider.token != null) {
      organizationProvider.getOrganizations(authProvider.token ?? '');
      setState(() {
        _organizationsToShow = organizationProvider.organizations;
      });
    }
  }

  void filterOrganizations() {
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

    if (mounted) {
      setState(() {
        _organizationsToShow = organizationProvider.organizations.where((organization) {
          return organization.name.toLowerCase().contains(_searchController.text.toLowerCase());
        }).toList();
      });
    }
  }


  Future<void> _handleOnTap(Organization organization) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    if (mounted && authProvider.userRole != null) {
      organizationProvider.organization = organization;
      Navigator.pushNamed(context, AppRoutes.organizationDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
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
                  t.organizations_page_title,
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
                                      _organizationsToShow = organizationProvider.organizations;
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                )
                            ],
                            onChanged: (value) {
                              if (_searchController.text != '') {
                                filterOrganizations();
                              } else {
                                setState(() {
                                  _organizationsToShow = organizationProvider.organizations;
                                });
                              }
                            },
                            onSubmitted: (value) {
                              filterOrganizations();
                            },
                            hintText: t.organization_searchbar_placeholder,
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                childAspectRatio: 1,
                mainAxisSpacing: 2,
              ),
              itemCount: _searchController.text.isEmpty 
                ? organizationProvider.organizations.length 
                : _organizationsToShow.length,
              itemBuilder: (context, index) {
                final organization = _searchController.text.isEmpty 
                  ? organizationProvider.organizations[index]
                  : _organizationsToShow[index];
                return OrganizationCard(
                  organization: organization,
                  onTap: () => _handleOnTap(organization),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}