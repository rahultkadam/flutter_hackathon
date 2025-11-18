class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer; // Index of correct option
  final String explanation;
  final String category; // SIP, Mutual Funds, Stocks, Tax, Insurance
  final String difficulty; // Beginner, Intermediate, Advanced

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.category,
    required this.difficulty,
  });
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final int streakDays;
  final DateTime completedDate;
  final String difficulty;
  final List<int> answers; // User's answers

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.streakDays,
    required this.completedDate,
    required this.difficulty,
    required this.answers,
  });

  int get percentage => ((score / totalQuestions) * 100).toInt();

  Map<String, dynamic> toJson() => {
    'score': score,
    'totalQuestions': totalQuestions,
    'streakDays': streakDays,
    'completedDate': completedDate.toIso8601String(),
    'difficulty': difficulty,
    'answers': answers,
  };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    score: json['score'] as int,
    totalQuestions: json['totalQuestions'] as int,
    streakDays: json['streakDays'] as int,
    completedDate: DateTime.parse(json['completedDate'] as String),
    difficulty: json['difficulty'] as String,
    answers: List<int>.from(json['answers'] as List),
  );
}

class UserBadge {
  final String name;
  final String description;
  final String emoji;
  final DateTime unlockedDate;

  UserBadge({
    required this.name,
    required this.description,
    required this.emoji,
    required this.unlockedDate,
  });
}
