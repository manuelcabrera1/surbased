import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/organization/application/widgets/user_filter_dialog.dart';
import 'package:surbased/src/user/application/pages/user_details_page.dart';
import 'package:surbased/src/user/domain/user_model.dart';

class OrganizationUsers extends StatefulWidget {
  const OrganizationUsers({super.key});

  @override
  State<OrganizationUsers> createState() => _OrganizationUsersState();
}

class _OrganizationUsersState extends State<OrganizationUsers> {
  final SearchController _searchController = SearchController();
  List<User> _usersToShow = [];
  String _sortField = 'name';
  bool _isAscending = true;
  String? _selectedRole;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      final organizationProvider =
          Provider.of<OrganizationProvider>(context, listen: false);
      if (organizationProvider.organization?.users != null) {
        setState(() {
          _usersToShow = organizationProvider.organization!.users!;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterUsers() {
    final organizationProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (mounted &&
        organizationProvider.organization != null &&
        organizationProvider.organization!.users != null) {
      setState(() {
        _usersToShow = organizationProvider.organization!.users!
            .where((user) =>
                // Filtro por texto
                (user.name?.toLowerCase().contains(_searchController.text.toLowerCase()) ??
                false ||
                    user.email
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                // Filtro por rol
                && (_selectedRole == null || user.role == _selectedRole)
            )
            .toList();
            
        // Aplicar ordenamiento
        _applySorting();
      });
    }
  }
  
  void _applySorting() {
    _usersToShow.sort((a, b) {
      int result;
      
      switch (_sortField) {
        case 'name':
          result = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'email':
          result = a.email.compareTo(b.email);
          break;
        case 'role':
          result = a.role.compareTo(b.role);
          break;
        default:
          result = (a.name ?? '').compareTo(b.name ?? '');
      }
      
      return _isAscending ? result : -result;
    });
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
      builder: (context) => UserFilterDialog(
        currentSortField: _sortField,
        isAscending: _isAscending,
        selectedRole: _selectedRole,
        onApplyFilter: (sortField, isAscending, role) {
          setState(() {
            _sortField = sortField;
            _isAscending = isAscending;
            _selectedRole = role;
            filterUsers();
          });
        },
        areFromSameOrganization: true,
      ),
    );
  }

  String _getSortFieldName(String field) {
    final t = AppLocalizations.of(context)!;
    switch (field) {
      case 'name':
        return t.user_list_sort_name;
      case 'email':
        return t.user_list_sort_email;
      case 'role':
        return t.user_list_sort_role;
      default:
        return t.user_list_sort_name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final t = AppLocalizations.of(context)!;

    if (authProvider.isLoading || organizationProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Aplicar ordenamiento por defecto la primera vez
    if (_usersToShow.isNotEmpty) {
      _applySorting();
    }

    return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 10),
              child: Row(
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
                                  _usersToShow =
                                      organizationProvider.organization!.users!;
                                });
                              },
                              icon: const Icon(Icons.close),
                            )
                        ],
                        onChanged: (value) {

                          if (_searchController.text != '') {
                            filterUsers();
                          } else {
                            setState(() {
                              _usersToShow =
                                  organizationProvider.organization!.users!;
                            });
                          }
                        },
                        onSubmitted: (value) {

                          filterUsers();
                        },
                        hintText: t.users_searchbar_placeholder,
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
            if (_usersToShow.isEmpty)
              Container(
                        height: MediaQuery.of(context).size.height * 0.5,
                        alignment: Alignment.center,
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
                                    t.users_error_no_users,
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
            else
              Expanded(
                child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, left: 7),
                itemCount: _usersToShow.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.userDetails, arguments: _usersToShow[index].id);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _usersToShow[index].role == 'researcher'
                                ? t.researcher
                                : t.participant,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        _usersToShow[index].name?.substring(0, 1) ?? '',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(_usersToShow[index].name ?? ''),
                    subtitle: Text(_usersToShow[index].email),
                  );
                },
                            ),
              ),
          ],
    );
  }
}
