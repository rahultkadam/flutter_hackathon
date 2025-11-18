import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/myth_fact_models.dart';
import '../models/quiz_models.dart';
import '../models/user_profile.dart';

class PerplexityService {
  static const String _baseUrl = 'https://api.perplexity.ai/chat/completions';

  // ⚠️ IMPORTANT: Replace with your API key from https://www.perplexity.ai/settings/api
  static const String _apiKey = 'api-key';

  Future<String> getChatResponse(
  String userMessage,
  UserProfile profile,
) async {
  if (_apiKey == 'YOUR_PERPLEXITY_API_KEY_HERE') {
    throw Exception(
      'Please set your Perplexity API key in lib/services/perplexity_service.dart',
    );
  }

  final systemPrompt = _buildSystemPrompt(profile);

  try {
    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': 'sonar',
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userMessage}
            ],
            'max_tokens': 500,
            'temperature': 0.7,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Safe parsing with type checking
      if (data is Map && data.containsKey('choices')) {
        final choices = data['choices'];
        if (choices is List && choices.isNotEmpty) {
          final firstChoice = choices[0];
          if (firstChoice is Map && firstChoice.containsKey('message')) {
            final message = firstChoice['message'];
            if (message is Map && message.containsKey('content')) {
              return message['content'] as String? ?? '';
            }
          }
        }
      }

      return 'Unable to parse response. Please try again.';
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception(
        'API Error: ${response.statusCode} - ${errorBody['error']?['message'] ?? 'Unknown error'}',
      );
    }
  } catch (e) {
    rethrow;
  }
}


  String _buildSystemPrompt(UserProfile profile) {
    return '''You are Money Buddy, a friendly financial advisor chatbot designed for Indian investors.

User Profile:
- Age: ${profile.age} years old
- Gender: ${profile.gender}
- Occupation: ${profile.occupation}
- Income Range: ${profile.incomeRange}

Your responsibilities:
1. Provide personalized financial advice based on the user's profile
2. Explain investment concepts in SIMPLE, plain language
3. Focus on Indian financial products and context (SIP, mutual funds, PPF, NPS, ELSS, etc.)
4. Use emojis occasionally to make conversations friendly and engaging
5. Keep responses SHORT and concise (under 100 words)
6. Provide age and income-appropriate suggestions
7. Never give personalized investment advice without disclaimers
8. Encourage long-term thinking and diversification
9. Users are from india so focus on indian finance.

Note : Strictly stick to your roles and responsibilities and don't answer to any question other than finance.
Send generic response if any other question is received.

Response Format:
- Start with an engaging emoji or short greeting
- Explain the concept in 2-3 simple sentences
- Provide 1-2 practical examples relevant to their profile
- End with an actionable tip or question

Remember: You are teaching financial literacy, not trading strategies.''';
  }

  Future<List<QuizQuestion>> generateQuizQuestions(
      UserProfile profile,
      String difficulty,
      int count,
      ) async {
    try {
      final prompt = '''
Generate exactly $count multiple-choice financial quiz questions for a ${profile.age}-year-old ${profile.gender} with income ${profile.incomeRange}.
User is from India. 
Difficulty: $difficulty

Format as JSON array with this structure:
[{
  "question": "question text",
  "options": ["option1", "option2", "option3", "option4"],
  "correctAnswer": 0,
  "explanation": "detailed explanation",
  "category": "category name"
}]
Return ONLY the JSON array, no other text.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'sonar',
          'messages': [{'role': 'user', 'content': prompt}],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // >>> FIX: Use correct path for content
        final content = data['choices'][0]['message']['content'];

        // Extract JSON array from string
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final List<dynamic> questionsJson = jsonDecode(jsonStr);

          return questionsJson.asMap().entries.map((entry) {
            final q = entry.value;
            return QuizQuestion(
              id: entry.key + 1,
              question: q['question'] as String,
              options: List<String>.from(q['options']),
              correctAnswer: q['correctAnswer'] is int
                  ? q['correctAnswer'] as int
                  : int.tryParse(q['correctAnswer'].toString()) ?? 0,
              explanation: q['explanation'] as String,
              category: q['category'] as String,
              difficulty: difficulty,
            );
          }).toList();
        }
      }
      return _getFallbackQuizQuestions(difficulty, count);
    } catch (e) {
      print('Error generating quiz: $e');
      return _getFallbackQuizQuestions(difficulty, count);
    }
  }

  Future<List<MythFactStatement>> generateMythFactStatements(
      UserProfile profile,
      int count,
      ) async {
    try {
      final prompt = '''
Generate exactly $count financial myth or fact statements for a ${profile.age}-year-old with income ${profile.incomeRange}.
User is from India.
Format as JSON array:
[{
  "statement": "statement text",
  "isFact": true/false,
  "explanation": "detailed explanation why it's myth or fact",
  "category": "category name",
  "emoji": "relevant emoji"
}]
Return ONLY the JSON array, no other text.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'sonar',
          'messages': [{'role': 'user', 'content': prompt}],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          final List<dynamic> statementsJson = jsonDecode(jsonStr);

          return statementsJson.asMap().entries.map((entry) {
            final s = entry.value;
            return MythFactStatement(
              id: entry.key + 1,
              statement: s['statement'] as String,
              isFact: s['isFact'] as bool,
              explanation: s['explanation'] as String,
              category: s['category'] as String,
              emoji: s['emoji'] as String,
            );
          }).toList();
        }
      }

      return _getFallbackMythFactStatements(count);
    } catch (e) {
      print('Error generating myths: $e');
      return _getFallbackMythFactStatements(count);
    }
  }

  Future<List<String>> generateQuickSuggestions(UserProfile profile) async {
    try {
      final prompt = '''
Generate 4 short - (max 5 words), personalized financial question suggestions for a ${profile.age}-year-old ${profile.gender} with income ${profile.incomeRange}.
User is from India.
Format as JSON array of strings:
["Question 1?", "Question 2?", "Question 3?", "Question 4?"]

Return ONLY the JSON array, no other text.
''';

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'sonar',
          'messages': [{'role': 'user', 'content': prompt}],
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          return List<String>.from(jsonDecode(jsonStr));
        }
      }

      return _getFallbackSuggestions();
    } catch (e) {
      print('Error generating suggestions: $e');
      return _getFallbackSuggestions();
    }
  }

  // Fallback methods
  List<QuizQuestion> _getFallbackQuizQuestions(String difficulty, int count) {
    final allQuestions = [
      QuizQuestion(
        id: 1,
        question: 'What does SIP stand for?',
        options: ['Simple Investment Plan', 'Systematic Investment Plan', 'Stock Investment Program', 'Savings Investment Plan'],
        correctAnswer: 1,
        explanation: 'SIP stands for Systematic Investment Plan. It allows you to invest a fixed amount regularly in mutual funds.',
        category: 'SIP',
        difficulty: 'Beginner',
      ),
      QuizQuestion(
        id: 2,
        question: 'What is the lock-in period for ELSS mutual funds?',
        options: ['1 year', '2 years', '3 years', '5 years'],
        correctAnswer: 2,
        explanation: 'ELSS (Equity Linked Savings Scheme) has a mandatory lock-in period of 3 years, the shortest among tax-saving instruments.',
        category: 'Tax Saving',
        difficulty: 'Beginner',
      ),
      // Add more fallback questions...
    ];

    return allQuestions.take(count).toList();
  }

  List<MythFactStatement> _getFallbackMythFactStatements(int count) {
    final allStatements = [
      MythFactStatement(
        id: 1,
        statement: 'You need ₹1 lakh to start investing',
        isFact: false,
        explanation: 'False! Many investment options like SIPs start from just ₹100-500.',
        category: 'Investment Basics',
        emoji: '💰',
      ),
      MythFactStatement(
        id: 2,
        statement: 'PPF is 100% safe and government-backed',
        isFact: true,
        explanation: 'True! PPF is backed by the government and offers guaranteed returns.',
        category: 'Investment Basics',
        emoji: '🏦',
      ),
      // Add more fallback statements...
    ];

    return allStatements.take(count).toList();
  }

  List<String> _getFallbackSuggestions() {
    return [
      'Best investment for my age?',
      'How to save tax?',
      'Emergency fund calculation',
      'Explain SIP in 30 seconds',
    ];
  }

}
