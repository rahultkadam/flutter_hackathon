import 'package:flutter/foundation.dart';
import '../models/quiz_models.dart';
import '../models/user_profile.dart';
import '../services/perplexity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuizProvider extends ChangeNotifier {
  final PerplexityService _perplexityService = PerplexityService();

  List<QuizQuestion> _currentQuiz = [];
  List<int> _userAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isQuizStarted = false;
  bool _isLoading = false;
  String _selectedDifficulty = 'Beginner';
  UserProfile? _userProfile;

  int _streakDays = 0;
  List<QuizResult> _quizResults = [];
  List<UserBadge> _badges = [];

  // Getters
  List<QuizQuestion> get currentQuiz => _currentQuiz;
  List<int> get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  bool get isQuizStarted => _isQuizStarted;
  bool get isLoading => _isLoading;
  String get selectedDifficulty => _selectedDifficulty;
  int get streakDays => _streakDays;
  List<QuizResult> get quizResults => _quizResults;
  List<UserBadge> get badges => _badges;

  QuizQuestion? get currentQuestion =>
      _currentQuestionIndex < _currentQuiz.length ? _currentQuiz[_currentQuestionIndex] : null;

  int get score => _userAnswers.asMap().entries.fold(0, (sum, entry) {
    if (entry.key >= _currentQuiz.length) return sum;
    return sum + (_currentQuiz[entry.key].correctAnswer == entry.value ? 1 : 0);
  });

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
  }

  Future<void> startQuiz(String difficulty) async {
    if (_userProfile == null) return;

    _selectedDifficulty = difficulty;
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch quiz questions from API
      _currentQuiz = await _perplexityService.generateQuizQuestions(
        _userProfile!,
        difficulty,
        5, // 5 questions
      );

      _userAnswers = [];
      _currentQuestionIndex = 0;
      _isQuizStarted = true;

      await _loadQuizData();
    } catch (e) {
      print('Error starting quiz: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(int optionIndex) {
    if (_currentQuestionIndex < _userAnswers.length) {
      _userAnswers[_currentQuestionIndex] = optionIndex;
    } else {
      _userAnswers.add(optionIndex);
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _currentQuiz.length - 1) {
      _currentQuestionIndex++;
    }
    notifyListeners();
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
    }
    notifyListeners();
  }

  Future<void> submitQuiz() async {
    final result = QuizResult(
      score: score,
      totalQuestions: _currentQuiz.length,
      streakDays: _streakDays + 1,
      completedDate: DateTime.now(),
      difficulty: _selectedDifficulty,
      answers: _userAnswers,
    );

    _quizResults.add(result);
    _streakDays = result.streakDays;

    _checkAndUnlockBadges();
    await _saveQuizData();

    _isQuizStarted = false;
    notifyListeners();
  }

  void _checkAndUnlockBadges() {
    if (_streakDays == 7 && !_badges.any((b) => b.name == 'Week Warrior')) {
      _badges.add(UserBadge(
        name: 'Week Warrior',
        description: '7-day streak achieved!',
        emoji: '🔥',
        unlockedDate: DateTime.now(),
      ));
    }

    if (_quizResults.length == 20 && !_badges.any((b) => b.name == 'Quiz Master')) {
      _badges.add(UserBadge(
        name: 'Quiz Master',
        description: 'Completed 20 quizzes!',
        emoji: '🎓',
        unlockedDate: DateTime.now(),
      ));
    }

    if (_streakDays == 100 && !_badges.any((b) => b.name == '100-Day Streak')) {
      _badges.add(UserBadge(
        name: '100-Day Streak',
        description: 'Incredible 100-day streak!',
        emoji: '🏆',
        unlockedDate: DateTime.now(),
      ));
    }

    if (score == _currentQuiz.length) {
      _badges.add(UserBadge(
        name: 'Perfect Score',
        description: 'Scored 100% on a quiz!',
        emoji: '⭐',
        unlockedDate: DateTime.now(),
      ));
    }
  }

  Future<void> _saveQuizData() async {
    final prefs = await SharedPreferences.getInstance();

    final resultsJson = _quizResults.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList('quiz_results', resultsJson);
    await prefs.setInt('streak_days', _streakDays);
  }

  Future<void> _loadQuizData() async {
    final prefs = await SharedPreferences.getInstance();

    final resultsJson = prefs.getStringList('quiz_results') ?? [];
    _quizResults = resultsJson.map((r) => QuizResult.fromJson(jsonDecode(r))).toList();
    _streakDays = prefs.getInt('streak_days') ?? 0;
  }

  void resetQuiz() {
    _currentQuiz = [];
    _userAnswers = [];
    _currentQuestionIndex = 0;
    _isQuizStarted = false;
    notifyListeners();
  }
}
