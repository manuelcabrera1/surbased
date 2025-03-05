import 'package:flutter/material.dart';

class UserSecurityPage extends StatefulWidget {
  const UserSecurityPage({super.key});

  @override
  State<UserSecurityPage> createState() => _UserSecurityPageState();
}

class _UserSecurityPageState extends State<UserSecurityPage> {
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
        body: const Center(child: Text('User Security Page')));
  }
}
