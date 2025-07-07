import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/channels/models/create_channel_form_state.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

class CreateChannelFormNotifier extends StateNotifier<CreateChannelFormState> {
  CreateChannelFormNotifier() : super(const CreateChannelFormState());

  void updateChannelName(String name) {
    state = state.copyWith(channelName: name, clearErrorMessage: true, submissionSuccess: false);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description, clearErrorMessage: true, submissionSuccess: false);
  }

  Future<void> submitCreateChannelForm() async {
    // Clear previous errors/success state
    state = state.copyWith(isLoading: true, clearErrorMessage: true, submissionSuccess: false);

    // Basic Validation
    if (state.channelName.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Channel name cannot be empty.', isLoading: false);
      return;
    }
    if (state.channelName.trim().length < 3) {
      state = state.copyWith(errorMessage: 'Channel name must be at least 3 characters.', isLoading: false);
      return;
    }
    if (state.description.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Description cannot be empty.', isLoading: false);
      return;
    }
     if (state.description.trim().length < 10) {
      state = state.copyWith(errorMessage: 'Description must be at least 10 characters.', isLoading: false);
      return;
    }

    // Simulate network request / async operation
    await Future.delayed(const Duration(seconds: 1));

    // Simulate success/failure
    // In a real app, this would be an API call.
    bool success = true; // Change to false to test error case
    // Random random = Random();
    // bool success = random.nextBool();


    if (success) {
      debugPrint('Channel Creation Submitted (Mock): Name: ${state.channelName}, Desc: ${state.description}');
      // Reset form or indicate success
      state = state.copyWith(isLoading: false, submissionSuccess: true, channelName: '', description: '');
      // Keep channelName and description if you want them to persist after mock success for some reason
      // state = state.copyWith(isLoading: false, submissionSuccess: true);
    } else {
      state = state.copyWith(errorMessage: 'Mock submission failed. Please try again.', isLoading: false);
    }
  }

  // Call this to reset the submissionSuccess flag after UI has reacted to it
  void consumeSubmissionSuccess() {
    if (state.submissionSuccess) {
      state = state.copyWith(submissionSuccess: false);
    }
  }
}

// Provider for CreateChannelFormNotifier
final createChannelFormProvider =
    StateNotifierProvider<CreateChannelFormNotifier, CreateChannelFormState>((ref) {
  return CreateChannelFormNotifier();
});
