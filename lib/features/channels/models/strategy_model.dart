import 'package:flutter/foundation.dart' show immutable;

@immutable
class StrategyModel {
  final String id;
  final String title;
  final String description;
  final String authorName; // Or authorId if linking to UserModel
  final DateTime createdAt;
  // final String encryptedContent; // For later actual implementation

  const StrategyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.createdAt,
    // this.encryptedContent = '', // Default or handle null
  });

  // For equatability and easy debugging/testing
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StrategyModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          authorName == other.authorName &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      authorName.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'StrategyModel(id: $id, title: $title, description: $description, authorName: $authorName, createdAt: $createdAt)';
  }

  // Example copyWith method if needed for state management (e.g. with StateNotifier)
  StrategyModel copyWith({
    String? id,
    String? title,
    String? description,
    String? authorName,
    DateTime? createdAt,
    // String? encryptedContent,
  }) {
    return StrategyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      // encryptedContent: encryptedContent ?? this.encryptedContent,
    );
  }
}
