import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/auth/infrastructure/auth_provider.dart';
import 'package:surbased/src/user/infrastructure/user_provider.dart';

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
      return 'This field is required';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        final updatedUser = await userProvider.updateUser(
            authProvider.user!.id,
            _nameController.text,
            _lastNameController.text,
            _emailController.text,
            DateFormat('yyyy-MM-dd').format(_birthdate!),
            authProvider.token!);
        if (updatedUser != null) {
          authProvider.refreshUser(updatedUser);
          setState(() => _isEditing = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(userProvider.error!)),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: _fieldValidator,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        enabled: _isEditing,
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Icon(Icons.person_outline),
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
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: _fieldValidator,
                ),
                const SizedBox(height: 20),
                DateFormField(
                  enabled: _isEditing,
                  labelText: 'Birthdate',
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
