import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/auth/application/provider/auth_provider.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';

import '../../../category/application/provider/category_provider.dart';

class SurveyForm extends StatefulWidget {
  const SurveyForm({super.key});

  @override
  State<SurveyForm> createState() => SurveyFormState();
}

class SurveyFormState extends State<SurveyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(text: '');
  DateTime? _startDate;
  DateTime? _endDate;
  String? _categoryId;

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _endDateValidator(DateTime? value) {
    if (value != null && _startDate != null && value.isBefore(_startDate!)) {
      return 'End date cannot be before start date';
    }
    return null;
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      final surveyProvider =
          Provider.of<SurveyProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      bool success = surveyProvider.addSurveyInfo(
        _nameController.text,
        _descriptionController.text,
        _startDate ?? DateTime.now(),
        _endDate,
        _categoryId!,
        authProvider.user!.id,
      );
      if (success) {
        Navigator.pushNamed(context, AppRoutes.surveyAddQuestions);
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
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categories = categoryProvider.categories;
    final surveyProvider = Provider.of<SurveyProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            TextFormField(
              keyboardType: TextInputType.text,
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Survey Name',
                border: OutlineInputBorder(),
              ),
              validator: _fieldValidator,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ))
                  .toList(),
              onChanged: (categoryId) => setState(() {
                _categoryId = categoryId;
              }),
              validator: _fieldValidator,
            ),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            DateFormField(
              labelText: 'Start Date',
              initialDate: _startDate,
              onChanged: (date) => setState(() => _startDate = date),
              required: false,
              canSelectAFutureDate: true,
            ),
            const SizedBox(height: 20),
            DateFormField(
              labelText: 'End Date',
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
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
