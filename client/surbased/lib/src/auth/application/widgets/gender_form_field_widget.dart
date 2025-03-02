import 'package:flutter/material.dart';

class GenderFormField extends FormField<String> {
  GenderFormField({
    super.key,
    String? initialGender,
    required String labelText,
    void Function(String?)? onChanged,
  }) : super(
          initialValue: initialGender,
          validator: (value) => value == null ? 'Please select a gender' : null,
          builder: (FormFieldState<String> state) {
            final theme = Theme.of(state.context);
            final genderOptions = ['Male', 'Female', 'Other'];

            return Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(labelText, style: theme.textTheme.bodyLarge),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 16,
                    runSpacing: 0,
                    children: genderOptions.map((gender) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: gender,
                            groupValue: state.value,
                            onChanged: (value) {
                              state.didChange(value);
                              onChanged?.call(value);
                            },
                          ),
                          Text(gender),
                        ],
                      );
                    }).toList(),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ),
                ],
              ),
            );
          },
        );
}
