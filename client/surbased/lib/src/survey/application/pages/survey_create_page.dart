import 'package:flutter/material.dart';
import 'package:surbased/src/auth/application/widgets/date_form_field_widget.dart';
import 'package:surbased/src/config/app_routes.dart';

class SurveyCreatePage extends StatefulWidget {
  const SurveyCreatePage({super.key});

  @override
  State<SurveyCreatePage> createState() => SurveyCreatePageState();
}

class SurveyCreatePageState extends State<SurveyCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  String? _fieldValidator(String? value) {
    if (value == null || value.isEmpty || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Survey'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Survey Title',
                    border: OutlineInputBorder(),
                  ),
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
                ),
                const SizedBox(height: 20),
                DateFormField(
                  labelText: 'End Date',
                  initialDate: _endDate,
                  onChanged: (date) => setState(() => _endDate = date),
                  required: false,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _formKey.currentState?.validate() ?? false
                      ? Navigator.pushNamed(
                          context,
                          AppRoutes.surveyAddQuestions,
                        )
                      : null,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
