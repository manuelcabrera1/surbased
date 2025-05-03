import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserEditInfoPage extends StatefulWidget {
  const UserEditInfoPage({super.key});

  @override
  State<UserEditInfoPage> createState() => _UserEditInfoPageState();
}

class _UserEditInfoPageState extends State<UserEditInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  DateTime? _birthdate;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    _nameController.text = user?.name ?? '';
    _lastNameController.text = user?.lastname ?? '';
    _emailController.text = user?.email ?? '';
    _birthdate = user?.birthdate;
  }

  @override
  void dispose() {
    super.dispose();
    _formKey.currentState?.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.input_error_required;
    }
    return null;
  }

  Future<void> _handleSave() async {
    final t = AppLocalizations.of(context);
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        final updatedUser = await authProvider.updateUser(
            authProvider.user!.id,
            authProvider.token!,
            name: _nameController.text,
            lastname: _lastNameController.text,
            email: _emailController.text,
            birthdate: DateFormat('yyyy-MM-dd').format(_birthdate!));
        if (updatedUser) {
          setState(() => _isEditing = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(t!.profile_updated)),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(authProvider.error ?? t!.profile_update_error)),
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
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.edit_profile_page_title),
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        enabled: _isEditing,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: t.first_name,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: _fieldValidator,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        enabled: _isEditing,
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: t.last_name,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: _fieldValidator,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextFormField(
                  enabled: _isEditing,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: t.email,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  validator: _fieldValidator,
                ),
                const SizedBox(height: 20),
                DateFormField(
                  context: context,
                  enabled: _isEditing,
                  labelText: t.birthdate,
                  initialDate: _birthdate,
                  onChanged: (date) => setState(() => _birthdate = date),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
