import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../services/perplexity_service.dart';

class QuickSuggestions extends StatefulWidget {
  final Function(String) onSuggestionTap;

  const QuickSuggestions({
    Key? key,
    required this.onSuggestionTap,
  }) : super(key: key);

  @override
  State<QuickSuggestions> createState() => _QuickSuggestionsState();
}

class _QuickSuggestionsState extends State<QuickSuggestions> {
  List<String> _suggestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final chatProvider = context.read<ChatProvider>();
    final profile = chatProvider.userProfile;

    if (profile != null) {
      try {
        final suggestions = await PerplexityService().generateQuickSuggestions(profile);
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _suggestions = [
            'Best investment for my age?',
            'How to save tax?',
            'Emergency fund calculation',
            'Explain SIP in 30 seconds',
          ];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _suggestions = [
          'Best investment for my age?',
          'How to save tax?',
          'Emergency fund calculation',
          'Explain SIP in 30 seconds',
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 Ask me about...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => widget.onSuggestionTap(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    border: Border.all(color: Colors.green!),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
