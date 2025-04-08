import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_form.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../category/application/provider/category_provider.dart';


class OrganizationCreatePage extends StatefulWidget {
  const OrganizationCreatePage({super.key});

  @override
  State<OrganizationCreatePage> createState() => OrganizationCreatePageState();
}

class OrganizationCreatePageState extends State<OrganizationCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.input_error_required;
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        if (authProvider.isAuthenticated) {
          final isRegistered = await organizationProvider.createOrganization(
              _nameController.text, authProvider.token!);

          if (isRegistered) {
            if (mounted) {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(organizationProvider.error!)),
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
    final organizationProvider = Provider.of<OrganizationProvider>(context);

    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          t.organization_create_page_title,
                          maxLines: 2,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: t.organization_create_page_title.length > 20 ? 25 : 30,
                          ),
                        ),
                      ],
                    ),
                  Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: t.organization_name,
                            border: const OutlineInputBorder(),
                          ),
                          validator: _fieldValidator,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: organizationProvider.isLoading ? null : _handleSubmit,
                          child: organizationProvider.isLoading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )
                              : Text(t.organization_create),
                        ),
                      ],
                    ),
                  ),
                )
                ],
              ),
          ),
      ),
    );
  }
}
