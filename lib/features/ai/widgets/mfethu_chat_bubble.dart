import 'package:flutter/material.dart';
import 'package:betwizz_app/features/channels/models/chat_message_model.dart'; // For ChatMessageModel
import 'package:intl/intl.dart'; // For date formatting

// Placeholder for the current user's ID - replace with actual auth logic
const String _currentUserPlaceholderId = "currentUser_ID_Placeholder";

class MfethuChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  // final bool isUser; // No longer needed if we use message.senderId

  const MfethuChatBubble({
    super.key,
    required this.message,
    // required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = message.senderId == _currentUserPlaceholderId;
    final alignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleAlignment = isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start;
    final color = isCurrentUser ? Theme.of(context).primaryColor.withAlpha(220) : Colors.grey[300];
    final textColor = isCurrentUser ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: bubbleAlignment,
            children: [
              Flexible( // Ensures text bubble does not overflow horizontally
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16.0),
                      topRight: const Radius.circular(16.0),
                      bottomLeft: isCurrentUser ? const Radius.circular(16.0) : const Radius.circular(4.0),
                      bottomRight: isCurrentUser ? const Radius.circular(4.0) : const Radius.circular(16.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Text within bubble always starts left
                    mainAxisSize: MainAxisSize.min, // Bubble wraps content
                    children: [
                      if (!isCurrentUser) // Show sender name for Mfethu's messages
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            message.senderName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                        ),
                      Text(
                        message.text,
                        style: TextStyle(color: textColor, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3.0, left: 12.0, right: 12.0),
            child: Text(
              DateFormat('hh:mm a').format(message.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
