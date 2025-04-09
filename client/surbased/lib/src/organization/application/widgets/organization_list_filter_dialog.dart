import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrganizationListFilterDialog extends StatefulWidget {
  final String? currentSortField;
  final bool? isAscending;
  final String? selectedSize;
  final Function(String sortField, bool ascending, String? size) onApplyFilter;

  const OrganizationListFilterDialog({
    super.key,
    this.currentSortField,
    this.isAscending,
    this.selectedSize,
    required this.onApplyFilter,
  });

  @override
  State<OrganizationListFilterDialog> createState() => _OrganizationListFilterDialogState();
}

class _OrganizationListFilterDialogState extends State<OrganizationListFilterDialog> {
  late String _selectedSortField;
  late bool _isAscending;
  String? _selectedSize;
  bool _showSizeFilter = false;

  @override
  void initState() {
    super.initState();
    _selectedSortField = widget.currentSortField ?? 'name';
    _isAscending = widget.isAscending ?? true;
    _selectedSize = widget.selectedSize;
    _showSizeFilter = _selectedSize != null;
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
          'size', 
          'Tamaño (usuarios)', 
          _selectedSortField == 'size' ? _isAscending : null
        ),
        _buildSortOption(
          theme, 
          'surveys', 
          'Número de encuestas', 
          _selectedSortField == 'surveys' ? _isAscending : null
        ),
        
        // Divisor y título de filtros por tamaño
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
                    'Filtrar por tamaño',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: _showSizeFilter,
                    onChanged: (value) {
                      setState(() {
                        _showSizeFilter = value;
                        if (!value) {
                          _selectedSize = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Filtros de tamaño (solo se muestran si _showSizeFilter es true)
        if (_showSizeFilter)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSizeOption(theme, 'small', 'Pequeña (<10 usuarios)'),
                _buildSizeOption(theme, 'medium', 'Mediana (10-50 usuarios)'),
                _buildSizeOption(theme, 'large', 'Grande (>50 usuarios)'),
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
                  _showSizeFilter ? _selectedSize : null
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

  Widget _buildSizeOption(ThemeData theme, String value, String label) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSize = value;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedSize,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSize = newValue;
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: _selectedSize == value ? FontWeight.bold : FontWeight.normal,
                color: _selectedSize == value ? theme.colorScheme.primary : null,
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
      case 'creationDate':
        return Icons.calendar_today;
      case 'size':
        return Icons.people;
      case 'surveys':
        return Icons.assignment;
      default:
        return Icons.sort;
    }
  }
}
