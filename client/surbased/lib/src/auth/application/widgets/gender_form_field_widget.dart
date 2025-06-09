import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GenderFormField extends FormField<String> {
  GenderFormField({
    super.key,
    required BuildContext context,
    String? initialGender,
    required String labelText,
    void Function(String?)? onChanged,
    bool required = true,
  }) : super(
          initialValue: initialGender,
          validator: (value) => value == null && required ? AppLocalizations.of(context)!.gender_select : null,
          builder: (FormFieldState<String> state) {
            final theme = Theme.of(state.context);
            final t = AppLocalizations.of(state.context)!;
            final genderOptions = {
              'male': t.gender_male,
              'female': t.gender_female,
              'other': t.gender_other,
            };

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
                    children: genderOptions.entries.map((gender) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: gender.key,
                            groupValue: state.value,
                            onChanged: (value) {
                              state.didChange(value);
                              onChanged?.call(value);
                            },
                          ),
                          Text(gender.value),
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
