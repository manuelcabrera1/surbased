import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';

class UserDeleteAccountPage extends StatefulWidget {
  const UserDeleteAccountPage({super.key});

  @override
  State<UserDeleteAccountPage> createState() => _UserDeleteAccountPageState();
}

class _UserDeleteAccountPageState extends State<UserDeleteAccountPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isConfirmed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_formKey.currentState!.validate() || !_isConfirmed) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isDeleted = await authProvider.deleteUser(authProvider.user!.id.toString(), _passwordController.text, authProvider.token!);
      if (mounted) {
        if (isDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.delete_account_success)),
          );
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.login,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.error!)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.delete_account_error),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.delete_account_page_title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.delete_account_question, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Descripción
              Text(
                t.delete_account_description,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              
              // Lista de datos
              Text(t.delete_account_data_surveys, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(t.delete_account_data_personal, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              Text(t.delete_account_data_settings, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 24),
              
              CheckboxListTile(
                value: _isConfirmed,
                onChanged: (value) {
                  setState(() => _isConfirmed = value ?? false);
                },
                title: Text(t.delete_account_confirm, style: theme.textTheme.bodyLarge),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 24),
              
              // Campo de contraseña
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: t.delete_account_password,
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.input_error_password;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Botón de eliminar
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isConfirmed && !_isLoading ? _deleteAccount : null,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(t.delete_account_button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
