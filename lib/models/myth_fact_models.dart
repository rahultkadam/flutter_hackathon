class MythFactStatement {
  final int id;
  final String statement;
  final bool isFact;
  final String explanation;
  final String category;
  final String emoji;

  MythFactStatement({
    required this.id,
    required this.statement,
    required this.isFact,
    required this.explanation,
    required this.category,
    required this.emoji,
  });
}

class MythFactGameResult {
  final int correctAnswers;
  final int totalQuestions;
  final int currentStreak;
  final DateTime completedDate;
  final List<bool> answers;

  MythFactGameResult({
    required this.correctAnswers,
    required this.totalQuestions,
    required this.currentStreak,
    required this.completedDate,
    required this.answers,
  });

  int get percentage => ((correctAnswers / totalQuestions) * 100).toInt();

  Map<String, dynamic> toJson() => {
    'correctAnswers': correctAnswers,
    'totalQuestions': totalQuestions,
    'currentStreak': currentStreak,
    'completedDate': completedDate.toIso8601String(),
    'answers': answers,
  };

  factory MythFactGameResult.fromJson(Map<String, dynamic> json) => MythFactGameResult(
    correctAnswers: json['correctAnswers'] as int,
    totalQuestions: json['totalQuestions'] as int,
    currentStreak: json['currentStreak'] as int,
    completedDate: DateTime.parse(json['completedDate'] as String),
    answers: List<bool>.from(json['answers'] as List),
  );
}
