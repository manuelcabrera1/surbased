import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/organization/application/widgets/user_filter_dialog.dart';
import 'package:surbased/src/user/application/pages/user_details_page.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
import 'package:surbased/src/user/domain/user_model.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final SearchController _searchController = SearchController();
  List<User> _usersToShow = [];
  String _sortField = 'name';
  bool _isAscending = true;
  String? _selectedRole;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      final userProvider =
          Provider.of<UserProvider>(context, listen: false);

        setState(() {
          _usersToShow = userProvider.users;
        });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getTranslatedRole(String role) {
    final t = AppLocalizations.of(context)!;
    return role == 'researcher' ? t.researcher.toLowerCase() : role == 'admin' ? t.admin.toLowerCase() : t.participant.toLowerCase();
  }

  void filterUsers() {
    final userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final organizationProvider =
        Provider.of<OrganizationProvider>(context, listen: false);

    if (mounted) {
      
      setState(() {
        _usersToShow = userProvider.users
            .where((user) =>
                // Filtro de búsqueda por texto
                ((user.name != null && user.name!.toLowerCase().contains(_searchController.text.toLowerCase())) ||
                    (user.email
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                        ||
                        _getTranslatedRole(user.role)
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase())
                        ||
                        (user.organizationId != null &&
                        organizationProvider.getOrganizationName(user.organizationId!)
                        .toLowerCase()
                        .contains(_searchController.text.toLowerCase()))
                    )
                // Filtro por rol seleccionado
                && (_selectedRole == null || user.role == _selectedRole)
            )
            .toList();
            
        // Aplicar ordenamiento
        _applySorting();
      });
    }
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
      case 'organization':
        return t.user_list_sort_organization;
      default:
        return t.user_list_sort_name;
    }
  }

  
  void _applySorting() {
    _usersToShow.sort((a, b) {
      int result;
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
      
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
        case 'organization':
          final orgNameA = a.organizationId != null 
              ? organizationProvider.getOrganizationName(a.organizationId!)
              : '';
          final orgNameB = b.organizationId != null 
              ? organizationProvider.getOrganizationName(b.organizationId!)
              : '';
          result = orgNameA.compareTo(orgNameB);
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
      ),
    );
  }

  String _getUserInitial(User user) {
    if (user.name != null && user.name!.isNotEmpty) {
      return user.name![0].toUpperCase();
    } else {
      return user.email[0].toUpperCase();
    }
  }

  String _getUserDisplayName(User user) {
    if (user.name != null && user.name!.isNotEmpty) {
      return user.name!;
    } else {
      return user.email.split('@')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final t = AppLocalizations.of(context)!;

    if (authProvider.isLoading || organizationProvider.isLoading || userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Aplicar ordenamiento por defecto la primera vez
    if (_usersToShow.isNotEmpty) {
      _applySorting();
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  t.users_page_title,
                  style: theme.textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 20),
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
                                      _usersToShow = userProvider.users;
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
                                  _usersToShow = userProvider.users;
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
                      if (_usersToShow.isEmpty) ...[
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
                                    t.users_error_no_users,
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
                    padding: const EdgeInsets.only(top: 8, left: 7),
                    itemCount: _usersToShow.length,
                    itemBuilder: (context, index) {
                      final user = _usersToShow[index];
                      final orgName = user.organizationId != null
                          ? organizationProvider.getOrganizationName(user.organizationId!)
                          : null;
                          
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.userDetails, 
                              arguments: user.id);
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
                                user.role == 'researcher'
                                    ? t.researcher
                                    : user.role == 'admin'
                                        ? t.admin
                                        : t.participant,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            _getUserInitial(user),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          _getUserDisplayName(user),
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.email, 
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: user.email.length > 20 ? 12 : 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (orgName != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 16,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      orgName,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                                ),
                  ),
                ]
              ],
        ),
      ),
    );
  }
}
