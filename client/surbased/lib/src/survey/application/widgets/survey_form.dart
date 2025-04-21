import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:surbased/src/survey/application/provider/tags_provider.dart';

import '../../../category/application/provider/category_provider.dart';

class SurveyForm extends StatefulWidget {
  final bool isGeneratingWithAI;
  final bool isEditing;
  const SurveyForm({super.key, this.isGeneratingWithAI = false, this.isEditing = false});

  @override
  State<SurveyForm> createState() => SurveyFormState();

}

class SurveyFormState extends State<SurveyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(text: '');
  final TextEditingController _numberOfQuestionsController =
      TextEditingController(text: '');
  final TextEditingController _localeController =
      TextEditingController(text: '');
  final TextEditingController _tagController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _categoryId;
  final List<String> _selectedTags = [];
  List<String> _availableTags = [];

  // Lista de colores para las tags
  static const List<Color> _tagColors = [
    Color(0xFFE8F5E9), // green.shade50
    Color(0xFFFFF3E0), // orange.shade50
    Color(0xFFF3E5F5), // purple.shade50
    Color(0xFFE3F2FD), // blue.shade50
    Color(0xFFFFEBEE), // red.shade50
    Color(0xFFE0F2F1), // teal.shade50
    Color(0xFFFCE4EC), // pink.shade50
    Color(0xFFE8EAF6), // indigo.shade50
  ];

  @override
  void initState() {
    super.initState();
    final surveyProvider = Provider.of<SurveyProvider>(context, listen: false);
    if (surveyProvider.currentSurvey != null) {
      _nameController.text = surveyProvider.currentSurvey!.name;
      _descriptionController.text = surveyProvider.currentSurvey!.description ?? '';
      _categoryId = surveyProvider.currentSurvey!.categoryId;
      _startDate = surveyProvider.currentSurvey!.startDate;
      _endDate = surveyProvider.currentSurvey!.endDate;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final tagsProvider = Provider.of<TagsProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated && !tagsProvider.isLoading && tagsProvider.tags.isNotEmpty) {
        setState(() {
        _availableTags = tagsProvider.tags.map((tag) => tag.name).toList();
      });
      }
      
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    _selectedTags.clear();
    _availableTags.clear();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.input_error_required;
    }
    return null;
  }

  String? _fieldNumberValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.input_error_required;
    }

    if (int.tryParse(value) == null) {
      return AppLocalizations.of(context)!.survey_form_number_error;
    }

    if (int.parse(value) < 1) {
      return AppLocalizations.of(context)!.survey_form_number_positive;
    }

    return null;
  }

  String? _endDateValidator(DateTime? value) {
    if (value != null && _startDate != null && value.isBefore(_startDate!) && !widget.isEditing) {
      return AppLocalizations.of(context)!.start_end_date_error;
    }
    return null;
  }

  Widget _buildTagChip(String text, VoidCallback onDeleted) {
    final theme = Theme.of(context);
    final index = _selectedTags.indexOf(text);
    final color = _tagColors[index % _tagColors.length];
    
    return Padding(
      padding: const EdgeInsets.only(right: 2, bottom: 4),
      child: Chip(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        label: Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.computeLuminance() > 0.5 
                ? Colors.black87 
                : Colors.white,
            fontSize: 11,
          ),
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        onDeleted: onDeleted,
        deleteIconColor: color.computeLuminance() > 0.5 
            ? Colors.black54 
            : Colors.white70,
      ),
    );
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

      bool success = surveyProvider.addOrUpdateSurveyInfo(
        _nameController.text,
        _descriptionController.text,
        _startDate ?? DateTime.now(),
        _endDate ?? DateTime.now().add(const Duration(days: 7)),
        _categoryId!,
        authProvider.user!.id,
        _selectedTags
      );
      if (success) {
        if (widget.isGeneratingWithAI) {
          
          surveyProvider.generateQuestionsWithAI(
            _categoryId!,
            authProvider.user!.id,
            _nameController.text,
            categoryProvider.getCategoryById(_categoryId!).name,
            _selectedTags,
            _descriptionController.text,
            _localeController.text,
            _numberOfQuestionsController.text,
            _startDate ?? DateTime.now(),
            _endDate ?? DateTime.now().add(const Duration(days: 7)),
          ); 
        }
        Navigator.pushNamed(context, AppRoutes.surveyAddQuestions, arguments: widget.isEditing);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(surveyProvider.error!)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final tagsProvider = Provider.of<TagsProvider>(context);
    final t = AppLocalizations.of(context)!;

    if (tagsProvider.isLoading || categoryProvider.isLoading || surveyProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.text,
              controller: _nameController,
              decoration: InputDecoration(
                labelText: t.survey_name,
                border: const OutlineInputBorder(),
              ),
              validator: widget.isGeneratingWithAI ? null : _fieldValidator,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: t.category,
                border: const OutlineInputBorder(),
              ),
              value: _categoryId,
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name, style: TextStyle(fontWeight: FontWeight.normal, color: theme.colorScheme.tertiary)),
                      ))
                  .toList(),
              onChanged: (categoryId) => setState(() {
                _categoryId = categoryId;
              }),
              validator: _fieldValidator,
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: _selectedTags
                      .map((tag) => _buildTagChip(
                            tag,
                            () => _removeTag(tag),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Autocomplete<String>(
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return InkWell(
                                    onTap: () => onSelected(option),
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(option),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: t.tags,
                            hintText: t.tags_write,
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                if (controller.text.isNotEmpty) {
                                  _addTag(controller.text);
                                  controller.clear();
                                }
                              },
                            ),
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _addTag(value);
                              controller.clear();
                            }
                          },
                        );
                      },
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _availableTags.where((tag) =>
                          tag.toLowerCase().contains(textEditingValue.text.toLowerCase()) &&
                          !_selectedTags.contains(tag)
                        );
                      },
                      displayStringForOption: (String option) => option,
                      onSelected: _addTag,
                    );
                  }
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (widget.isGeneratingWithAI) ...[
              Column(
                children:[ 
                  TextFormField(
                  keyboardType: TextInputType.multiline,
                  minLines: 2,
                  maxLines: 4,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: t.survey_form_ai_description,
                    border: const OutlineInputBorder(),
                    hintText: t.survey_form_ai_description_hint,
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    ),
                    validator: _fieldValidator,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 2,
                    controller: _localeController,
                    decoration: InputDecoration(
                      labelText: t.language,
                      border: const OutlineInputBorder(),
                    ),
                    validator: _fieldValidator,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    minLines: 1,
                    maxLines: 2,
                    controller: _numberOfQuestionsController,
                    decoration: InputDecoration(
                      labelText: t.survey_form_ai_number_questions,
                      border: const OutlineInputBorder(),
                    ),
                    validator: _fieldNumberValidator,
                  ),
                  const SizedBox(height: 20),
                  
                ]
              ),
            ] else ...[
              TextFormField(
                keyboardType: TextInputType.multiline,
                minLines: 2,
                maxLines: 4,
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: t.description,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            DateFormField(
              context: context,
              labelText: t.start_date,
              initialDate: _startDate,
              onChanged: (date) => setState(() => _startDate = date),
              required: false,
              canSelectAFutureDate: true,
            ),
            const SizedBox(height: 20),
            DateFormField(
              context: context,
              labelText: t.end_date,
              initialDate: _endDate,
              onChanged: (date) => setState(() => _endDate = date),
              required: false,
              canSelectAFutureDate: true,
              validator: _endDateValidator,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: surveyProvider.isLoading ? null : _handleContinue,
              child: surveyProvider.isLoading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    )
                  : Text(t.go_forward),
            ),
          ],
        ),
      ),
    );
  }
}
