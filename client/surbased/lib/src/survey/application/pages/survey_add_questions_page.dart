import 'package:flutter/material.dart';

class SurveyAddQuestionsPage extends StatefulWidget {
  const SurveyAddQuestionsPage({super.key});

  @override
  State<SurveyAddQuestionsPage> createState() => _SurveyAddQuestionsPageState();
}

class _SurveyAddQuestionsPageState extends State<SurveyAddQuestionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Questions'),
      ),
    );
  }
}
