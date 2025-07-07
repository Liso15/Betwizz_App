import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/channels/notifiers/chat_providers.dart';
import 'package:betwizz_app/features/channels/models/chat_message_model.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

class CommunityChatView extends ConsumerStatefulWidget {
  final String channelId; // Assuming channelId is passed to this view

  const CommunityChatView({super.key, required this.channelId});

  @override
  ConsumerState<CommunityChatView> createState() => _CommunityChatViewState();
}

class _CommunityChatViewState extends ConsumerState<CommunityChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatMessagesProvider(widget.channelId).notifier).postMessage(text);
      _messageController.clear();
      // Scroll to bottom after sending a message
      WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void _scrollToBottom() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && _scrollController.position.hasContentDimensions) {
           _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
  }


  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(chatMessagesProvider(widget.channelId));

    // Listen to message state changes to scroll to bottom when new messages arrive
    ref.listen(chatMessagesProvider(widget.channelId), (previous, next) {
      if (next is AsyncData<List<ChatMessageModel>>) {
        // If previous was also data and new data has more messages, it's likely a new message.
        final prevDataLength = previous is AsyncData<List<ChatMessageModel>> ? previous.value.length : 0;
        if (next.value.length > prevDataLength) {
           _scrollToBottom();
        }
      }
    });


    return Column(
      children: [
        Expanded(
          child: messagesState.when(
            data: (messages) {
              if (messages.isEmpty) {
                return const Center(child: Text('No messages yet. Start the conversation!'));
              }
              // Initial scroll to bottom when messages are first loaded
              WidgetsBinding.instance.addPostFrameCallback((_) {
                 if (_scrollController.hasClients && _scrollController.position.hasContentDimensions) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                 }
              });
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  // Placeholder for current user ID - replace with actual auth user ID
                  final bool isCurrentUser = message.senderId == "currentUser_placeholder_ID";
                  return _buildMessageBubble(context, message, isCurrentUser);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error loading messages: $error'),
            ),
          ),
        ),
        _buildMessageInputField(),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessageModel message, bool isCurrentUser) {
    final alignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isCurrentUser ? Theme.of(context).primaryColor.withAlpha(200) : Colors.grey[300];
    final textColor = isCurrentUser ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible( // Ensures text bubble does not overflow
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12.0),
                      topRight: const Radius.circular(12.0),
                      bottomLeft: isCurrentUser ? const Radius.circular(12.0) : const Radius.circular(0),
                      bottomRight: isCurrentUser ? const Radius.circular(0) : const Radius.circular(12.0),
                    ),
                  ),
                  child: Column(
                     crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      if (!isCurrentUser) // Show sender name for other users
                        Text(
                          message.senderName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: textColor.withOpacity(0.8)
                          ),
                        ),
                      if (!isCurrentUser) const SizedBox(height: 2),
                      Text(message.text, style: TextStyle(color: textColor)),
                    ],
                  )
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.0, left: 8.0, right: 8.0),
            child: Text(
              DateFormat('hh:mm a').format(message.timestamp), // HH:mm for 24-hour
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 4.0,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none, // Or OutlineInputBorder()
                contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
              ),
              onSubmitted: (_) => _sendMessage(),
              textInputAction: TextInputAction.send,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
