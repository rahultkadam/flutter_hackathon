import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/myth_fact_models.dart';
import '../models/quiz_models.dart';
import '../models/user_profile.dart';
import '../models/daily_fact_models.dart';

class PerplexityService {
  static const String _baseUrl = 'https://api.perplexity.ai/chat/completions';
  static const String _apiKey = 'api-key'; // Replace with your key

  // FIX #1 & #2: Updated prompt with finance restriction and follow-up questions
  Future<String> getChatResponse(
      String userMessage,
      UserProfile profile,
      ) async {
    final systemPrompt = _buildSystemPrompt(profile);

    // FIX #1: Log the prompt being sent
    print('=== PERPLEXITY API PROMPT ===');
    print('System Prompt: $systemPrompt');
    print('User Message: $userMessage');
    print('============================');

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
          'max_tokens': 600,
          'temperature': 0.7,
        }),
      )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('choices')) {
          final choices = data['choices'];
          if (choices is List && choices.isNotEmpty) {
            final firstChoice = choices[0]; // Get the first element from choices
            if (firstChoice is Map && firstChoice.containsKey('message')) {
              final message = firstChoice['message'];
              if (message is Map && message.containsKey('content')) {
                final responseText = message['content'] as String? ?? '';

                // FIX #1: Log the response
                print('=== API RESPONSE ===');
                print(responseText);
                print('===================');

                return responseText;
              }
            }
          }
        }
        return 'Unable to parse response. Please try again.';
      }
      else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'API Error: ${response.statusCode} - ${errorBody['error']?['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('Error in getChatResponse: $e');
      rethrow;
    }
  }

  // FIX #1 & #2: Enhanced system prompt
  String _buildSystemPrompt(UserProfile profile) {
    return '''You are Money Buddy, a friendly financial advisor chatbot designed EXCLUSIVELY for Indian investors.

**CRITICAL RULES:**
1. You ONLY answer questions related to finance, investments, banking, taxes, insurance, and money management.
2. If the user asks about anything non-financial (weather, sports, general knowledge, etc.), respond with:
   "I'm Money Buddy, your financial advisor! 💰 I specialize in helping you with investments, taxes, SIP, mutual funds, insurance, and financial planning. Please ask me a finance-related question!"
3. ALWAYS end your response with 2 relevant related questions that the user may want to explore next in this exact format:

FOLLOW_UP:
- [First follow-up question]?
- [Second follow-up question]?

User Profile:
- Name: ${profile.firstName} ${profile.lastName}
- Age: ${profile.age} years old
- Gender: ${profile.gender}
- Occupation: ${profile.occupation}
- Income Range: ${profile.incomeRange}

Your responsibilities:
1. Provide personalized financial advice based on the user's profile
2. Explain investment concepts in SIMPLE, plain language
3. Focus on Indian financial products (SIP, mutual funds, PPF, NPS, ELSS, etc.)
4. Use emojis occasionally to make conversations friendly
5. Keep responses SHORT and concise (under 150 words)
6. Provide age and income-appropriate suggestions
7. Include disclaimers when needed
8. Encourage long-term thinking and diversification
9. **ALWAYS** end with 2 follow-up questions in the FOLLOW_UP: format

Response Format:
- Start with an emoji or short greeting
- Answer in 2-3 simple sentences
- Provide 1-2 practical examples relevant to their profile
- End with an actionable tip
- **MUST** end with FOLLOW_UP: section with 2 questions

Example:
"Great question! 💡 SIP (Systematic Investment Plan) is a way to invest a fixed amount regularly in mutual funds...

FOLLOW_UP:
- What's the minimum amount to start a SIP?
- Which mutual fund categories are best for beginners?"

Remember: Finance topics ONLY. Always include FOLLOW_UP questions and FOLLOW_UP questions answer should be expected from API and not user ''';
  }

  // Generate quiz questions from API
  Future<List<QuizQuestion>> generateQuizQuestions(
      UserProfile profile,
      String difficulty,
      int count,
      ) async {
    try {
      final prompt = '''
Generate exactly $count multiple-choice financial quiz questions for a ${profile.age}-year-old ${profile.gender} with income ${profile.incomeRange}.
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
        explanation: 'ELSS has a mandatory lock-in period of 3 years, the shortest among tax-saving instruments.',
        category: 'Tax Saving',
        difficulty: 'Beginner',
      ),
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

  // ADD THIS METHOD TO YOUR EXISTING PerplexityService CLASS

  Future<List<DailyFact>> generateDailyFacts(
      UserProfile profile,
      int count,
      ) async {
    try {

      final prompt = '''
Generate exactly $count mind-blowing, interesting financial facts for a ${profile.age}-year-old with income ${profile.incomeRange} & occupation - ${profile.occupation}.

Create a balanced mix of:

Positive, inspiring financial stories:

-legendary investment wins
-smart long-term wealth strategies
-Indian stock market success stories (Infosys IPO, Sensex growth, SIP compounding, etc.)
-entrepreneurs and investors who made brilliant decisions
-Crazy investment bubbles (tulips, beanie babies, crypto)

Negative or cautionary stories:

-historical financial disasters (dot-com crash, Great Depression, 2008 crisis)
-speculative bubbles (tulip mania, beanie babies, crypto manias)
-corporate scandals (Enron, Lehman Brothers, Satyam)
-famous investor mistakes and losses
-Shocking corporate scandals (Enron, Lehman Brothers)

Neutral / weird / fun financial trivia:
-unusual economic events
-strange market behaviors
-odd financial rules, loopholes, or historical quirks
-Economic phenomena that seem unbelievable

Proportion rule:
40 percent positive + 40 percent negative + 20 percent neutral or weird trivia.
The tone must be mind-blowing, surprising, and also motivating so the user feels excited to learn more about finance and investing.
Give priority to Indian Market.

Each fact must create reactions like:
"OMG, I didn't know that!"
"Wow, that's crazy!"
"This makes me want to learn more!"

Each fact should make someone say "OMG, I didn't know that!" or "Wow, that's crazy!"

Format as JSON array:
[{
  "headline": "Did you know... [short catchy 1-2 line fact]",
  "fullExplanation": "Detailed explanation with context, dates, and why it matters (3-4 sentences)",
  "category": "Bubbles/Crashes/Scandals/Trivia/Investors",
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
        final choices = data['choices'];
        String? content;
        if (choices is List &&
            choices.isNotEmpty &&
            choices[0] is Map &&
            (choices[0] as Map).containsKey('message')) {
          final msg = choices[0]['message']; // FIXED: choices[0] not choices
          if (msg is Map && msg.containsKey('content')) {
            content = msg['content'] as String?;
          } else if (msg is String) {
            content = msg;
          }
        }


        if (content != null) {
          final jsonMatch = RegExp(r'\[[\s\S]*\]').firstMatch(content);
          if (jsonMatch != null) {
            final jsonStr = jsonMatch.group(0)!;
            final List factsJson = jsonDecode(jsonStr);

            return factsJson.asMap().entries.map((entry) {
              final f = entry.value;
              return DailyFact(
                id: entry.key + 1,
                headline: f['headline'] as String,
                fullExplanation: f['fullExplanation'] as String,
                category: 'Trivia',
                emoji: f['emoji'] as String? ?? '💡',
                date: DateTime.now(),
              );
            }).toList();
          }
        }
      }

      return _getFallbackFacts(count);
    } catch (e) {
      print('Error generating trivia: $e');
      return _getFallbackFacts(count);
    }
  }

  List<DailyFact> _getFallbackFacts(int count) {
    final fallbacks = [
      DailyFact(
        id: 1,
        headline: 'Did you know the dot-com bubble had companies with no product—just vibes?',
        fullExplanation: 'During the late 1990s dot-com bubble, companies with no revenue, no products, and sometimes just a domain name raised millions. Pets.com spent \$300 million before going bankrupt in 268 days. The bubble burst in 2000, erasing \$5 trillion in value.',
        category: 'Trivia',
        emoji: '💥',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 2,
        headline: 'Did you know the Great Depression began partly because people bought stocks with borrowed money?',
        fullExplanation: 'In the 1920s, you could buy stocks with only 10% down payment, borrowing the rest. When the market crashed in 1929, these "margin calls" forced mass sell-offs, creating a death spiral. The Dow Jones lost 89% of its value by 1932.',
        category: 'Trivia',
        emoji: '📉',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 3,
        headline: 'Did you know a 17th-century bubble promised profits from a business "doing nothing at all"?',
        fullExplanation: 'During the South Sea Bubble of 1720, one scammer literally advertised shares for "a company for carrying out an undertaking of great advantage, but nobody to know what it is." He raised £2,000 in a day, then disappeared forever.',
        category: 'Trivia',
        emoji: '🎪',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 4,
        headline: 'Did you know banks in 2008 were selling risky mortgages like Black Friday deals?',
        fullExplanation: 'Banks gave mortgages to people with no income verification (NINJA loans - No Income, No Job, no Assets), then packaged them as "safe" AAA-rated securities. When housing prices fell, \$2 trillion vanished and Lehman Brothers collapsed overnight.',
        category: 'Trivia',
        emoji: '🏚️',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 5,
        headline: 'Did you know investors once believed beanie babies would make them rich?',
        fullExplanation: 'In the 1990s, people bought Beanie Babies thinking they\'d be worth millions. Rare ones sold for \$5,000+. Today, 99% are worthless. One guy spent \$100,000 on them and later got divorced over his collection. His wife got half the beanie babies.',
        category: 'Trivia',
        emoji: '🧸',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 6,
        headline: 'Did you know a single accounting lie can cost more than an actual crime?',
        fullExplanation: 'Enron\'s CFO hid \$1 billion in debt using fake companies. When exposed in 2001, \$74 billion in shareholder value vanished. 20,000 employees lost jobs and pensions. The CEO got 24 years in prison—longer than many violent criminals.',
        category: 'Trivia',
        emoji: '🎭',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 7,
        headline: 'Did you know Warren Buffett still lives in a house he bought for \$31,500 in 1958?',
        fullExplanation: 'Despite being worth \$120+ billion, Buffett lives in his Omaha home bought for \$31,500 (about \$340,000 today). He drives a modest car, doesn\'t carry a smartphone, and once said his greatest investment was a \$100 public speaking course.',
        category: 'Trivia',
        emoji: '🏡',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 8,
        headline: 'Did you know tulips were once worth more than houses in Holland?',
        fullExplanation: 'During "Tulip Mania" in 1637, a single tulip bulb sold for 10 times a skilled worker\'s annual salary. One rare bulb was traded for a house in Amsterdam. When the bubble burst, prices dropped 99% in weeks, bankrupting thousands.',
        category: 'Trivia',
        emoji: '🌷',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 9,
        headline: 'Did you know Bitcoin pizza cost \$10...and would be worth \$650 million today?',
        fullExplanation: 'On May 22, 2010, programmer Laszlo Hanyecz paid 10,000 Bitcoin for two pizzas—the first Bitcoin transaction for physical goods. At Bitcoin\'s \$65,000 peak, those pizzas were worth \$650 million. May 22 is now "Bitcoin Pizza Day."',
        category: 'Trivia',
        emoji: '🍕',
        date: DateTime.now(),
      ),
      DailyFact(
        id: 10,
        headline: 'Did you know the 2008 crisis started with a \$1.2 billion lie about mortgage quality?',
        fullExplanation: 'Rating agencies like Moody\'s and S&P gave AAA ratings (highest safety) to mortgage bundles that were 90% junk. Internal emails later revealed analysts knew they were "rating garbage" but did it anyway for profit. Fines: \$2 billion. Damage: \$10+ trillion.',
        category: 'Trivia',
        emoji: '💣',
        date: DateTime.now(),
      ),
    ];

    return fallbacks.take(count).toList();
  }

}
