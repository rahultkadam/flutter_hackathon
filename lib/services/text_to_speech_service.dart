import 'dart:ui';

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
    await _flutterTts.setLanguage('en-IN'); // or 'en-US'
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _isInitialized = true;
  }

  Future<void> speak(String text, {VoidCallback? onComplete, VoidCallback? onStop}) async {
    await initialize();
    if (_isPlaying) {
      await stop();
    }
    _onComplete = onComplete;
    _onStop = onStop;
    await _flutterTts.speak(text);
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
  }

  bool get isPlaying => _isPlaying;
}
