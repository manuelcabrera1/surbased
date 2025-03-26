import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/survey/application/provider/answer_provider.dart';
import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyQuestionCard extends StatefulWidget {
  final Question question;
  const SurveyQuestionCard({
    super.key,
    required this.question,
  });

  @override
  State<SurveyQuestionCard> createState() => _SurveyQuestionCardState();
}

class _SurveyQuestionCardState extends State<SurveyQuestionCard> {
  List<String> selectedMultipleOptions = [];
  String? selectedSingleOption;
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final question = widget.question;
    final theme = Theme.of(context);
    final answerProvider = Provider.of<AnswerProvider>(context);

    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${question.number}. ${question.description} ${question.required! ? '*' : ''}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: question.required! &&
                        answerProvider.questionsToBeAnswered
                            .contains(question.id)
                    ? theme.colorScheme.error.withOpacity(0.8)
                    : theme.colorScheme.tertiary,
              ),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (question.type != "open" && question.options != null && question.options!.isNotEmpty) ...[
              ...question.options!.map((option) => Padding(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      question.type == "multiple_choice"
                          ? Checkbox(
                              value:
                                  selectedMultipleOptions.contains(option.id),
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedMultipleOptions.add(option.id!);
                                    answerProvider.addOptionToQuestion(
                                        question, option);
                                  } else {
                                    selectedMultipleOptions.remove(option.id);
                                    answerProvider.removeOptionFromQuestion(
                                        question, option);
                                  }
                                });
                              },
                            )
                          : Radio(
                              value: option.id,
                              groupValue: selectedSingleOption,
                              onChanged: (value) {
                                setState(() {
                                  selectedSingleOption = value;
                                  answerProvider.changeOptionToQuestion(
                                      question, option);
                                });
                              },
                            ),
                      Text(
                        option.description ?? AppLocalizations.of(context)!.none,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ))),
            ],
            if (question.type == "open") ...[
              TextField(
                controller: textController,
                minLines: 1,
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    answerProvider.setTextToQuestion(question, value);
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
