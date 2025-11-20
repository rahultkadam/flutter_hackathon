import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/quick_suggestions.dart';
import '../widgets/response_actions.dart';
import '../widgets/chat_history_panel.dart';
import '../widgets/disclaimer_icon.dart';
import '../widgets/initial_disclaimer_dialog.dart';
import '../services/text_to_speech_service.dart';
import '../services/speech_to_text_service.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import '../utils/disclaimer_helper.dart';
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
  String _micButtonLabel = 'Hold to speak';

  @override
  void initState() {
    super.initState();
    _speechToTextService = SpeechToTextService();
    _textToSpeechService = TextToSpeechService();
    _initializeSpeechToText();
    _checkAndShowDisclaimer();
  }

  Future<void> _checkAndShowDisclaimer() async {
    // Check if disclaimer has been shown before
    final hasShown = await DisclaimerHelper.hasShownDisclaimer();
    
    if (!hasShown && mounted) {
      // Show disclaimer after a short delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (mounted) {
          final accepted = await InitialDisclaimerDialog.show(context);
          
          // If user declined, navigate back
          if (!accepted && mounted) {
            Navigator.of(context).pop();
          }
        }
      });
    }
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

  // FIX #1: Hold to speak, release to stop - DON'T auto-send
  void _startListening() async {
    if (!_isMicActive) {
      try {
        setState(() {
          _isMicActive = true;
          _micButtonLabel = 'Listening...';
        });
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
        // FIX #1: Write to message controller - DON'T auto-send
        _messageController.text = recognizedWords;

        // Show feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Voice captured. Review and tap Send'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.primaryPurple,
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
      setState(() {}); // Trigger rebuild to update send/mic button

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

  // In chat_screen.dart, update the _showProfileDialog method:
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
              // FIX #5: Show full name
              _buildProfileItem('Name', profile.fullName),
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
        title: const Text('Chat With 💰 Money Buddy'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showProfileDialog,
            tooltip: 'Profile',
          ),
          // FIX #2: Clear chat moved to app bar
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.messages.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Chat?'),
                      content: const Text('This will delete all messages.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            chatProvider.clearChat();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Clear chat',
              );
            },
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
              if (chatProvider.messages.isEmpty)
                QuickSuggestions(
                  onSuggestionTap: (query) {
                    _messageController.text = query;
                    _sendMessage();
                  },
                ),
              Expanded(
                child: chatProvider.messages.isEmpty
                    ? _buildWelcomeMessage()
                    : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveHelper.getPadding(context, mobile: 16, desktop: 40),
                    vertical: ResponsiveHelper.getPadding(context, mobile: 16, desktop: 12),
                  ),
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
                                    title: const Text('Suggested Follow-ups'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: message.suggestedFollowUps!
                                          .map(
                                            (question) => GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                            _messageController.text =
                                                question;
                                            _sendMessage();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryPurple,
                                                border: Border.all(
                                                  color: AppColors.primaryPurple,
                                                ),
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                              padding:
                                              const EdgeInsets.all(8),
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
              _buildInputArea(chatProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveHelper.getPadding(context, mobile: 20, desktop: 16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '👋 Hi! I\'m Money Buddy',
                style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, mobile: 28, desktop: 24), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 16, desktop: 12)),
              Text(
                'Your Personal Financial Advisor',
                style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, mobile: 16, desktop: 14), color: Colors.grey),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 32, desktop: 24)),
              Text(
                'Ask me about:',
                style: TextStyle(fontSize: ResponsiveHelper.getFontSize(context, mobile: 16, desktop: 14), fontWeight: FontWeight.w500),
              ),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 16, desktop: 12)),
              _buildWelcomeItem('💡 SIP and mutual funds'),
              _buildWelcomeItem('📊 Investment strategies'),
              _buildWelcomeItem('💰 Tax-saving options'),
              _buildWelcomeItem('🏦 Banking products'),
              _buildWelcomeItem('🎯 Personalized advice'),
              SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 32, desktop: 24)),
              Text(
                'Use the button below to type or hold mic to speak! 👇',
                style: TextStyle(fontSize: isDesktop ? 12 : 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeItem(String text) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: isDesktop ? 13 : 14),
      ),
    );
  }

  // FIX #1: WhatsApp-style send/mic button with floating design
  Widget _buildInputArea(ChatProvider chatProvider) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final horizontalPadding = ResponsiveHelper.getPadding(context, mobile: 12, desktop: 40);
    
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ResponsiveHelper.getMaxContentWidth(context),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: ResponsiveHelper.getPadding(context, mobile: 12, desktop: 10),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getPadding(context, mobile: 16, desktop: 14),
            vertical: ResponsiveHelper.getPadding(context, mobile: 12, desktop: 10),
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 2),
                blurRadius: 12,
                spreadRadius: 1,
                color: Colors.black.withOpacity(0.15),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Disclaimer icon (low-opacity warning icon)
              DisclaimerIcon(
                useSnackbar: !isDesktop, // Use modal on desktop, snackbar on mobile
                size: isDesktop ? 16 : 18,
                opacity: 0.35,
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context, mobile: 4, desktop: 6)),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Ask me anything...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                  minLines: 1,
                  enabled: !chatProvider.isLoading,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  onChanged: (_) => setState(() {}), // Rebuild to show send/mic button
                ),
              ),
              SizedBox(width: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 10)),
              // Combined Send/Mic Button
              ValueListenableBuilder(
                valueListenable: _messageController,
                builder: (context, value, child) {
                  final hasText = value.text.trim().isNotEmpty;

                  if (hasText) {
                    // Show send button
                    return FloatingActionButton(
                      mini: true,
                      onPressed: chatProvider.isLoading ? null : _sendMessage,
                      backgroundColor: AppColors.primaryPurple,
                      child: Icon(Icons.send, size: isDesktop ? 18 : 20, color: Colors.white),
                    );
                  } else {
                    // Show mic button (hold to speak)
                    return GestureDetector(
                      onLongPressStart: (_) => _startListening(),
                      onLongPressEnd: (_) => _stopListening(),
                      child: Container(
                        width: isDesktop ? 44 : 48,
                        height: isDesktop ? 44 : 48,
                        decoration: BoxDecoration(
                          color: _isMicActive ? Colors.red : Colors.blue,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _isMicActive
                                  ? Colors.red.withOpacity(0.4)
                                  : Colors.blue.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isMicActive ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: isDesktop ? 20 : 24,
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
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
