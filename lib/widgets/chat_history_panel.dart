import 'package:flutter/material.dart';
import '../models/chat_features.dart';

class ChatHistoryPanel extends StatelessWidget {
  final List<ChatMessage> favoriteMessages;
  final VoidCallback onViewAllHistory;

  const ChatHistoryPanel({
    Key? key,
    required this.favoriteMessages,
    required this.onViewAllHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '📚 Favorites & History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your saved responses',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (favoriteMessages.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    '📌',
                    style: TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bookmark responses to see them here',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          else
            ...favoriteMessages.map((message) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Card(
                  child: ListTile(
                    title: Text(
                      message.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      'Saved: ${message.timestamp.toString().split('.')}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    trailing: const Icon(Icons.favorite, color: Colors.red, size: 16),
                    onTap: () {
                      // Copy to clipboard or perform action
                    },
                  ),
                ),
              );
            }).toList(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton.icon(
              onPressed: onViewAllHistory,
              icon: const Icon(Icons.history),
              label: const Text('View All History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
