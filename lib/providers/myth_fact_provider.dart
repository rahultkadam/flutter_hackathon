import 'package:flutter/foundation.dart';
import '../models/myth_fact_models.dart';
import '../models/user_profile.dart';
import '../services/perplexity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MythFactProvider extends ChangeNotifier {
  final PerplexityService _perplexityService = PerplexityService();

  List<MythFactStatement> _currentStatements = [];
  int _currentStatementIndex = 0;
  int _correctAnswers = 0;
  int _streak = 0;
  int _maxStreak = 0;
  bool _isGameActive = false;
  bool _isLoading = false;
  List<bool> _userAnswers = [];
  List<MythFactGameResult> _gameResults = [];
  UserProfile? _userProfile;

  List<MythFactStatement> get currentStatements => _currentStatements;
  int get currentStatementIndex => _currentStatementIndex;
  MythFactStatement? get currentStatement =>
      (_currentStatementIndex < _currentStatements.length)
          ? _currentStatements[_currentStatementIndex]
          : null;

  int get correctAnswers => _correctAnswers;
  int get streak => _streak;
  int get maxStreak => _maxStreak;
  bool get isGameActive => _isGameActive;
  bool get isLoading => _isLoading;
  List<MythFactGameResult> get gameResults => _gameResults;
  int get totalAnswered => _userAnswers.length;

  // FIX #7: Added to track last game result
  MythFactGameResult? _lastGameResult;
  MythFactGameResult? get lastGameResult => _lastGameResult;

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    notifyListeners();
  }

  // FIX #7: Always fetch from API
  Future<void> startGame() async {
    if (_userProfile == null) return;

    _isLoading = true;
    _lastGameResult = null; // Reset last result
    notifyListeners();

    try {
      await _loadGameData();

      // FIX #7: Always fetch fresh statements from API
      print('🎲 Fetching myth vs fact statements from API...');
      _currentStatements = await _perplexityService.generateMythFactStatements(
        _userProfile!,
        20,
      );
      print('✅ Fetched ${_currentStatements.length} statements');

      _currentStatementIndex = 0;
      _correctAnswers = 0;
      _streak = 0;
      _userAnswers = [];
      _isGameActive = true;
    } catch (e) {
      print('❌ Error starting game: $e');
      _currentStatements = [];
      _isGameActive = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  bool isAnswerCorrect(MythFactStatement statement, bool userSwipedRight) {
    return userSwipedRight == statement.isFact;
  }

  void processAnswer(bool isCorrect) {
    if (!_isGameActive) return;

    _userAnswers.add(isCorrect);

    if (isCorrect) {
      _correctAnswers++;
      _streak++;
      if (_streak > _maxStreak) {
        _maxStreak = _streak;
      }
      print('✅ Correct! Score: $_correctAnswers/${_currentStatements.length}');
    } else {
      _streak = 0;
      print('❌ Incorrect! Score: $_correctAnswers/${_currentStatements.length}');
    }

    if (_currentStatementIndex < _currentStatements.length - 1) {
      _currentStatementIndex++;
      notifyListeners();
    } else {
      // FIX #7: End game when all questions answered
      endGame();
    }
  }

  Future<void> endGame() async {
    _isGameActive = false;

    final result = MythFactGameResult(
      correctAnswers: _correctAnswers,
      totalQuestions: _currentStatements.length,
      currentStreak: _maxStreak,
      completedDate: DateTime.now(),
      answers: _userAnswers,
    );

    _gameResults.add(result);
    _lastGameResult = result; // FIX #7: Store for results screen

    await _saveGameData();

    print('🎮 Game ended. Final score: $_correctAnswers/${_currentStatements.length} (${result.percentage}%)');
    notifyListeners();
  }

  Future<void> _saveGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = _gameResults.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList('mythfact_results', resultsJson);
      await prefs.setInt('mythfact_max_streak', _maxStreak);
    } catch (e) {
      print('Error saving game data: $e');
    }
  }

  Future<void> _loadGameData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final resultsJson = prefs.getStringList('mythfact_results') ?? [];
      _gameResults = resultsJson
          .map((r) => MythFactGameResult.fromJson(jsonDecode(r)))
          .toList();
      _maxStreak = prefs.getInt('mythfact_max_streak') ?? 0;
    } catch (e) {
      print('Error loading game data: $e');
    }
  }

  void resetGame() {
    _currentStatements = [];
    _currentStatementIndex = 0;
    _correctAnswers = 0;
    _streak = 0;
    _userAnswers = [];
    _isGameActive = false;
    _lastGameResult = null;
    notifyListeners();
  }
}
