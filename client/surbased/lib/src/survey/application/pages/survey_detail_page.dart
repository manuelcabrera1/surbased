import 'package:flutter/material.dart';

class SurveyDetailPage extends StatefulWidget {
  const SurveyDetailPage({super.key});

  @override
  State<SurveyDetailPage> createState() => _SurveyDetailPageState();
}

class _SurveyDetailPageState extends State<SurveyDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Detail'),
      ),
    );
  }
}
