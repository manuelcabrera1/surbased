import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormField extends FormField<DateTime> {
  DateFormField({
    super.key,
    DateTime? initialDate,
    required String labelText,
    String? Function(DateTime?)? validator,
    void Function(DateTime?)? onChanged,
  }) : super(
    initialValue: initialDate,
    validator: validator ?? (value) => value == null ? 'This field is required' : null,
    builder: (FormFieldState<DateTime> state) {
      final theme = Theme.of(state.context);
      return InkWell(
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: state.context,
            initialDate: state.value ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );

          if (selectedDate != null) {
            state.didChange(selectedDate);
            onChanged?.call(selectedDate);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: const Icon(Icons.calendar_month),
            errorText: state.errorText,
          ),
          child: Text(
            state.value == null 
              ? 'Select Date'
              : DateFormat('dd/MM/yyyy').format(state.value!),
              style : theme.textTheme.bodyLarge!.copyWith(color: const Color(0xFF757575)),
          ),
        ),
      );
    },
  );
}