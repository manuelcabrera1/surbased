import 'package:flutter/material.dart';

class SurveyWithoutQuestionsCard extends StatelessWidget {
  const SurveyWithoutQuestionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.question_answer_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'There are no questions added',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Click \'+\' to add a question',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
