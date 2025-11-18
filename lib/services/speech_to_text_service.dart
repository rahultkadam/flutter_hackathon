import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  
  factory SpeechToTextService() {
    return _instance;
  }
  
  SpeechToTextService._internal();
  
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isInitialized = false;
  
  bool get isListening => _speechToText.isListening;
  bool get isInitialized => _isInitialized;
  String get lastWords => _speechToText.lastRecognizedWords;
  
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (error) => print('Error: $error'),
        onStatus: (status) => print('Status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      print('STT Initialization error: $e');
      return false;
    }
  }
  
  Future<void> startListening() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (!_speechToText.isListening) {
      try {
        await _speechToText.listen(
          localeId: 'en_IN',
          onResult: (result) {
            // Result handled via callback
          },
        );
      } catch (e) {
        print('STT Start Error: $e');
      }
    }
  }
  
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      print('STT Stop Error: $e');
    }
  }
  
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
    } catch (e) {
      print('STT Cancel Error: $e');
    }
  }
}
