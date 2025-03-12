import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:surbased/src/category/application/provider/category_provider.dart';
import 'package:surbased/src/survey/application/provider/survey_provider.dart';

class SurveyInfo extends StatelessWidget {
  const SurveyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surveyProvider = Provider.of<SurveyProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final survey = surveyProvider.currentSurvey;
    final dateFormat = DateFormat('dd/MM/yyyy');

    if (survey == null) {
      return const Center(child: Text('No survey selected'));
    }

    if (surveyProvider.isLoading || categoryProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final category = categoryProvider.getCategoryById(survey.categoryId);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información general
            ExpansionTile(
              initiallyExpanded: true,
              title: Text(
                "General Information",
                style: theme.textTheme.titleLarge,
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        'Name',
                        survey.name,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Category',
                        category.name,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'Start Date',
                        dateFormat.format(survey.startDate),
                      ),
                      if (survey.endDate != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'End Date',
                          dateFormat.format(survey.endDate!),
                        ),
                      ],
                      if (survey.description != null &&
                          survey.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Description:',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          survey.description!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            // Preguntas
            ExpansionTile(
              initiallyExpanded: survey.questions.length < 10,
              title: Text(
                "Questions (${survey.questions.length})",
                style: theme.textTheme.titleLarge,
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: survey.questions.length,
                  itemBuilder: (context, index) {
                    final question = survey.questions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary,
                        child: Text('${index + 1}'),
                      ),
                      title: Text(question.description ?? 'No description'),
                      subtitle: Text(question.multipleAnswer == true
                          ? 'Multiple choice'
                          : 'Single choice'),
                    );
                  },
                ),
              ],
            ),
            ExpansionTile(
              initiallyExpanded: true,
              title: Text("Answers (poner numero)",
                  style: theme.textTheme.titleLarge),
              children: const [
                Text(
                    "Aqui ira una lista de respuestas en la que si pulsas se puede ver la respuesta de cada user"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoRow(
  BuildContext context,
  String label,
  String value,
) {
  final theme = Theme.of(context);

  return Align(
    alignment: Alignment.centerLeft,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge,
        ),
      ],
    ),
  );
}
