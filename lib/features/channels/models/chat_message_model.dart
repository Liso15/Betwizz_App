import 'package:flutter/foundation.dart' show immutable;

@immutable
class ChatMessageModel {
  final String id;
  final String senderId; // ID of the user who sent the message
  final String senderName; // Display name of the sender
  final String text;
  final DateTime timestamp;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  // For equatability and easy debugging/testing
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          senderId == other.senderId &&
          senderName == other.senderName &&
          text == other.text &&
          timestamp == other.timestamp;

  @override
  int get hashCode =>
      id.hashCode ^
      senderId.hashCode ^
      senderName.hashCode ^
      text.hashCode ^
      timestamp.hashCode;

  @override
  String toString() {
    return 'ChatMessageModel(id: $id, senderId: $senderId, senderName: $senderName, text: "$text", timestamp: $timestamp)';
  }

  // Example copyWith method if needed
  ChatMessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? text,
    DateTime? timestamp,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
