import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/organization/application/provider/organization_provider.dart';
import 'package:surbased/src/organization/domain/organization_model.dart';

class OrganizationForm extends StatefulWidget {
  final bool isEditing;
  const OrganizationForm({super.key, this.isEditing = false});

  @override
  State<OrganizationForm> createState() => _OrganizationFormState();
}

class _OrganizationFormState extends State<OrganizationForm> {
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
          bool isSuccess = false;

          if (widget.isEditing) {
            isSuccess = await organizationProvider.updateOrganization(
                organizationProvider.selectedOrganization!.id.toString(), _nameController.text, authProvider.token!);
          } else {
            isSuccess = await organizationProvider.createOrganization(
                _nameController.text, authProvider.token!);
          }

          if (isSuccess) {
            if (mounted) {
              organizationProvider.getOrganizations(authProvider.token!);
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(organizationProvider.error!)),
              );
            }
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
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
      if (widget.isEditing) {
        _nameController.text = organizationProvider.selectedOrganization!.name;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final organizationProvider = Provider.of<OrganizationProvider>(context, listen: false);
    return Form(
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
                      : Text(widget.isEditing ? t.organization_edit : t.organization_create),
                ),
              ],
            ),
          );
  }
}