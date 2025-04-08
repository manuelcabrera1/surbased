import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/widgets/gender_form_field_widget.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserForm extends StatefulWidget {
  final bool isCreate;
  const UserForm({super.key, this.isCreate = false});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _organizationController = TextEditingController();
  final _passwordController = TextEditingController();
  DateTime? _birthdate;
  String? _gender;
  String? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _organizationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final isRegistered = await authProvider.register(
            _nameController.text,
            _lastNameController.text,
            _selectedRole!,
            _organizationController.text,
            _emailController.text,
            _passwordController.text,
            DateFormat('yyyy-MM-dd').format(_birthdate!),
            _gender!.toLowerCase());

        if (isRegistered) {
          if (mounted) {
            widget.isCreate ? _navigateToLogin() : Navigator.popUntil(context, (route) => route.isFirst);
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
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.input_error_required;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final t = AppLocalizations.of(context)!;

    return Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText:
                              t.first_name,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: _fieldValidator,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText:
                              t.last_name,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: _fieldValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (widget.isCreate) ...[
                  DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: t.role,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "admin",
                      child: Text(t.admin),
                    ),
                    DropdownMenuItem(
                      value: "researcher",
                      child: Text(t.researcher),
                    ),
                    DropdownMenuItem(
                      value: "participant",
                      child: Text(t.participant),
                    ),

                  ],
                  validator: (value) {
                    if (value == null) {
                      return t.input_error_required;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRole = value;
                      });
                    }
                  },
                ),
                ],
                const SizedBox(height: 20),
                if (_selectedRole != "admin") ...[
                  TextFormField(
                    controller: _organizationController,
                    decoration: InputDecoration(
                      labelText:
                          t.organization,
                      prefixIcon: const Icon(Icons.business),
                    ),
                    validator: _fieldValidator,
                  ),
                  const SizedBox(height: 20),
                ],
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
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t.password,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: _fieldValidator,
                ),
                const SizedBox(height: 20),
                DateFormField(
                  context: context,
                  labelText: t.birthdate,
                  initialDate: _birthdate,
                  onChanged: (date) =>
                      setState(() => _birthdate = date),
                ),
                const SizedBox(height: 20),
                GenderFormField(
                  context: context,
                  labelText: t.gender,
                  initialGender: _gender,
                  onChanged: (gender) =>
                      setState(() => _gender = gender),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed:
                        authProvider.isLoading ? null : _handleSubmit,
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          )
                        : Text(widget.isCreate ? t.user_create : t.register)),
              ],
      ),
    );
  }
}
