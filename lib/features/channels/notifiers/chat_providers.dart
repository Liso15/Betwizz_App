import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/channels/models/chat_message_model.dart';
import 'package:betwizz_app/features/channels/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart'; // For generating unique message IDs

// State for chat messages: loading, data, or error
typedef ChatMessagesState = AsyncValue<List<ChatMessageModel>>;

// Notifier for managing chat messages for a specific channel
class ChatMessagesNotifier extends StateNotifier<ChatMessagesState> {
  final ChatRepository _chatRepository;
  final String _channelId;
  // Placeholder for current user - in a real app, get this from an auth provider
  final String _currentUserId = "currentUser_placeholder_ID";
  final String _currentUserName = "Me";

  ChatMessagesNotifier(this._chatRepository, this._channelId) : super(const AsyncValue.loading()) {
    _fetchInitialMessages();
  }

  Future<void> _fetchInitialMessages() async {
    try {
      final messages = await _chatRepository.getChatMessages(_channelId);
      if (mounted) { // Check if notifier is still mounted before updating state
        state = AsyncValue.data(messages);
      }
    } catch (e, s) {
      if (mounted) {
        state = AsyncValue.error(e, s);
      }
    }
  }

  Future<void> postMessage(String text) async {
    if (text.trim().isEmpty) return;

    final newMessage = ChatMessageModel(
      id: const Uuid().v4(), // Generate a unique ID
      senderId: _currentUserId,
      senderName: _currentUserName,
      text: text.trim(),
      timestamp: DateTime.now(),
    );

    // Optimistically update the UI
    final previousState = state.asData?.value ?? [];
    state = AsyncValue.data([...previousState, newMessage]);

    try {
      await _chatRepository.postChatMessage(_channelId, newMessage);
      // If backend confirms, state is already updated.
      // If backend fails, we might want to revert the optimistic update or show an error.
      // For this mock, we assume success from the repository.
      // If repository throws, the catch block below handles it.
    } catch (e, s) {
      // Revert optimistic update on error and set error state
      if (mounted) {
        state = AsyncValue.data(previousState); // Revert to previous messages
         // Optionally, also convey the error to the user, e.g., by setting a separate error state
        // or by re-throwing and letting the UI handle it via provider's error state.
        // For now, just reverting and letting the main state reflect last known good.
        // A more robust solution might involve a specific error state for posting.
        print("Error posting message: $e"); // Log error
        // state = AsyncValue.error("Failed to post message: $e", s); // This would replace the whole list with error
      }
    }
  }

  // Optional: Method to refresh messages
  Future<void> refreshMessages() async {
    state = const AsyncValue.loading();
    await _fetchInitialMessages();
  }
}

// Provider for ChatMessagesNotifier
// Using family to pass the channelId to the notifier
final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, ChatMessagesState, String>(
  (ref, channelId) {
    final chatRepository = ref.watch(chatRepositoryProvider);
    return ChatMessagesNotifier(chatRepository, channelId);
  },
);
