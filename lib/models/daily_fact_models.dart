class DailyFact {
  final int id;
  final String headline;
  final String fullExplanation;
  final String category;
  final String emoji;
  final DateTime date;
  bool isBookmarked;

  DailyFact({
    required this.id,
    required this.headline,
    required this.fullExplanation,
    required this.category,
    required this.emoji,
    required this.date,
    this.isBookmarked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'headline': headline,
      'fullExplanation': fullExplanation,
      'category': category,
      'emoji': emoji,
      'date': date.toIso8601String(),
      'isBookmarked': isBookmarked,
    };
  }

  factory DailyFact.fromJson(Map<String, dynamic> json) {
    return DailyFact(
      id: json['id'] as int,
      headline: json['headline'] as String,
      fullExplanation: json['fullExplanation'] as String,
      category: json['category'] as String? ?? 'Finance',
      emoji: json['emoji'] as String? ?? '💰',
      date: DateTime.parse(json['date'] as String),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }

  DailyFact copyWith({bool? isBookmarked}) {
    return DailyFact(
      id: id,
      headline: headline,
      fullExplanation: fullExplanation,
      category: category,
      emoji: emoji,
      date: date,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

class DailyFactSession {
  final DateTime date;
  final int factsViewed;
  final List<int> bookmarkedFactIds;

  DailyFactSession({
    required this.date,
    required this.factsViewed,
    required this.bookmarkedFactIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'factsViewed': factsViewed,
      'bookmarkedFactIds': bookmarkedFactIds,
    };
  }

  factory DailyFactSession.fromJson(Map<String, dynamic> json) {
    return DailyFactSession(
      date: DateTime.parse(json['date'] as String),
      factsViewed: json['factsViewed'] as int,
      bookmarkedFactIds: List<int>.from(json['bookmarkedFactIds'] ?? []),
    );
  }
}
