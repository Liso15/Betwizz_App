import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:betwizz_app/features/ai/widgets/mfethu_chat_bubble.dart';
import 'package:betwizz_app/features/channels/models/chat_message_model.dart'; // Used by MfethuChatBubble & Notifier
import 'package:betwizz_app/features/ai/notifiers/mfethu_chat_notifier.dart'; // Import the notifier

// MfethuChatBubble class has been moved

// Placeholder for Khanyo Prediction Display - PRD 7.1
class KhanyoPredictionCard extends StatelessWidget {
  final String predictionTitle;
  final String detail;
  final double confidence; // e.g. 0.0 to 1.0

  const KhanyoPredictionCard({
    super.key,
    required this.predictionTitle,
    required this.detail,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(predictionTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(detail, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: LinearProgressIndicator(value: confidence, backgroundColor: Colors.grey[300], color: Colors.green, minHeight: 6,)),
                const SizedBox(width: 8),
                Text('${(confidence * 100).toStringAsFixed(0)}% Confident', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AiDashboardScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const AiDashboardScreen({super.key});

  @override
  ConsumerState<AiDashboardScreen> createState() => _AiDashboardScreenState();
}

class _AiDashboardScreenState extends ConsumerState<AiDashboardScreen> { // Changed to ConsumerState
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _chatController.text.trim();
    if (text.isNotEmpty) {
      ref.read(mfethuChatProvider.notifier).addUserMessage(text);
      _chatController.clear();
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
    final chatMessages = ref.watch(mfethuChatProvider);

    // Listen for changes to scroll to bottom
    ref.listen(mfethuChatProvider, (previous, next) {
      if (next.length > (previous?.length ?? 0) ) {
         _scrollToBottom();
      }
    });

    // Initial scroll to bottom when messages are first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
        if (chatMessages.isNotEmpty) _scrollToBottom();
    });


    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Dashboard (Mfethu & Khanyo)'),
      ),
      body: Column(
        children: [
          // Khanyo Predictions Section (remains the same for now)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Khanyo's Predictions", style: Theme.of(context).textTheme.headlineSmall),
          ),
          SizedBox(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              children: const [
                KhanyoPredictionCard(predictionTitle: "Next Goal Scorer", detail: "Player X - High probability based on recent form.", confidence: 0.75),
                KhanyoPredictionCard(predictionTitle: "Match Outcome", detail: "Team Y to win by 2 goals.", confidence: 0.60),
                KhanyoPredictionCard(predictionTitle: "Over/Under 2.5 Goals", detail: "High chance of Over 2.5 goals.", confidence: 0.85),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Mfethu Chat", style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: chatMessages.length,
              itemBuilder: (context, index) {
                final message = chatMessages[index];
                return MfethuChatBubble(message: message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Ask Mfethu...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Remember to gamble responsibly. Hotline: XXX-XXX-XXXX',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
