import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/category/domain/category_model.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/user/application/provider/user_provider.dart';
import 'package:surbased/src/user/domain/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class UserDetailsPage extends StatefulWidget {
  final String userId;
  const UserDetailsPage({super.key, required this.userId});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  User? _user;
  String? _organizationName;
  List<Category> _userCategoriesOfInterest  = [];
  int _userSurveysCompleted = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadUserDetails();
      _loadUserData();
    });
  }

  void _loadUserDetails() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);

    if (authProvider.token != null && widget.userId != '') {
      try {
        final user = await userProvider.getUserById(widget.userId, authProvider.token!);
        if (user != null) {
          setState(() {
            _user = user;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(userProvider.error!)),
            );
          }
        }
        if (user != null && user.organizationId != null) {
          final organization = await organizationProvider.getOrganizationById(user.organizationId!, authProvider.token!);
          if (organization != null) {
            setState(() {
              _organizationName = organization.name;
            });
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
  }

  void _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      try {
        final surveys = await authProvider.getSurveysAssignedToUser(widget.userId, authProvider.token!);
        setState(() {
          _userSurveysCompleted = surveys.length;
          _userCategoriesOfInterest = surveys.map((survey) => categoryProvider.getCategoryById(survey.categoryId)).toList();
          _userCategoriesOfInterest = _userCategoriesOfInterest.toSet().toList();
        });

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  String _getGenderTranslation(String? gender) {
    final t = AppLocalizations.of(context)!;
    if (gender == null) return '-';
    
    switch (gender.toLowerCase()) {
      case 'male':
        return t.gender_male;
      case 'female':
        return t.gender_female;
      case 'other':
        return t.gender_other;
      default:
        return gender;
    }
  }

  String _getRoleTranslation(String role) {
    final t = AppLocalizations.of(context)!;
    switch (role.toLowerCase()) {
      case 'researcher':
        return t.researcher;
      case 'participant':
        return t.participant;
      default:
        return role;
    }
  }

  void _removeUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      if (authProvider.token != null && mounted) {
        final isDeleted = await authProvider.deleteUser(widget.userId, null, authProvider.token!, isCurrentUser: false);
        if (isDeleted && mounted) {
          userProvider.getUsers(authProvider.token!, null, null);
          Navigator.popUntil(context, (route) => route.isFirst);

        } else{ 
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.error!)),
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

  void _showRemoveUserDialog() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.user_remove),
        content: Text(t.user_remove_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.cancel),
          ),
          TextButton(
            onPressed: () => _removeUser(),
            child: Text(t.remove),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final t = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);

    if (userProvider.isLoading || organizationProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.profile_page_title),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }



    return Scaffold(
      appBar: AppBar(
        title: Text(t.profile_page_title),
        actions: [
            PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => {
                          Navigator.pushNamed(context, AppRoutes.userEdit, arguments: _user)
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
                        onTap: () => _showRemoveUserDialog(),
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
          ]),
      body: SafeArea(
        child: _user == null
            ? Center(
                child: Text(
                  t.user_not_found,
                  style: theme.textTheme.titleLarge,
                ),
              )
            : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // Encabezado con avatar y nombre
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 16),
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                _user!.name != null && _user!.name!.isNotEmpty
                                    ? _user!.name![0].toUpperCase()
                                    : _user!.email[0].toUpperCase(),
                                style: theme.textTheme.displayMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (_user!.name != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  '${_user!.name} ${_user!.lastname ?? ''}',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              _user!.email,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Chip(
                              label: Text(
                                _getRoleTranslation(_user!.role),
                                style: TextStyle(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: theme.colorScheme.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                    ),

                    
                    // Sección de información personal, actividad y categorías
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0), // Padding vertical para la tarjeta
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // --- Información Personal ---
                              _buildCardSubSectionTitle(context, t.user_details_personal_info),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Column(
                                  children: [
                                    _buildInfoRow(
                                      t.user_details_organization, 
                                      _organizationName ?? t.user_not_assigned,
                                      Icons.business,
                                      theme,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildInfoRow(
                                      t.user_details_gender,
                                      _getGenderTranslation(_user!.gender),
                                      Icons.person,
                                      theme,
                                    ),
                                    if (_user!.birthdate != null) ...[
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        t.user_details_birthdate,
                                        DateFormat('dd/MM/yyyy').format(_user!.birthdate!),
                                        Icons.cake,
                                        theme,
                                      ),
                                    ],
                                    if (_user!.age != null) ...[
                                      const SizedBox(height: 12),
                                      _buildInfoRow(
                                        t.user_details_age,
                                        '${_user!.age} ${t.user_details_years}',
                                        Icons.calendar_today,
                                        theme,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              
                              const Divider(height: 32, thickness: 0.5, indent: 16, endIndent: 16),
                              
                              // --- Actividad ---
                              _buildCardSubSectionTitle(context, t.user_details_activity),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: _buildStatRow(
                                  t.user_details_surveys_completed,
                                  '$_userSurveysCompleted',
                                  Icons.assignment,
                                  theme.colorScheme.primary,
                                  theme,
                                ),
                              ),

                              const Divider(height: 32, thickness: 0.5, indent: 16, endIndent: 16),

                              // --- Categorías de Interés ---
                              _buildCardSubSectionTitle(context, t.user_details_categories),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: _userCategoriesOfInterest.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          t.user_no_categories,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0, // Aumentado para mejor espaciado vertical
                                      children: _userCategoriesOfInterest.map((category) {
                                        return Chip(
                                          avatar: Icon(
                                            Icons.label,
                                            size: 18,
                                            color: theme.colorScheme.primary,
                                          ),
                                          label: Text(Category.getCategoryName(context, category.name)),
                                          backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                                          labelStyle: TextStyle(
                                            color: theme.colorScheme.onSecondaryContainer,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Ajustar padding del chip
                                        );
                                      }).toList(),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    
                  ],
                ),
              ),
        ),
      );
  }
  
  Widget _buildCardSubSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value, IconData icon, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatRow(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
 
}