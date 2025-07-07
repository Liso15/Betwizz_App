import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/channels/notifiers/create_channel_form_notifier.dart';
import 'package:betwizz_app/features/channels/models/create_channel_form_state.dart';

class CreateChannelScreen extends ConsumerWidget { // Changed to ConsumerWidget
  const CreateChannelScreen({super.key});

  // Note: FormKey is not strictly necessary if all validation is handled by the notifier,
  // but can be kept if you prefer using TextFormField's validator prop directly for UI feedback
  // before even hitting the notifier. For this example, we'll rely on notifier's error message.
  // final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(createChannelFormProvider);
    final formNotifier = ref.read(createChannelFormProvider.notifier);

    // Listen for submission success to show SnackBar and pop
    ref.listen<CreateChannelFormState>(createChannelFormProvider, (previous, next) {
      if (next.submissionSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Channel creation submitted (Mock)!')),
        );
        // Reset the success flag so it doesn't trigger again on rebuild
        formNotifier.consumeSubmissionSuccess();
        // Optionally navigate back or to a different screen
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Channel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // child: Form( // Form widget is optional if not using its validation
          // key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                initialValue: formState.channelName, // Set initialValue
                decoration: const InputDecoration(
                  labelText: 'Channel Name',
                  hintText: 'Enter a unique name for your channel',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => formNotifier.updateChannelName(value),
                // validator: ... // Could still use local validation if desired
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: formState.description, // Set initialValue
                decoration: const InputDecoration(
                  labelText: 'Channel Description',
                  hintText: 'Tell viewers what your channel is about',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => formNotifier.updateDescription(value),
              ),
              const SizedBox(height: 16.0),
              if (formState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    formState.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              const SizedBox(height: 8.0),
              formState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => formNotifier.submitCreateChannelForm(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: const Text('Create Channel'),
                    ),
            ],
          ),
        // ),
      ),
    );
  }
}
