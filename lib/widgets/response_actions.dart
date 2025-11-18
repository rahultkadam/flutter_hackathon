import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/text_to_speech_service.dart';

class ResponseActions extends StatefulWidget {
  final String responseText;
  final VoidCallback onBookmark;
  final VoidCallback onSuggestFollowUp;
  final bool isFavorite;

  const ResponseActions({
    Key? key,
    required this.responseText,
    required this.onBookmark,
    required this.onSuggestFollowUp,
    required this.isFavorite,
  }) : super(key: key);

  @override
  State<ResponseActions> createState() => _ResponseActionsState();
}

class _ResponseActionsState extends State<ResponseActions> {
  late bool _isFavorite;
  bool _isPlaying = false;
  final _tts = TextToSpeechService();

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _shareAsImage() async {
    try {
      await Share.share(
        '💰 Money Buddy Response:\n\n${widget.responseText}\n\n#MoneyBuddy #FinancialLiteracy',
        subject: 'Money Buddy Financial Advice',
      );
    } catch (e) {
      print('Share error: $e');
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onBookmark();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? '❤️ Added to favorites' : '💔 Removed from favorites',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await _tts.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _tts.speak(widget.responseText,
          onComplete: () {
            if (mounted) setState(() => _isPlaying = false);
          },
          onStop: () {
            if (mounted) setState(() => _isPlaying = false);
          }
      );
      setState(() {
        _isPlaying = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
            label: 'Favorite',
            color: _isFavorite ? Colors.red : Colors.grey,
            onTap: _toggleFavorite,
          ),
          _ActionButton(
            icon: Icons.share,
            label: 'Share',
            color: Colors.blue,
            onTap: _shareAsImage,
          ),
          _ActionButton(
            icon: Icons.help_outline,
            label: 'Follow-up',
            color: Colors.orange,
            onTap: widget.onSuggestFollowUp,
          ),
          _ActionButton(
            icon: _isPlaying ? Icons.stop : Icons.volume_up,
            label: _isPlaying ? 'Stop' : 'Listen',
            color: Colors.purple,
            onTap: _toggleAudio,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
}
