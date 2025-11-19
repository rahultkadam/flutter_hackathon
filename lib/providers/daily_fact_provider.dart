import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/daily_fact_models.dart';
import '../models/user_profile.dart';
import '../services/perplexity_service.dart'; // FIX #6: Use PerplexityService

class DailyFactProvider extends ChangeNotifier {
  final PerplexityService _service = PerplexityService(); // FIX #6: Changed from DailyFactService

  List<DailyFact> _todaysFacts = [];
  int _currentFactIndex = 0;
  bool _isLoading = false;
  UserProfile? _userProfile;
  DailyFactSession? _todaySession;
  List<DailyFact> _bookmarkedFacts = [];

  List<DailyFact> get todaysFacts => _todaysFacts;
  DailyFact? get currentFact =>
      (_currentFactIndex < _todaysFacts.length && _todaysFacts.isNotEmpty)
          ? _todaysFacts[_currentFactIndex]
          : null;
  int get currentFactIndex => _currentFactIndex;
  int get factsViewedToday => _todaySession?.factsViewed ?? 0;
  int get factsRemainingToday => 10 - factsViewedToday;
  bool get isLoading => _isLoading;
  List<DailyFact> get bookmarkedFacts => _bookmarkedFacts;
  bool get hasMoreFacts => _currentFactIndex < _todaysFacts.length - 1;

  void setUserProfile(UserProfile? profile) {
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> loadTodaysFacts() async {
    if (_userProfile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _loadSession();
      await _loadBookmarkedFacts();

      final prefs = await SharedPreferences.getInstance();
      final cachedFactsJson = prefs.getString('daily_facts_cache');
      final cacheDate = prefs.getString('daily_facts_cache_date');
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (cachedFactsJson != null && cacheDate == today) {
        final List<dynamic> jsonList = jsonDecode(cachedFactsJson);
        _todaysFacts = jsonList.map((json) => DailyFact.fromJson(json)).toList();
        print('✅ Loaded ${_todaysFacts.length} trivia from cache');
      } else {
        print('💡 Fetching fresh trivia from API...');
        _todaysFacts = await _service.generateDailyFacts(_userProfile!, 10);

        await prefs.setString(
          'daily_facts_cache',
          jsonEncode(_todaysFacts.map((f) => f.toJson()).toList()),
        );
        await prefs.setString('daily_facts_cache_date', today);
        print('✅ Fetched and cached ${_todaysFacts.length} trivia');
      }

      _currentFactIndex = _todaySession?.factsViewed ?? 0;
    } catch (e) {
      print('❌ Error loading trivia: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void nextFact() {
    if (_currentFactIndex < _todaysFacts.length - 1) {
      _currentFactIndex++;
      _updateSession();
      notifyListeners();
    }
  }

  void previousFact() {
    if (_currentFactIndex > 0) {
      _currentFactIndex--;
      notifyListeners();
    }
  }

  Future<void> toggleBookmark(DailyFact fact) async {
    final index = _todaysFacts.indexWhere((f) => f.id == fact.id);
    if (index != -1) {
      _todaysFacts[index] = fact.copyWith(isBookmarked: !fact.isBookmarked);

      if (_todaysFacts[index].isBookmarked) {
        _bookmarkedFacts.add(_todaysFacts[index]);
      } else {
        _bookmarkedFacts.removeWhere((f) => f.id == fact.id);
      }

      await _saveBookmarkedFacts();
      notifyListeners();
    }
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString('daily_fact_session');
      final today = DateTime.now().toIso8601String().split('T');

      if (sessionJson != null) {
        final session = DailyFactSession.fromJson(jsonDecode(sessionJson));
        final sessionDate = session.date.toIso8601String().split('T');

        if (sessionDate == today) {
          _todaySession = session;
        } else {
          _todaySession = DailyFactSession(
            date: DateTime.now(),
            factsViewed: 0,
            bookmarkedFactIds: [],
          );
          await _saveSession();
        }
      } else {
        _todaySession = DailyFactSession(
          date: DateTime.now(),
          factsViewed: 0,
          bookmarkedFactIds: [],
        );
        await _saveSession();
      }
    } catch (e) {
      print('Error loading session: $e');
      _todaySession = DailyFactSession(
        date: DateTime.now(),
        factsViewed: 0,
        bookmarkedFactIds: [],
      );
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'daily_fact_session',
        jsonEncode(_todaySession!.toJson()),
      );
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  Future<void> _updateSession() async {
    if (_todaySession != null) {
      _todaySession = DailyFactSession(
        date: _todaySession!.date,
        factsViewed: _currentFactIndex + 1,
        bookmarkedFactIds: _todaySession!.bookmarkedFactIds,
      );
      await _saveSession();
    }
  }

  Future<void> _loadBookmarkedFacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList('bookmarked_facts') ?? [];
      _bookmarkedFacts = bookmarksJson
          .map((json) => DailyFact.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading bookmarks: $e');
    }
  }

  Future<void> _saveBookmarkedFacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = _bookmarkedFacts
          .map((fact) => jsonEncode(fact.toJson()))
          .toList();
      await prefs.setStringList('bookmarked_facts', bookmarksJson);
    } catch (e) {
      print('Error saving bookmarks: $e');
    }
  }

  void reset() {
    _todaysFacts = [];
    _currentFactIndex = 0;
    _todaySession = null;
    notifyListeners();
  }

  void setCurrentFactIndex(int idx) {
    _currentFactIndex = idx;
    _updateSession(); // This exists in your provider
    notifyListeners();
  }

}
