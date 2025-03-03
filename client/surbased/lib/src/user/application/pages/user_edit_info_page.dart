import 'package:flutter/material.dart';

class UserEditInfoPage extends StatefulWidget {
  const UserEditInfoPage({super.key});

  @override
  State<UserEditInfoPage> createState() => _UserEditInfoPageState();
}

class _UserEditInfoPageState extends State<UserEditInfoPage> {
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
        child: Text('User Edit Info Page'),
      ),
    );
  }
}
