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
import 'package:surbased/src/organization/application/widgets/organization_list_filter_dialog.dart';


class OrganizationList extends StatefulWidget {
  const OrganizationList({super.key});

  @override
  State<OrganizationList> createState() => _OrganizationListState();
}

class _OrganizationListState extends State<OrganizationList> {
  final _searchController = SearchController();
  List<Organization> _organizationsToShow = [];
  String _sortField = 'name';
  bool _isAscending = true;
  String? _selectedSize;

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
          // Filtrado por texto
          final textMatch = organization.name.toLowerCase().contains(_searchController.text.toLowerCase());
          
          // Filtrado por tamaño
          final sizeMatch = _selectedSize == null || _getSizeCategory(organization.usersCount ?? 0) == _selectedSize;
          
          return textMatch && sizeMatch;
        }).toList();
        
        // Aplicar ordenamiento
        _applySorting();
      });
    }
  }
  
  void _applySorting() {
    _organizationsToShow.sort((a, b) {
      int result;
      
      switch (_sortField) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'size':
          final sizeA = a.usersCount ?? 0;
          final sizeB = b.usersCount ?? 0;
          result = sizeA.compareTo(sizeB);
          break;
        case 'surveys':
          final surveysA = a.surveysCount ?? 0;
          final surveysB = b.surveysCount ?? 0;
          result = surveysA.compareTo(surveysB);
          break;
        default:
          result = a.name.compareTo(b.name);
      }
      
      return _isAscending ? result : -result;
    });
  }
  
  String _getSizeCategory(int usersCount) {
    if (usersCount < 10) {
      return 'small';
    } else if (usersCount < 50) {
      return 'medium';
    } else {
      return 'large';
    }
  }

  String _getSortFieldName(String field) {
    switch (field) {
      case 'name':
        return 'Nombre';
      case 'size':
        return 'Tamaño';
      case 'surveys':
        return 'Número de encuestas';
      default:
        return 'Nombre';
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => OrganizationListFilterDialog(
        currentSortField: _sortField,
        isAscending: _isAscending,
        selectedSize: _selectedSize,
        onApplyFilter: (sortField, isAscending, size) {
          setState(() {
            _sortField = sortField;
            _isAscending = isAscending;
            _selectedSize = size;
            filterOrganizations();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final t = AppLocalizations.of(context)!;

    // Asegurarnos de tener la lista actualizada
    if (_organizationsToShow.isEmpty && organizationProvider.organizations.isNotEmpty) {
      _organizationsToShow = [...organizationProvider.organizations];
    }
    
    // Aplicar ordenamiento
    if (_organizationsToShow.isNotEmpty) {
      _applySorting();
    }
    
    // Crear lista temporal para mostrar (aplicando filtros si hay búsqueda)
    final displayOrganizations = _searchController.text.isEmpty && _selectedSize == null
        ? [..._organizationsToShow] // Usar la lista ya ordenada
        : _organizationsToShow;

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
                                const EdgeInsets.symmetric(horizontal: 10)),
                            leading: Icon(Icons.search,
                                color: theme.colorScheme.onSurfaceVariant),
                            trailing: [
                              if (_searchController.text != '')
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _organizationsToShow = [...organizationProvider.organizations];
                                      _applySorting();
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
                                  _organizationsToShow = [...organizationProvider.organizations];
                                  _applySorting();
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
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showFilterDialog,
                        icon: const Icon(Icons.filter_list_outlined, size: 30),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Mostrar información del ordenamiento activo
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _showFilterDialog,
                      child: Wrap(children: [
                        Text('Ordenado por: ', style: theme.textTheme.bodySmall),
                      Text(
                        _getSortFieldName(_sortField) + (_isAscending ? ' ↑' : ' ↓'),
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
            // Lista vacía
            if (displayOrganizations.isEmpty) 
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.business_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron organizaciones',
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            // Contenido principal
            if (displayOrganizations.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 1,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: displayOrganizations.length,
                  itemBuilder: (context, index) {
                    return OrganizationCard(
                      organization: displayOrganizations[index],
                      onTap: () => _handleOnTap(displayOrganizations[index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

}