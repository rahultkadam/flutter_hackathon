class ChatSession {
  final String id;
  final DateTime createdAt;
  final String title;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isFavorite;
  final List<String>? suggestedFollowUps;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isFavorite = false,
    this.suggestedFollowUps,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'isFavorite': isFavorite,
    'suggestedFollowUps': suggestedFollowUps,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] as String,
    content: json['content'] as String,
    isUser: json['isUser'] as bool,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isFavorite: json['isFavorite'] as bool? ?? false,
    suggestedFollowUps: (json['suggestedFollowUps'] as List?)?.cast<String>(),
  );
}

class QuickSuggestion {
  final String title;
  final String query;
  final String emoji;

  QuickSuggestion({
    required this.title,
    required this.query,
    required this.emoji,
  });
}
