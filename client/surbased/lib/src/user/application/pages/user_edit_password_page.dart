import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserEditPasswordPage extends StatefulWidget {
  const UserEditPasswordPage({super.key});

  @override
  State<UserEditPasswordPage> createState() => _UserEditPasswordPageState();
}

class _UserEditPasswordPageState extends State<UserEditPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isEditing = false;



  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final updatedUser = await authProvider.updateUserPassword(
            authProvider.user!.id,
            _passwordController.text,
            authProvider.token!);

        if (updatedUser) {
          setState(() => _isEditing = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.password_updated)),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(authProvider.error ?? AppLocalizations.of(context)!.password_update_error)),
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

  String? _confirmPasswordValidator(String? value) {
    _fieldValidator(value);
    if (value != _passwordController.text) {
      return AppLocalizations.of(context)!.password_dont_match;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.edit_password_page_title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            icon: _isEditing ? const Icon(Icons.save) : const Icon(Icons.edit),
            onPressed: _isEditing
                ? _handleSave
                : () => setState(() => _isEditing = true),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                  enabled: _isEditing,
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: _fieldValidator,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  enabled: _isEditing,
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password_confirm,
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  validator: _confirmPasswordValidator,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
