import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import '../widgets/survey_question_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SurveyCompletePage extends StatefulWidget {
  const SurveyCompletePage({super.key});

  @override
  State<SurveyCompletePage> createState() => _SurveyCompletePageState();
}

class _SurveyCompletePageState extends State<SurveyCompletePage> {
  final _formKey = GlobalKey<FormState>();

  bool allRequiredQuestionsAreAnswered() {
    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final questions = answerProvider.currentSurveyBeingAnswered!.questions;

    bool isRequired;
    bool result = true;

    for (var question in questions) {
      isRequired = surveyProvider.currentSurvey!.questions
          .firstWhere((q) => q.id == question.id)
          .required!;
      if (isRequired && question.options == null || question.options!.isEmpty && question.text == null) {
        answerProvider.addQuestionToBeAnswered(question.id!);
        result = false;
      }
    }
    return result;
  }

  void _submitSurvey() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;
    if (authProvider.token != null) {
      bool success = await answerProvider.registerSurveyAnswers(
          surveyProvider.currentSurvey!.id!, authProvider.token!);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.survey_submitted),
            ),
          );
          Navigator.pushReplacementNamed(context, AppRoutes.home);
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
    final t = AppLocalizations.of(context)!;
    if (allRequiredQuestionsAreAnswered()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.survey_submit),
          content: Text(t.survey_submit_confirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.cancel),
            ),
            TextButton(
              onPressed: () => _submitSurvey(),
              child: Text(t.submit),
            ),
          ],
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.survey_answer_required_questions),
          ),
        );
      }
    }
  }

  void _showGoBackConfirmationDialog() {
    final answerProvider = Provider.of<AnswerProvider>(context, listen: false);
    final t = AppLocalizations.of(context)!;

    if ( answerProvider.currentSurveyBeingAnswered != null && answerProvider.currentSurveyBeingAnswered!.questions
        .any((q) => q.options!.isNotEmpty)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.go_back),
          content: Text(
              t.survey_return_confirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.cancel),
            ),
            TextButton(
              onPressed: () {
                answerProvider.clearAllCurrentInfo();
                Navigator.pop(context);
              },
              child: Text(t.go_back),
            ),
          ],
        ),
      );
    } else {
      answerProvider.clearAllCurrentInfo();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final answerProvider = Provider.of<AnswerProvider>(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final t = AppLocalizations.of(context)!;

    if (answerProvider.isLoading || surveyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.survey_complete),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: answerProvider.isLoading
                ? null
                : _showGoBackConfirmationDialog),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: surveyProvider.currentSurvey!.questions.length,
                  itemBuilder: (context, index) {
                    return SurveyQuestionCard(
                      question: surveyProvider.currentSurvey!.questions[index],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: answerProvider.isLoading
                    ? null
                    : _showSubmitSurveyConfirmationDialog,
                child: answerProvider.isLoading
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : Text(t.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
