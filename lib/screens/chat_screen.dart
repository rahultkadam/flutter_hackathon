import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/quick_suggestions.dart';
import '../widgets/response_actions.dart';
import '../widgets/chat_history_panel.dart';
import '../services/text_to_speech_service.dart';
import '../services/speech_to_text_service.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late SpeechToTextService _speechToTextService;
  late TextToSpeechService _textToSpeechService;
  bool _isMicActive = false;
  String _micButtonLabel = 'Tap to speak';

  @override
  void initState() {
    super.initState();
    _speechToTextService = SpeechToTextService();
    _textToSpeechService = TextToSpeechService();
    _initializeSpeechToText();
  }

  Future<void> _initializeSpeechToText() async {
    final initialized = await _speechToTextService.initialize();
    if (!initialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _startListening() async {
    if (!_isMicActive) {
      try {
        setState(() {
          _isMicActive = true;
          _micButtonLabel = 'Listening...';
        });

        // Start listening - will continue until stopped
        await _speechToTextService.startListening();
      } catch (e) {
        print('Error starting: $e');
        setState(() {
          _isMicActive = false;
          _micButtonLabel = 'Hold to speak';
        });
      }
    }
  }

  // CHANGE 1: In _startListening() - DON'T auto-send
  Future<void> _stopListening() async {
    if (!_isMicActive) return;

    try {
      await _speechToTextService.stopListening();
      final recognizedWords = _speechToTextService.lastWords;

      setState(() {
        _isMicActive = false;
        _micButtonLabel = 'Hold to speak';
      });

      if (recognizedWords.isNotEmpty) {
        // Write to message controller - DON'T auto-send
        _messageController.text = recognizedWords;

        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Voice captured. Review and tap Send'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error stopping: $e');
      setState(() {
        _isMicActive = false;
        _micButtonLabel = 'Hold to speak';
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatProvider>().sendMessage(message);
      _messageController.clear();

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _playResponse(String text) async {
    await _textToSpeechService.speak(text);
  }

  void _showProfileDialog() {
    final profile = context.read<ChatProvider>().userProfile;
    if (profile != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Your Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileItem('Age', '${profile.age} years'),
              _buildProfileItem('Gender', profile.gender),
              _buildProfileItem('Occupation', profile.occupation),
              _buildProfileItem('Income', profile.incomeRange),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 Money Buddy'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showProfileDialog,
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatHistoryScreen(
                    allMessages: context.read<ChatProvider>().messages,
                  ),
                ),
              );
            },
            tooltip: 'History',
          ),
        ],
      ),
      drawer: ChatHistoryPanel(
        favoriteMessages: context.watch<ChatProvider>().favoriteMessages,
        onViewAllHistory: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatHistoryScreen(
                allMessages: context.read<ChatProvider>().messages,
              ),
            ),
          );
        },
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Column(
            children: [
              // Quick suggestions at top
              if (chatProvider.messages.isEmpty)
                QuickSuggestions(
                  onSuggestionTap: (query) {
                    _messageController.text = query;
                    _sendMessage();
                  },
                ),

              // Messages list
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildWelcomeMessage()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatProvider.messages.length +
                            (chatProvider.isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (chatProvider.isLoading &&
                              index == chatProvider.messages.length) {
                            return const TypingIndicator();
                          }

                          final message = chatProvider.messages[index];
                          return Column(
                            children: [
                              ChatBubble(message: message),
                              if (!message.isUser)
                                ResponseActions(
                                  responseText: message.content,
                                  isFavorite: message.isFavorite,
                                  onBookmark: () {
                                    chatProvider.toggleFavorite(message);
                                  },
                                  onSuggestFollowUp: () {
                                    if (message.suggestedFollowUps != null &&
                                        message.suggestedFollowUps!.isNotEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                              'Suggested Follow-ups'),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: message.suggestedFollowUps!
                                                .map(
                                                  (question) =>
                                                      GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _messageController.text =
                                                          question;
                                                      _sendMessage();
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Container(
                                                        width:
                                                            double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .green,
                                                          border: Border.all(
                                                            color: Colors
                                                                .green!,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        child: Text(
                                                          '• $question',
                                                          style: const TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Close'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  },
                                ),
                            ],
                          );
                        },
                      ),
              ),

              // Input area
              _buildInputArea(chatProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '👋 Hi! I\'m Money Buddy',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your Personal Financial Advisor',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            const Text(
              'Ask me about:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildWelcomeItem('💡 SIP and mutual funds'),
            _buildWelcomeItem('📊 Investment strategies'),
            _buildWelcomeItem('💰 Tax-saving options'),
            _buildWelcomeItem('🏦 Banking products'),
            _buildWelcomeItem('🎯 Personalized advice'),
            const SizedBox(height: 32),
            const Text(
              'Use the buttons below to type or speak! 👇',
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  // Update the input button to use GestureDetector with onLongPress
  Widget _buildInputArea(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Text input and send button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                  enabled: !chatProvider.isLoading,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: chatProvider.isLoading ? null : _sendMessage,
                backgroundColor: Colors.green,
                child: const Icon(Icons.send, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Voice button with HOLD-TO-SPEAK
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPressStart: (_) => _startListening(),
                onLongPressEnd: (_) => _stopListening(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isMicActive ? Colors.red : Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isMicActive
                            ? Colors.red.withOpacity(0.4)
                            : Colors.blue.withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isMicActive ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _micButtonLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isMicActive ? Colors.red : Colors.blue,
                      ),
                    ),
                    const Text(
                      'Hold button to speak',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.clear_all),
                color: Colors.orange,
                onPressed: () {
                  chatProvider.clearChat();
                },
                tooltip: 'Clear chat',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _textToSpeechService.stop();
    _speechToTextService.cancelListening();
    super.dispose();
  }
}
