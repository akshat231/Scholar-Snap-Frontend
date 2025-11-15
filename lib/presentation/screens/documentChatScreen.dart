import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/themeProvider.dart';
import '../../providers/documentProvider.dart';

class ChatScreen extends StatefulWidget {
  final String documentTitle;
  final String documentId;

  const ChatScreen({
    super.key,
    required this.documentTitle,
    required this.documentId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() async {
    final userMessage = _controller.text.trim();
    if (userMessage.isEmpty) return;

    final provider = Provider.of<DocumentsProvider>(context, listen: false);
    _controller.clear();

    await provider.fetchChatResponse(
      docId: widget.documentId,
      userMessage: userMessage,
    );

    // Scroll to bottom after response
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final provider = Provider.of<DocumentsProvider>(context);
    final messages = provider.getChatHistory(widget.documentId);
    final isLoading = provider.isChatLoading(widget.documentId);

    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final inputBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.grey[100];
    final userBubbleColor = isDark ? Colors.blue[400] : Colors.blue[200];
    final assistantBubbleColor = isDark ? Colors.grey[800] : Colors.grey[300];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: isLoading ? messages.length + 1 : messages.length,
              itemBuilder: (context, index) {
                if (index >= messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: assistantBubbleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final msg = messages[index];
                final isUser = msg['isUser'] as bool;
                final text = msg['text'] as String;

                final alignment = isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start;
                final bubbleColor =
                    isUser ? userBubbleColor : assistantBubbleColor;
                final textColor = isUser ? Colors.white : Colors.black87;

                return Column(
                  crossAxisAlignment: alignment,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(color: textColor),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            color: inputBgColor,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask a question about the PDF...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      filled: true,
                      fillColor:
                          isDark ? const Color(0xFF2A2A2A) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send,
                      color: Theme.of(context).primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
