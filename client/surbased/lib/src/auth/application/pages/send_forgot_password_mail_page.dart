import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/widgets/gender_form_field_widget.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SendForgotPasswordMailPage extends StatefulWidget {
  const SendForgotPasswordMailPage({super.key});

  @override
  State<SendForgotPasswordMailPage> createState() => _SendForgotPasswordMailPageState();
}

class _SendForgotPasswordMailPageState extends State<SendForgotPasswordMailPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();



  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }



  void _navigateToEnterResetCodePage() {
    Navigator.pushReplacementNamed(context, AppRoutes.enterResetCode, arguments: _emailController.text);
  }

  Future<void> _handleSendForgotPasswordMail() async {
    if (_formKey.currentState!.validate()) {
      final t = AppLocalizations.of(context)!;
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final isMailSent = await authProvider.sendForgotPasswordMail(_emailController.text);

        if (isMailSent) {
          _navigateToEnterResetCodePage();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t.email_sent)),
            );
          }

        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(authProvider.error!)),
            );
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

  String? _fieldValidator(String? value) {
    final t = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return t.input_error_required;
    }
    return null;
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
            child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          t.password_reset,
                          style: theme.textTheme.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 24), // Para compensar el espacio del icono y mantener el título centrado
                    ],
                  ),
                  const SizedBox(height: 40),
                  Form(
                        key: _formKey,
                        child: Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [   
                                Text(t.forgot_password_instructions,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      )),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    labelText: t.email,
                                    prefixIcon: const Icon(Icons.email),
                                  ),
                                  validator: _fieldValidator,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                    onPressed:
                                        authProvider.isLoading ? null : _handleSendForgotPasswordMail,
                                    child: authProvider.isLoading
                                        ? const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          )
                                        : Text(t.send_email)),
                                const SizedBox(height: 30),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, AppRoutes.login);
                                      },
                                      child: const Icon(Icons.arrow_back),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, AppRoutes.login);
                                      },
                                      child: Text(t.back_to_login),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ]),
        ),
      ),
    );
  }
}
