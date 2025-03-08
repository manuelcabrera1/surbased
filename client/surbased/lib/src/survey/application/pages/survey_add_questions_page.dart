import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/pages/survey_without_questions_card.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/application/widgets/survey_add_edit_question_dialog.dart';
import 'package:surbased/src/survey/domain/question_model.dart';

class SurveyAddQuestionsPage extends StatefulWidget {
  const SurveyAddQuestionsPage({super.key});

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
      builder: (context) => AlertDialog(
        title: const Text('Save Survey'),
        content: const Text('Are you sure you want to save this survey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _createSurvey(),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _createSurvey() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    try {
      bool success = await surveyProvider.createSurvey(
        authProvider.token!,
      );
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Survey saved successfully')),
          );
          Navigator.pushNamed(context, AppRoutes.home);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(surveyProvider.error!)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surveyProvider = Provider.of<SurveyProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Lista de preguntas añadidas
            if (surveyProvider.currentSurvey == null ||
                surveyProvider.currentSurvey!.questions.isEmpty)
              const SurveyWithoutQuestionsCard()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Added Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        '(Drag to reorder)',
                        style: TextStyle(
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
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditQuestionDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDraggableQuestionCard(int index) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final question = surveyProvider.currentSurvey!.questions[index];

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
                  Text(
                    '${index + 1}. ${question.description}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _duplicateQuestion(index),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.content_copy),
                            SizedBox(width: 12),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => _showAddEditQuestionDialog(
                          question: question,
                          index: index,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 12),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => _removeQuestion(index),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 12),
                            Text('Remove'),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 4),
              if (question.options.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Opciones:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    ...question.options.map((option) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              Icon(
                                !question.multipleAnswer
                                    ? Icons.radio_button_unchecked
                                    : Icons.check_box_outline_blank,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(option.description),
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
                  question.required
                      ? Chip(
                          label: const Text(
                            'Required',
                            style: TextStyle(
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
