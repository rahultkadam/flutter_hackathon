import 'package:flutter/material.dart';
import '../models/chat_features.dart';

class ChatHistoryScreen extends StatefulWidget {
  final List<ChatMessage> allMessages;

  const ChatHistoryScreen({
    Key? key,
    required this.allMessages,
  }) : super(key: key);

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  late TextEditingController _searchController;
  late List<ChatMessage> _filteredMessages;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredMessages = widget.allMessages;
  }

  void _filterMessages(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMessages = widget.allMessages;
      } else {
        _filteredMessages = widget.allMessages
            .where((msg) =>
                msg.content.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMessages,
              decoration: InputDecoration(
                hintText: 'Search messages...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterMessages('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _filteredMessages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No messages found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = _filteredMessages[index];
                      return ChatHistoryTile(
                        message: message,
                        isUser: message.isUser,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ChatHistoryTile extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;

  const ChatHistoryTile({
    Key? key,
    required this.message,
    required this.isUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUser ? Colors.green : Colors.grey,
          child: Text(
            isUser ? '👤' : '🤖',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        title: Text(
          message.content,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        subtitle: Text(
          'Timestamp: ${message.timestamp.toString().split('.')}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: message.isFavorite
            ? const Icon(Icons.favorite, color: Colors.red, size: 18)
            : null,
        onTap: () {
          // Show full message dialog
          _showMessageDialog(context, message);
        },
      ),
    );
  }

  void _showMessageDialog(BuildContext context, ChatMessage message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUser ? 'Your Question' : 'Money Buddy Response'),
        content: SingleChildScrollView(
          child: Text(message.content),
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
