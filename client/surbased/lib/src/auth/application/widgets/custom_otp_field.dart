import 'package:flutter/material.dart';

class CustomOTPField extends StatefulWidget {
  final Function(String) onChanged;
  final bool isLastField;
  final bool isFirstField;

  const CustomOTPField({
    super.key,
    required this.onChanged,
    this.isLastField = false,
    this.isFirstField = false,
  });

  @override
  State<CustomOTPField> createState() => _CustomOTPFieldState();
}

class _CustomOTPFieldState extends State<CustomOTPField> {
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 50,
      height: 65,
      child: TextFormField(
        controller: _otpController,
        focusNode: _otpFocusNode,
        onChanged: (value) {
          widget.onChanged(value);
          // Si se está escribiendo un número y no es el último campo
          if (value.length == 1 && !widget.isLastField) {
            FocusScope.of(context).nextFocus();
          }
          // Si se está borrando y no es el primer campo
          if (value.isEmpty && !widget.isFirstField) {
            FocusScope.of(context).previousFocus();
          }
        },
        maxLength: 1,
        textAlign: TextAlign.center,
        autofocus: widget.isFirstField,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          counterText: '',                         
        ),
        style: theme.textTheme.headlineLarge,
      ),
    );
  }
}