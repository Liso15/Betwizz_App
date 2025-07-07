import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/channels/models/chat_message_model.dart'; // Reusing ChatMessageModel
import 'package:uuid/uuid.dart';

const String _mfethuSenderId = 'mfethu_ai';
const String _mfethuSenderName = 'Mfethu';
// Placeholder for current user - in a real app, get this from an auth provider
const String _currentUserPlaceholderId = "currentUser_ID_Placeholder";
const String _currentUserPlaceholderName = "You";


class MfethuChatNotifier extends StateNotifier<List<ChatMessageModel>> {
  MfethuChatNotifier() : super([]) {
    _initializeChat();
  }

  void _initializeChat() {
    // Initial welcome message from Mfethu
    state = [
      ChatMessageModel(
        id: const Uuid().v4(),
        senderId: _mfethuSenderId,
        senderName: _mfethuSenderName,
        text: "Welcome to Mfethu Chat! How can I help you with your betting strategy today? (I'm a basic version for now!)",
        timestamp: DateTime.now(),
      ),
      // PRD 4.2: Mfethu basic Q&A (local NLP model)
      ChatMessageModel(
        id: const Uuid().v4(),
        senderId: _mfethuSenderId,
        senderName: _mfethuSenderName,
        text: "Remember, I can provide basic Q&A even offline (once fully implemented).",
        timestamp: DateTime.now().add(const Duration(milliseconds: 100)), // Ensure different timestamp
      ),
    ];
  }

  void addUserMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessageModel(
      id: const Uuid().v4(),
      senderId: _currentUserPlaceholderId, // Replace with actual user ID from auth
      senderName: _currentUserPlaceholderName, // Replace with actual user name from auth/profile
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    state = [...state, userMessage];
    _addMfethuResponse(userMessage.text);
  }

  void _addMfethuResponse(String userText) {
    // Simulate thinking delay
    Timer(const Duration(milliseconds: 750), () {
      String mfethuReplyText;
      final lowerUserText = userText.toLowerCase();

      // Simple rule-based responses
      if (lowerUserText.contains("hello") || lowerUserText.contains("hi")) {
        mfethuReplyText = "Hello there! How can I assist you today?";
      } else if (lowerUserText.contains("how are you")) {
        mfethuReplyText = "I'm doing well, ready to chat about bets!";
      } else if (lowerUserText.contains("bye")) {
        mfethuReplyText = "Goodbye! Feel free to return anytime.";
      } else if (lowerUserText.contains("thank you") || lowerUserText.contains("thanks")) {
        mfethuReplyText = "You're welcome!";
      } else if (lowerUserText.contains("odds") || lowerUserText.contains("betway") || lowerUserText.contains("hollywood")) {
        mfethuReplyText = "I can't provide live odds or access bookmakers yet, but I can discuss general strategy!";
      }
       else {
        mfethuReplyText = "I've received your message: \"$userText\". My responses are quite basic for now.";
      }

      final mfethuMessage = ChatMessageModel(
        id: const Uuid().v4(),
        senderId: _mfethuSenderId,
        senderName: _mfethuSenderName,
        text: mfethuReplyText,
        timestamp: DateTime.now(),
      );
      state = [...state, mfethuMessage];
    });
  }
}

// Provider for MfethuChatNotifier
final mfethuChatProvider = StateNotifierProvider<MfethuChatNotifier, List<ChatMessageModel>>((ref) {
  return MfethuChatNotifier();
});
