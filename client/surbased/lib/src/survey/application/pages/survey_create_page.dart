import 'package:flutter/material.dart';

class SurveyCreatePage extends StatefulWidget {
  const SurveyCreatePage({super.key});

  @override
  State<SurveyCreatePage> createState() => _SurveyCreatePageState();
}

class _SurveyCreatePageState extends State<SurveyCreatePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          title: const Text("Create survey"),
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onPrimary),
          )),
      body: const Text("Create survey"),
    );
  }
}
