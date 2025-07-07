import 'package:flutter/foundation.dart' show immutable;

@immutable
class CreateChannelFormState {
  final String channelName;
  final String description;
  final bool isLoading;
  final String? errorMessage; // For displaying errors related to submission or validation
  final bool submissionSuccess; // To indicate successful submission

  const CreateChannelFormState({
    this.channelName = '',
    this.description = '',
    this.isLoading = false,
    this.errorMessage,
    this.submissionSuccess = false,
  });

  CreateChannelFormState copyWith({
    String? channelName,
    String? description,
    bool? isLoading,
    String? errorMessage,
    bool? clearErrorMessage, // Special flag to nullify error message
    bool? submissionSuccess,
  }) {
    return CreateChannelFormState(
      channelName: channelName ?? this.channelName,
      description: description ?? this.description,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage == true ? null : errorMessage ?? this.errorMessage,
      submissionSuccess: submissionSuccess ?? this.submissionSuccess,
    );
  }

  @override
  String toString() {
    return 'CreateChannelFormState(channelName: $channelName, description: $description, isLoading: $isLoading, errorMessage: $errorMessage, submissionSuccess: $submissionSuccess)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CreateChannelFormState &&
      other.channelName == channelName &&
      other.description == description &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage &&
      other.submissionSuccess == submissionSuccess;
  }

  @override
  int get hashCode {
    return channelName.hashCode ^
      description.hashCode ^
      isLoading.hashCode ^
      errorMessage.hashCode ^
      submissionSuccess.hashCode;
  }
}
