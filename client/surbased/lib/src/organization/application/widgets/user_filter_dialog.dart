import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';

class UserFilterDialog extends StatefulWidget {
  final String? currentSortField;
  final bool? isAscending;
  final String? selectedRole;
  final bool? areFromSameOrganization;
  final Function(String sortField, bool ascending, String? role) onApplyFilter;

  const UserFilterDialog({
    super.key,
    this.currentSortField,
    this.isAscending,
    this.selectedRole,
    required this.onApplyFilter,
    this.areFromSameOrganization = false,
  });

  @override
  State<UserFilterDialog> createState() => _UserFilterDialogState();
}

class _UserFilterDialogState extends State<UserFilterDialog> {
  late String _selectedSortField;
  late bool _isAscending;
  String? _selectedRole;
  bool _showRoleFilter = false;

  @override
  void initState() {
    super.initState();
    _selectedSortField = widget.currentSortField ?? 'name';
    _isAscending = widget.isAscending ?? true;
    _selectedRole = widget.selectedRole;
    _showRoleFilter = _selectedRole != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = AppLocalizations.of(context)!;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Text(
                t.sort_by,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildSortOption(
          theme, 
          'name', 
          'Nombre', 
          _selectedSortField == 'name' ? _isAscending : null
        ),
        _buildSortOption(
          theme, 
          'email', 
          'Email', 
          _selectedSortField == 'email' ? _isAscending : null
        ),
        _buildSortOption(
          theme, 
          'role', 
          'Rol', 
          _selectedSortField == 'role' ? _isAscending : null
        ),
        if (widget.areFromSameOrganization != true)
          _buildSortOption(
            theme, 
            'organization', 
            'Organización', 
            _selectedSortField == 'organization' ? _isAscending : null
          ),
       
        // Divisor y título de filtros por rol
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(thickness: 0.5),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filtrar por rol',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _showRoleFilter,
                    onChanged: (value) {
                      setState(() {
                        _showRoleFilter = value;
                        if (!value) {
                          _selectedRole = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Filtros de rol (solo se muestran si _showRoleFilter es true)
        if (_showRoleFilter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildRoleOption(theme, 'researcher', 'Investigador'),
                _buildRoleOption(theme, 'participant', 'Participante'),
                if (widget.areFromSameOrganization != true)
                  _buildRoleOption(theme, 'admin', 'Administrador'),
              ],
            ),
          ),
          
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () {
                widget.onApplyFilter(
                  _selectedSortField, 
                  _isAscending, 
                  _showRoleFilter ? _selectedRole : null
                );
                Navigator.pop(context);
              },
              child: const Text('Aplicar', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortOption(ThemeData theme, String value, String label, bool? isAscending) {
    final bool isSelected = _selectedSortField == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedSortField == value) {
            // Si ya está seleccionado, cambia la dirección
            _isAscending = !_isAscending;
          } else {
            // Si seleccionamos una nueva opción, mantén la dirección actual
            _selectedSortField = value;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Icon(
              _getSortIcon(value),
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: theme.colorScheme.primary,
              )
            else if (isAscending != null)
              Text(
                isAscending ? 'Ascendente' : 'Descendente',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(ThemeData theme, String value, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedRole,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: _selectedRole == value ? FontWeight.bold : FontWeight.normal,
                color: _selectedRole == value ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getSortIcon(String value) {
    switch (value) {
      case 'name':
        return Icons.sort_by_alpha;
      case 'email':
        return Icons.email;
      case 'role':
        return Icons.person;
      case 'organization':
        return Icons.business;
      default:
        return Icons.sort;
    }
  }
}
