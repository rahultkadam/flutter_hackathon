import 'package:flutter/material.dart';
import '../models/chat_features.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_helper.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 6),
      ),
      child: Row(
        mainAxisAlignment:
        message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: AppColors.primaryPurple,
              radius: isDesktop ? 16 : 20,
              child: Text('💰', style: TextStyle(fontSize: isDesktop ? 16 : 20)),
            ),
            SizedBox(width: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 10)),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 600 : double.infinity,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveHelper.getPadding(context, mobile: 16, desktop: 14),
                  vertical: ResponsiveHelper.getPadding(context, mobile: 12, desktop: 10),
                ),
                decoration: BoxDecoration(
                  color: message.isUser 
                      ? AppColors.primaryPurple 
                      : (Theme.of(context).brightness == Brightness.dark 
                          ? AppColors.primaryPurple.withOpacity(0.1)
                          : Colors.grey.shade100),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 16),
                  ),
                  border: message.isUser 
                      ? null 
                      : Border.all(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? AppColors.primaryPurple.withOpacity(0.3)
                              : Colors.grey.shade300,
                        ),
                ),
                child: _buildFormattedText(message.content, message.isUser, context),
              ),
            ),
          ),
          if (message.isUser) ...[
            SizedBox(width: ResponsiveHelper.getSpacing(context, mobile: 8, desktop: 10)),
            CircleAvatar(
              backgroundColor: Colors.grey,
              radius: isDesktop ? 16 : 20,
              child: Icon(Icons.person, size: isDesktop ? 16 : 20, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  // FIX #3 & #4: Remove references and format bold text
  Widget _buildFormattedText(String text, bool isUser, BuildContext context) {
    // FIX #3: Remove reference numbers like , ,
    String cleanedText = text.replaceAll(RegExp(r'\[\d+\]'), '');

    // Get appropriate text color based on user type and theme
    Color textColor = isUser 
        ? Colors.white 
        : (Theme.of(context).brightness == Brightness.dark 
            ? AppColors.white 
            : Colors.black87);

    // FIX #4: Parse **bold** text into TextSpans
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in boldPattern.allMatches(cleanedText)) {
      // Add text before the bold section
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: cleanedText.substring(lastIndex, match.start),
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            height: 1.5,
          ),
        ));
      }

      // Add bold text
      spans.add(TextSpan(
        text: match.group(1), // Text between **
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          height: 1.5,
        ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text after last bold section
    if (lastIndex < cleanedText.length) {
      spans.add(TextSpan(
        text: cleanedText.substring(lastIndex),
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          height: 1.5,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
