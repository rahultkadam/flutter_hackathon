import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;

  TextToSpeechService._internal() {
    _flutterTts.setCompletionHandler(() {
      if (_onComplete != null) _onComplete!();
      _isPlaying = false;
    });

    _flutterTts.setCancelHandler(() {
      if (_onStop != null) _onStop!();
      _isPlaying = false;
    });
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isPlaying = false;

  VoidCallback? _onComplete;
  VoidCallback? _onStop;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-IN');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  // FIX #6: Remove emojis before speaking
  String _removeEmojis(String text) {
    return text.replaceAll(
      RegExp(
        r'[\u{1F600}-\u{1F64F}]|' // Emoticons
        r'[\u{1F300}-\u{1F5FF}]|' // Symbols & Pictographs
        r'[\u{1F680}-\u{1F6FF}]|' // Transport & Map
        r'[\u{1F700}-\u{1F77F}]|' // Alchemical
        r'[\u{1F780}-\u{1F7FF}]|' // Geometric Shapes
        r'[\u{1F800}-\u{1F8FF}]|' // Supplemental Arrows
        r'[\u{1F900}-\u{1F9FF}]|' // Supplemental Symbols
        r'[\u{1FA00}-\u{1FA6F}]|' // Chess Symbols
        r'[\u{1FA70}-\u{1FAFF}]|' // Symbols Extended-A
        r'[\u{2600}-\u{26FF}]|'   // Miscellaneous Symbols
        r'[\u{2700}-\u{27BF}]',   // Dingbats
        unicode: true,
      ),
      '',
    ).trim();
  }

  Future<void> speak(String text, {VoidCallback? onComplete, VoidCallback? onStop}) async {
    await initialize();

    if (_isPlaying) {
      await stop();
    }

    _onComplete = onComplete;
    _onStop = onStop;

    // FIX #6: Clean text before speaking
    final cleanText = _removeEmojis(text);
    await _flutterTts.speak(cleanText);
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;
}
