import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../services/perplexity_service.dart';
import '../theme/app_theme.dart';

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
  List<String> _suggestions = [
    // Generic fallback first (fast display); will update after API fetch!
    'Best investment for my age?',
    'How to save tax?',
    'Emergency fund calculation',
    'Explain SIP in 30 seconds'
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start API fetch in the background, no loader shown
    _maybeLoadSuggestions();
  }

  void _maybeLoadSuggestions() async {
    final chatProvider = context.read<ChatProvider>();
    final profile = chatProvider.userProfile;
    if (profile != null) {
      try {
        final apiSuggestions = await PerplexityService().generateQuickSuggestions(profile);
        if (mounted) {
          setState(() {
            _suggestions = apiSuggestions;
          });
        }
      } catch (e) {
        // Ignore, fallback suggestions already shown.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  constraints: const BoxConstraints(maxWidth: 180), // prevent overflow on wide texts
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    suggestion,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,   // White text for best contrast
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
