import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import '../../domain/survey_model.dart';
import '../widgets/survey_question_card.dart';

class SurveyCompletePage extends StatefulWidget {
  final Survey? survey;
  const SurveyCompletePage({super.key, this.survey});

  @override
  State<SurveyCompletePage> createState() => _SurveyCompletePageState();
}

class _SurveyCompletePageState extends State<SurveyCompletePage> {
  final _formKey = GlobalKey<FormState>();

  bool allRequiredQuestionsAreAnswered() {
    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
    final questions = answerProvider.currentSurveyBeingAnswered!.questions;

    bool isRequired;
    bool result = true;

    for (var question in questions) {
      isRequired = widget.survey!.questions
          .firstWhere((q) => q.id == question.id)
          .required!;
      if (isRequired && question.options == null || question.options!.isEmpty) {
        answerProvider.addQuestionToBeAnswered(question.id!);
        result = false;
      }
    }
    return result;
  }

  void _submitSurvey() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
    if (authProvider.token != null) {
      bool success = await answerProvider.registerSurveyAnswers(
          widget.survey!.id!, authProvider.token!);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Survey submitted successfully'),
            ),
          );
          Navigator.pushNamed(context, AppRoutes.home);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(answerProvider.error!)),
          );
        }
      }
    }
  }

  void _showSubmitSurveyConfirmationDialog() {
    if (allRequiredQuestionsAreAnswered()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Submit Survey'),
          content: const Text('Are you sure you want to submit this survey?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => _submitSurvey(),
              child: const Text('Submit'),
            ),
          ],
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please answer all required questions'),
          ),
        );
      }
    }
  }

  void _showGoBackConfirmationDialog() {
    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);

    if (answerProvider.currentSurveyBeingAnswered!.questions
        .any((q) => q.options!.isNotEmpty)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Return'),
          content: const Text(
              'Are you sure you want to return to the survey list?\nYour progress will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                answerProvider.clearAllCurrentInfo();
                Navigator.pushNamed(context, AppRoutes.home);
              },
              child: const Text('Return'),
            ),
          ],
        ),
      );
    } else {
      answerProvider.clearAllCurrentInfo();
      Navigator.pushNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final answerProvider = Provider.of<AnswerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete survey"),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: answerProvider.isLoading
                ? null
                : _showGoBackConfirmationDialog),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: widget.survey!.questions.length,
                itemBuilder: (context, index) {
                  return SurveyQuestionCard(
                    question: widget.survey!.questions[index],
                  );
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: answerProvider.isLoading
                    ? null
                    : _showSubmitSurveyConfirmationDialog,
                child: answerProvider.isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
