import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';

class SurveyListFilterDialog extends StatefulWidget {
  final String? currentSortField;
  final bool? isAscending;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;
  final bool? canFilterByOrganization;
  final bool? includeFinished;
  final Function(String sortField, bool ascending, DateTime? startDate, DateTime? endDate, bool includeFinished) onApplyFilter;

  const SurveyListFilterDialog({
    super.key,
    this.currentSortField,
    this.isAscending,
    this.startDateFilter,
    this.endDateFilter,
    this.canFilterByOrganization = false,
    this.includeFinished = false,
    required this.onApplyFilter,
  });

  @override
  State<SurveyListFilterDialog> createState() => _SurveyListFilterDialogState();
}

class _SurveyListFilterDialogState extends State<SurveyListFilterDialog> {
  late String _selectedSortField;
  late bool _isAscending;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showDateFilters = false;
  bool _includeFinished = false;

  @override
  void initState() {
    super.initState();
    _selectedSortField = widget.currentSortField ?? 'name';
    _isAscending = widget.isAscending ?? true;
    _startDate = widget.startDateFilter;
    _endDate = widget.endDateFilter;
    _showDateFilters = _startDate != null || _endDate != null;
    _includeFinished = widget.includeFinished ?? false;
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
            'startDate', 
            'Fecha de inicio', 
            _selectedSortField == 'startDate' ? _isAscending : null
          ),
          _buildSortOption(
            theme, 
            'endDate', 
            'Fecha de fin', 
            _selectedSortField == 'endDate' ? _isAscending : null
          ),
          if (widget.canFilterByOrganization == true)
            _buildSortOption(
              theme, 
              'organization', 
              'Organización', 
              _selectedSortField == 'organization' ? _isAscending : null
            ),
          _buildSortOption(
            theme, 
            'questions', 
            'Número de preguntas', 
            _selectedSortField == 'questions' ? _isAscending : null
          ),
          
          // Divisor y título de filtros por fecha
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
                      'Filtrar por fechas',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _showDateFilters,
                      onChanged: (value) {
                        setState(() {
                          _showDateFilters = value;
                          if (!value) {
                            _startDate = null;
                            _endDate = null;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Filtros de fecha (solo se muestran si _showDateFilters es true)
          if (_showDateFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  DateFormField(
                    labelText: 'Fecha de inicio',
                    context: context,
                    initialDate: _startDate,
                    canSelectAFutureDate: true,
                    required: false,
                    onChanged: (date) {
                      setState(() {
                        _startDate = date;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DateFormField(
                    labelText: 'Fecha de fin',
                    context: context,
                    initialDate: _endDate,
                    canSelectAFutureDate: true,
                    required: false,
                    onChanged: (date) {
                      setState(() {
                        _endDate = date;
                      });
                    },
                  ),
                ],
              ),
            ),
            
          // Filtro para incluir cuestionarios finalizados
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
                      'Incluir cuestionarios finalizados',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: _includeFinished,
                      onChanged: (value) {
                        setState(() {
                          _includeFinished = value;
                        });
                      },
                    ),
                  ],
                ),
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
                    _showDateFilters ? _startDate : null, 
                    _showDateFilters ? _endDate : null,
                    _includeFinished
                  );
                  Navigator.pop(context);
                },
                child: Text(t.apply, style: const TextStyle(fontSize: 16)),
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
  
  IconData _getSortIcon(String value) {
    switch (value) {
      case 'name':
        return Icons.sort_by_alpha;
      case 'startDate':
      case 'endDate':
        return Icons.calendar_today;
      case 'questions':
        return Icons.numbers;
      default:
        return Icons.sort;
    }
  }
}
