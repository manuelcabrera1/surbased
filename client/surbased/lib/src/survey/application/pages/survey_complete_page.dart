import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import '../../domain/survey_model.dart';
import '../widgets/survey_question_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    if (authProvider.token != null) {
      bool success = await answerProvider.registerSurveyAnswers(
          widget.survey!.id!, authProvider.token!);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.survey_submitted),
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
    if (allRequiredQuestionsAreAnswered()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.survey_submit),
          content: Text(AppLocalizations.of(context)!.survey_submit_confirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => _submitSurvey(),
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        ),
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.survey_answer_required_questions),
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
          title: Text(AppLocalizations.of(context)!.go_back),
          content: Text(
              AppLocalizations.of(context)!.survey_return_confirmation),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                answerProvider.clearAllCurrentInfo();
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: Text(AppLocalizations.of(context)!.go_back),
            ),
          ],
        ),
      );
    } else {
      answerProvider.clearAllCurrentInfo();
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final answerProvider = Provider.of<AnswerProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.survey_complete),
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
                    : Text(AppLocalizations.of(context)!.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
