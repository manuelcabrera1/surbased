import 'package:flutter/material.dart';

class SurveyCompletePage extends StatefulWidget {
  const SurveyCompletePage({super.key});

  @override
  State<SurveyCompletePage> createState() => _SurveyCompletePageState();
}

class _SurveyCompletePageState extends State<SurveyCompletePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete survey"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Text("Complete survey"),
    );
  }
}
