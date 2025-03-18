import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:surbased/src/survey/domain/option_model.dart';
import 'package:surbased/src/survey/domain/question_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyAddEditQuestionDialog extends StatefulWidget {
  final Question? question;
  final bool isEdit;
  final int? index;
  const SurveyAddEditQuestionDialog(
      {super.key, this.question, this.isEdit = false, this.index});

  @override
  State<SurveyAddEditQuestionDialog> createState() =>
      _SurveyAddEditQuestionDialogState();
}

class _SurveyAddEditQuestionDialogState
    extends State<SurveyAddEditQuestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _options = <String>[];
  bool _isRequired = true;
  String _questionType = "";

  @override
  void initState() {
    super.initState();
    if (mounted &&
        widget.isEdit &&
        widget.question != null &&
        widget.question!.options != null) {
      _questionTextController.text = widget.question!.description!;
      _options.addAll(
          widget.question!.options!.map((option) => option.description!));
      _isRequired = widget.question!.required!;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _questionTextController.dispose();
  }

  void _addOption() {
    setState(() {
      _options.add('');
    });
  }

  void _updateOption(int index, String value) {
    setState(() {
      _options[index] = value;
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
    });
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.input_error_required;
    }
    return null;
  }

  void _addQuestion() {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    if (_formKey.currentState?.validate() ?? false) {
      bool success = surveyProvider.addQuestion(
        Question(
          surveyId: surveyProvider.currentSurvey!.id,
          description: _questionTextController.text,
          type: _questionType,
          required: _isRequired,
          options: List<Option>.from(_options.map((option) => Option(
                description: option,
              ))),
        ),
      );
      if (success) {
        if (mounted) {
          setState(() {
            // Limpiar el formulario
            _questionTextController.clear();
            _isRequired = true;
            _options.clear();
            _options.add('');
            Navigator.pop(context);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.question_add_error)),
          );
        }
      }
    }
  }

  void _updateQuestion() {
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    if (_formKey.currentState?.validate() ?? false) {
      bool success = surveyProvider.updateQuestion(
        widget.index!,
        Question(
          id: widget.question!.id,
          surveyId: widget.question!.surveyId,
          description: _questionTextController.text,
          type: _questionType,
          required: _isRequired,
          options: List<Option>.from(_options.map((option) => Option(
                questionId: widget.question!.id,
                description: option,
              ))),
        ),
      );
      if (success) {
        if (mounted) {
          setState(() {
            // Limpiar el formulario
            _questionTextController.clear();
            _isRequired = true;
            _options.clear();
            _options.add('');
            Navigator.pop(context);
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.question_update_error)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isEdit ? AppLocalizations.of(context)!.question_edit : AppLocalizations.of(context)!.question_new,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _questionTextController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.question_text,
                    border: const OutlineInputBorder(),
                  ),
                  validator: _fieldValidator,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: widget.isEdit ? widget.question!.type : null,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.question_type,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "single_choice",
                      child: Text(AppLocalizations.of(context)!.single_choice),
                    ),
                    DropdownMenuItem(
                      value: "multiple_choice",
                      child: Text(AppLocalizations.of(context)!.multiple_choice),
                    ),
                    DropdownMenuItem(
                      value: "likert_scale",
                      child: Text(AppLocalizations.of(context)!.likert_scale),
                    ),
                    DropdownMenuItem(
                      value: "open",
                      child: Text(AppLocalizations.of(context)!.open),
                    ),

                  ],
                  validator: (value) {
                    if (value == null) {
                      return AppLocalizations.of(context)!.input_error_required;
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _questionType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.required),
                  value: _isRequired,
                  onChanged: (value) {
                    setState(() {
                      _isRequired = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.options,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addOption,
                          icon: const Icon(Icons.add),
                          label: Text(AppLocalizations.of(context)!.add_option),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      _options.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _options[index],
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)!.option(index + 1),
                                  border: const OutlineInputBorder(),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                validator: _fieldValidator,
                                onChanged: (value) =>
                                    _updateOption(index, value),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => _removeOption(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: widget.isEdit ? _updateQuestion : _addQuestion,
                  label: Text(
                      widget.isEdit
                          ? AppLocalizations.of(context)!.question_update
                          : AppLocalizations.of(context)!.question_add),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
