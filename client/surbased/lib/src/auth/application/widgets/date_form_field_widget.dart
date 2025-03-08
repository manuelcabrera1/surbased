import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormField extends FormField<DateTime> {
  DateFormField({
    super.key,
    DateTime? initialDate,
    required String labelText,
    String? Function(DateTime?)? validator,
    void Function(DateTime?)? onChanged,
    bool enabled = true,
    bool required = true,
    bool canSelectAFutureDate = false,
  }) : super(
          initialValue: initialDate,
          validator: validator ??
              (value) =>
                  value == null && required ? 'This field is required' : null,
          builder: (FormFieldState<DateTime> state) {
            final theme = Theme.of(state.context);
            return InkWell(
              onTap: enabled
                  ? () async {
                      final selectedDate = await showDatePicker(
                        context: state.context,
                        initialDate: state.value ?? DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: canSelectAFutureDate
                            ? DateTime.now()
                                .add(const Duration(days: 365 * 100))
                            : DateTime.now(),
                      );

                      if (selectedDate != null) {
                        state.didChange(selectedDate);
                        onChanged?.call(selectedDate);
                      }
                    }
                  : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabled: enabled,
                  labelText: labelText,
                  prefixIcon: const Icon(Icons.calendar_month),
                  errorText: state.errorText,
                ),
                child: state.value == null
                    ? Text('Select Date',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant))
                    : Text(DateFormat('dd/MM/yyyy').format(state.value!),
                        style: theme.textTheme.bodyLarge!.copyWith(
                            color: !enabled
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.tertiary)),
              ),
            );
          },
        );
}
