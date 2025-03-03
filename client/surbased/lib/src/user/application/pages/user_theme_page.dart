import 'package:flutter/material.dart';

class UserThemePage extends StatefulWidget {
  const UserThemePage({super.key});

  @override
  State<UserThemePage> createState() => _UserThemePageState();
}

class _UserThemePageState extends State<UserThemePage> {
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
        body: const Center(child: Text('User Theme Page')));
  }
}
