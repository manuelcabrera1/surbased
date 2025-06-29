import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/widgets/survey_without_questions_card.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_add_edit_question_dialog.dart';
import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/survey_save_publish_dialog.dart';

class SurveyAddQuestionsPage extends StatefulWidget {
  final bool isEditing;
  const SurveyAddQuestionsPage({super.key, this.isEditing = false});

  @override
  State<SurveyAddQuestionsPage> createState() => _SurveyAddQuestionsPageState();
}

class _SurveyAddQuestionsPageState extends State<SurveyAddQuestionsPage> {
  void _removeQuestion(int index) {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    if (index >= 0 && index < surveyProvider.currentSurvey!.questions.length) {
      surveyProvider.removeQuestion(index);
    }
  }

  void _duplicateQuestion(int index) {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    final question = surveyProvider.currentSurvey!.questions[index];
    surveyProvider.insertQuestion(index + 1, question);
  }

  void _reorderQuestions(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        // Cuando se mueve hacia abajo, el índice se ajusta porque el elemento se elimina primero
        newIndex -= 1;
      }
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final Question item =
          surveyProvider.currentSurvey!.questions.removeAt(oldIndex);
      surveyProvider.currentSurvey!.questions.insert(newIndex, item);
    });
  }

  void _showAddEditQuestionDialog({Question? question, int? index = 0}) {
    if (question == null) {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => const SurveyAddEditQuestionDialog(),
      );
    } else {
      showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => SurveyAddEditQuestionDialog(
          question: question,
          isEdit: true,
          index: index,
        ),
      );
    }
  }

  void _showSaveSurveyDialog() {
    showDialog(
      context: context,
      builder: (context) => SurveySavePublishDialog(isEditing: widget.isEditing),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.survey_add_questions_page_title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSaveSurveyDialog(),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Lista de preguntas añadidas
          
              if (surveyProvider.isGeneratingQuestions) ...[
                Column(crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                const SizedBox(height: 70),
                const Align(alignment: Alignment.center, child: CircularProgressIndicator()),
                const SizedBox(height: 20),
                Text(t.survey_generating_questions, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface)),
                ]),
                ] else ...[
              if (surveyProvider.currentSurvey == null ||
                  surveyProvider.currentSurvey!.questions.isEmpty)
                const SurveyWithoutQuestionsCard()
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          t.survey_added_questions,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          t.drag_to_reorder,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: surveyProvider.currentSurvey!.questions.length,
                      onReorder: _reorderQuestions,
                      buildDefaultDragHandles:
                          false, // Desactivar los manejadores de arrastre predeterminados
                      itemBuilder: (context, index) {
                        return _buildDraggableQuestionCard(index);
                      },
                    ),
                    /*
                    ElevatedButton(onPressed: canContinue ? _handleContinue : null, 
                    child: canContinue 
                      ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white) 
                      : Text(AppLocalizations.of(context)!.go_forward)),
                    */
                  ],
                ),
                ],
            ],
          ),
        ),
        
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: '${widget.hashCode}',
        onPressed: () => _showAddEditQuestionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDraggableQuestionCard(int index) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final question = surveyProvider.currentSurvey!.questions[index];
    final t = AppLocalizations.of(context)!;

    return Card(
      key: ValueKey(index),
      margin: const EdgeInsets.only(bottom: 16.0),
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: ReorderableDragStartListener(
        index: index,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${index + 1}. ${question.description}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _showAddEditQuestionDialog(
                          question: question,
                          index: index,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.edit),
                            const SizedBox(width: 12),
                            Text(t.edit),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => _duplicateQuestion(index),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.content_copy),
                            const SizedBox(width: 12),
                            Text(t.duplicate),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => _removeQuestion(index),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.delete),
                            const SizedBox(width: 12),
                            Text(t.remove),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              //const SizedBox(height: 4),
              if (question.options != null && question.options!.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.options,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    ...question.options!.map((option) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                question.type == "multiple_choice"
                                    ? Icons.check_box_outline_blank
                                    : Icons.radio_button_unchecked,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      option.description!,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    if (question.type == "likert_scale" && option.points != null)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          "(valor: ${option.points})",
                                          style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ],
              // Añadir chip de Required en la esquina inferior derecha
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  question.required!
                      ? Chip(
                          label: Text(
                            t.required,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
