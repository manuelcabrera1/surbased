import 'package:flutter/material.dart';

class UserEditPasswordPage extends StatefulWidget {
  const UserEditPasswordPage({super.key});

  @override
  State<UserEditPasswordPage> createState() => _UserEditPasswordPageState();
}

class _UserEditPasswordPageState extends State<UserEditPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Info'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: const Center(
        child: Text('User Edit Password Page'),
      ),
    );
  }
}
