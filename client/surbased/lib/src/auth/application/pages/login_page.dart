import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  void _navigateToRegister() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isLogged = await authProvider.login(
          _emailController.text,
          _passwordController.text,
        );

        if (isLogged && mounted) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final surveyProvider =
              Provider.of<SurveyProvider>(context, listen: false);
          final organizationProvider =
              Provider.of<OrganizationProvider>(context, listen: false);
          final categoryProvider =
              Provider.of<CategoryProvider>(context, listen: false);

          if (authProvider.isAuthenticated) {
            await surveyProvider.getSurveys(
              authProvider.userId!,
              authProvider.userRole!,
              authProvider.token!,
              null,
              null,
            );

            await categoryProvider.getCategories(null, authProvider.token!);

            if (authProvider.user!.organizationId != null) {
              await organizationProvider.getOrganizationById(
                authProvider.user!.organizationId!,
                authProvider.token!,
              );

              if (authProvider.user!.role == 'researcher') {
                await organizationProvider.getUsersInOrganization(
                  authProvider.token!,
                );
              }
            }

            if (authProvider.user!.role == 'admin') {
              await authProvider.getUsers(authProvider.token!, null, null);
            }
          }
          _navigateToHome();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 130),

                // Logo o Título
                Text(
                  AppLocalizations.of(context)!.app_title,
                  style: theme.textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 50),

                // Campo de email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? AppLocalizations.of(context)!.input_error_email
                      : null,
                ),

                const SizedBox(height: 16),

                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                  ),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty
                      ? AppLocalizations.of(context)!.input_error_password
                      : null,
                ),

                const SizedBox(height: 24),

                // Botón de login
                ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        )
                      : Text(AppLocalizations.of(context)!.log_in),
                ),

                const SizedBox(height: 16),

                // Link "Olvidé mi contraseña"
                TextButton(
                  onPressed: () {
                    // Implementar navegación a recuperación de contraseña
                  },
                  child: Text(AppLocalizations.of(context)!.forgot_password),
                ),

                const SizedBox(height: 24),

                // Link para registrarse
                TextButton(
                  onPressed:
                      authProvider.isLoading ? null : _navigateToRegister,
                  child: Text(AppLocalizations.of(context)!.dont_have_account),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
