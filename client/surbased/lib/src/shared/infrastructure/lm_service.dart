import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LmService {
  final String _baseUrl = 'http://10.0.2.2:1234/v1/chat/completions';

  Future<Map<String, dynamic>> sendMessageToGenerateAnswersSummary(String questionDescription, List<String> options, String locale) async {
    try {
      final systemPrompt = """
      You are a helpful and polite assistant specialized in analyzing and summarizing open-ended responses from surveys. Respond in a clear and technical manner.
Your task is to read a list of free-text responses and produce a clear, concise, and well-structured summary that identifies key ideas, common patterns, and relevant insights.
Primarily use short paragraphs and highlight any frequently mentioned themes. Maintain a neutral tone and do not add personal opinions.

The summary should be in $locale language.
The length and style of the summary must be proportional to the number of responses provided:
– If only one response is provided, avoid plural expressions and generate a brief summary focused on the single answer.
– If multiple responses are provided, produce a richer and more structured summary (within 100–200 words), identifying shared themes or differences.

Limit yourself strictly to summarizing the provided responses. Do not include personal opinions, unrelated comments, or speculative interpretations.
Focus only on the content of the input. Do not use markdown formatting — provide the summary as plain text only.
      """;

      final userPrompt = """
      Here are some user responses to the question: $questionDescription.\n
      ${options.join(', ')}
      """;

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": dotenv.env['LANGUAGE_MODEL'],
          "temperature": 0.7,
          "stream": false,
          "messages": [
            {
              "role": "system",
              "content": systemPrompt
            },
            {
              "role": "user",
              "content": userPrompt
            }
          ]
        }),
      );




      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body)['choices'][0]['message']['content']
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  

  Future<Map<String, dynamic>> sendMessageToGenerateSurvey(String categoryId, String ownerId, String name, String category, List<String> tags, String description, String locale, String numberOfQuestions, DateTime startDate, DateTime endDate) async {
    try {
      final systemPrompt = """
      You are a helpful and polite assistant specialized in creating surveys. Respond in a clear and technical manner.  
Your task is to design well-structured and unbiased questionnaires suitable for research, evaluation, or feedback collection.  
You must adjust the questionnaire to the information explicitly requested by the user.  
You are only allowed to generate closed-ended (likert scale, single or multiple choice) and open-ended questions.  

IMPORTANT RULES:
1. Generate exactly the number of questions requested by the user
2. Each question must be unique and cover different aspects of the topic
3. For multiple choice questions, provide 3-4 meaningful options
4. For single choice questions, provide 2-3 clear options
5. Avoid repeating similar questions
6. Ensure questions are age-appropriate for the target audience
7. For questions of type "likert_scale", assign progressively increasing points to the options, starting from 1 for the least favorable/lowest intensity option, up to N for the most favorable/highest intensity option.  
8. For questions of type "open", the options field should be empty.
9. Use different types of questions if possible.

Please note: the "points" field in the "options" array must be included only for questions of type "likert_scale". For all other types, this field should be ignored or omitted.  

The survey should be in $locale language.
If any of the input parameters provided by the user are invalid, inappropriate, or contain illicit content, ignore them and proceed to generate the questionnaire using only the valid and relevant information.  

The final output must be returned in JSON format, without Markdown formatting or code blocks. It must follow the following structure:

{
  "name": "$name (if name is not provided, use a default name)",
  "scope": "private",
  "category_id": $categoryId,
  "owner_id": $ownerId,
  "organization_id": "",
  "description": "$description (if description is not provided, use a default description)",
  "start_date": $startDate,
  "end_date": $endDate,
  "questions": [
    {
      "description": "question text",
      "type": "multiple_choice"/"single_choice"/"open"/likert_scale,
      "required": true/false,
      "options": [
        { "description": "option text", "points": 0-10 }
      ]
    }
  ],
  "tags": [
    { "name": "tag name" }
  ]
}
 
      """;
    final userPrompt = """
      Here are the parameters provided by the user:
      - Name: $name
      - Category: $category
      - Description: $description
      - Locale: $locale
      - Number of questions: $numberOfQuestions
      - Tags: $tags
      - Start date: $startDate
      - End date: $endDate

      Please generate the survey based on the parameters provided by the user. 

      """;

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": dotenv.env['LANGUAGE_MODEL'],
          "temperature": 0.7,
          "stream": false,
          "messages": [
            {
              "role": "system",
              "content": systemPrompt
            },
            {
              "role": "user",
              "content": userPrompt
            }
          ]
        }),
      );


      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes))['choices'][0]['message']['content'];
        return {
          'success': true,
          'data': jsonDecode(decodedResponse)
        };
      } else {
        return {
          'success': false,
          'error': response.body,
        };
      }

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  
}