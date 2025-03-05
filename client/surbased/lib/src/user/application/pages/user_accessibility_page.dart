import 'package:flutter/material.dart';

class UserAccessibilityPage extends StatelessWidget {
  const UserAccessibilityPage({super.key});

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
        body: const Center(child: Text('User Accessibility Page')));
  }
}
