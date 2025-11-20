import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/user_profile.dart';
import '../models/chat_features.dart';
import '../models/disclaimer_config.dart';
import '../services/perplexity_service.dart';
import '../utils/disclaimer_helper.dart';

class ChatProvider extends ChangeNotifier {
  final PerplexityService _perplexityService = PerplexityService();
  final List<ChatMessage> _messages = [];
  final List<ChatMessage> _favoriteMessages = [];
  bool _isLoading = false;
  bool _isListening = false;
  UserProfile? _userProfile;

  List<ChatMessage> get messages => _messages;
  List<ChatMessage> get favoriteMessages => _favoriteMessages;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  UserProfile? get userProfile => _userProfile;

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _userProfile == null) return;

    const uuid = Uuid();

    // Add user message
    _messages.add(ChatMessage(
      id: uuid.v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    
    // Check if this is a high-risk query and add contextual warning
    final isHighRisk = DisclaimerHelper.containsHighRiskQuery(content);
    if (isHighRisk) {
      // Add a non-intrusive warning message from the bot
      _messages.add(ChatMessage(
        id: uuid.v4(),
        content: DisclaimerConfig.contextualWarningMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
      
      // Small delay so the warning appears before the actual response
      await Future.delayed(const Duration(milliseconds: 300));
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Get AI response
      final response = await _perplexityService.getChatResponse(
        content,
        _userProfile!,
      );

      // --- NEW DYNAMIC FOLLOW-UP PARSING FROM API ---
      // Uses format: Response text ... \n\nFOLLOW_UP:\n- Q1?\n- Q2?
      List<String> followUps = [];
      String displayResponse = response;
      final followUpMarker = 'FOLLOW_UP:';
      if (response.contains(followUpMarker)) {
        final parts = response.split(followUpMarker);
        displayResponse = parts[0].trim();
        // Extract follow-up questions from lines after marker
        followUps = parts[1]
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.startsWith('-') || l.startsWith('•'))
            .map((l) => l.replaceFirst(RegExp(r'^[-•]'), '').trim())
            .where((l) => l.isNotEmpty)
            .toList();
      }

      // Add AI message with dynamic follow-ups from API
      _messages.add(ChatMessage(
        id: uuid.v4(),
        content: displayResponse,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFollowUps: followUps,
      ));
    } catch (e) {
      _messages.add(ChatMessage(
        id: uuid.v4(),
        content: 'Sorry, I encountered an error: ${e.toString()}. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void toggleFavorite(ChatMessage message) {
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      final updatedMessage = ChatMessage(
        id: message.id,
        content: message.content,
        isUser: message.isUser,
        timestamp: message.timestamp,
        isFavorite: !message.isFavorite,
        suggestedFollowUps: message.suggestedFollowUps,
      );

      _messages[index] = updatedMessage;

      if (updatedMessage.isFavorite && !message.isUser) {
        _favoriteMessages.add(updatedMessage);
      } else if (!updatedMessage.isFavorite) {
        _favoriteMessages.removeWhere((m) => m.id == message.id);
      }

      notifyListeners();
    }
  }

  void setListeningState(bool listening) {
    _isListening = listening;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  // FIX #4: Generate contextual follow-up questions
  List<String> _generateFollowUpSuggestions(String response) {
    final followUps = <String>[];
    final lowerResponse = response.toLowerCase();

    if (lowerResponse.contains('sip') || lowerResponse.contains('systematic')) {
      followUps.add('What is the minimum SIP amount to start?');
      followUps.add('Which mutual fund is best for SIP?');
    }

    if (lowerResponse.contains('tax') || lowerResponse.contains('deduction')) {
      followUps.add('Which tax-saving investments are best for my age?');
      followUps.add('How does Section 80C work?');
    }

    if (lowerResponse.contains('fund') || lowerResponse.contains('mutual')) {
      followUps.add('What\'s the historical performance of this fund?');
      followUps.add('How much risk is involved?');
    }

    if (lowerResponse.contains('age') || lowerResponse.contains('young') || lowerResponse.contains('old')) {
      followUps.add('What should be my investment allocation at this age?');
      followUps.add('How much emergency fund do I need?');
    }

    if (lowerResponse.contains('emergency')) {
      followUps.add('In which account should I keep the emergency fund?');
      followUps.add('How is the emergency fund different from savings?');
    }

    if (lowerResponse.contains('risk')) {
      followUps.add('How do I assess my risk tolerance?');
      followUps.add('What investments match my risk profile?');
    }

    if (lowerResponse.contains('retirement')) {
      followUps.add('When should I start retirement planning?');
      followUps.add('How much should I save for retirement?');
    }

    if (lowerResponse.contains('insurance')) {
      followUps.add('What\'s the difference between term and whole life insurance?');
      followUps.add('How much coverage do I need?');
    }

    // Default follow-ups if no keywords match
    if (followUps.isEmpty) {
      followUps.addAll([
        'Can you explain this in more detail?',
        'How does this apply to my situation?',
      ]);
    }

    return followUps.take(2).toList();
  }
}
