import 'package:betwizz_app/features/channels/models/chat_message_model.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'dart:math'; // For Random

// Abstract class defining the contract for chat related operations
abstract class ChatRepository {
  Future<List<ChatMessageModel>> getChatMessages(String channelId);
  Future<void> postChatMessage(String channelId, ChatMessageModel message);
  // Stream<List<ChatMessageModel>> getChatMessagesStream(String channelId); // For real-time updates
}

class MockChatRepository implements ChatRepository {
  // In-memory store for mock messages, per channel
  final Map<String, List<ChatMessageModel>> _mockMessages = {};
  final Random _random = Random();

  // Helper to initialize some mock messages for a channel if not already present
  void _ensureChannelMessages(String channelId) {
    if (!_mockMessages.containsKey(channelId)) {
      _mockMessages[channelId] = [
        ChatMessageModel(
          id: 'msg_001_${channelId}_${_random.nextInt(1000)}',
          senderId: 'user_alpha',
          senderName: 'AlphaUser',
          text: 'Welcome to the $channelId chat!',
          timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ChatMessageModel(
          id: 'msg_002_${channelId}_${_random.nextInt(1000)}',
          senderId: 'user_beta',
          senderName: 'BetaMax',
          text: 'Glad to be here. Any hot tips today?',
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        ChatMessageModel(
          id: 'msg_003_${channelId}_${_random.nextInt(1000)}',
          senderId: 'user_alpha',
          senderName: 'AlphaUser',
          text: 'Just watching the odds for now. Keep an eye on the late games.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
      ];
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatMessages(String channelId) async {
    _ensureChannelMessages(channelId);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    debugPrint("MockChatRepository: Fetched ${_mockMessages[channelId]!.length} messages for channel $channelId");
    return List<ChatMessageModel>.from(_mockMessages[channelId]!); // Return a copy
  }

  @override
  Future<void> postChatMessage(String channelId, ChatMessageModel message) async {
    _ensureChannelMessages(channelId);
    // Simulate network delay for posting
    await Future.delayed(const Duration(milliseconds: 200));

    // Add the new message to our in-memory list for this channel
    _mockMessages[channelId]!.add(message);

    debugPrint('--- Mock Chat Message Posted ---');
    debugPrint('Channel ID: $channelId');
    debugPrint('Message ID: ${message.id}');
    debugPrint('Sender: ${message.senderName} (${message.senderId})');
    debugPrint('Text: ${message.text}');
    debugPrint('Timestamp: ${message.timestamp}');
    debugPrint('--- End Mock Message Post ---');

    // In a real implementation, this would send the message to a backend (e.g., Firestore, WebSocket server)
  }

  // Example for real-time stream (not used by current plan's FutureProvider but good for reference)
  // Stream<List<ChatMessageModel>> getChatMessagesStream(String channelId) {
  //   _ensureChannelMessages(channelId);
  //   // This is a simplified stream. A real Firestore stream would be more direct.
  //   // For a mock, you might need a StreamController that you add to when postChatMessage is called.
  //   return Stream.periodic(const Duration(seconds: 5), (_) {
  //     return List<ChatMessageModel>.from(_mockMessages[channelId]!);
  //   }).asBroadcastStream(); // Ensure it's a broadcast stream if listened to multiple times
  // }
}

// --- Riverpod Provider ---
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return MockChatRepository();
});
