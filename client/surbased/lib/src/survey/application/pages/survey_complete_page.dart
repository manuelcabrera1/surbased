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
    if (allRequiredQuestionsAreAnswered() && authProvider.token != null) {
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
              : () {
                  answerProvider.clearQuestionsToBeAnswered();
                  Navigator.of(context).pop();
                },
        ),
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
                onPressed: answerProvider.isLoading ? null : _submitSurvey,
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
