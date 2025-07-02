import 'package:flutter/material.dart';
// import 'package:rive/rive.dart'; // For Rive animations
// import 'package:custom_paint_example/custom_paint.dart'; // For CustomPaint examples

// Placeholder for Mfethu Chat Bubble - PRD 7.1
class MfethuChatBubble extends StatelessWidget {
  final String text;
  final bool isUser; // To differentiate user messages from Mfethu's

  const MfethuChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      ),
    );
  }
}

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


class AiDashboardScreen extends StatefulWidget {
  const AiDashboardScreen({super.key});

  @override
  State<AiDashboardScreen> createState() => _AiDashboardScreenState();
}

class _AiDashboardScreenState extends State<AiDashboardScreen> {
  final TextEditingController _chatController = TextEditingController();
  final List<Map<String, dynamic>> _chatMessages = [
    {'text': 'Welcome to Mfethu Chat! How can I help you with your betting strategy today?', 'isUser': false},
    // PRD 4.2: Mfethu basic Q&A (local NLP model)
    {'text': 'Remember, Mfethu can provide basic Q&A even offline.', 'isUser': false},
  ];

  // Placeholder for Rive animation - PRD 7.1
  // RiveAnimationController _riveController; (would need initialization)

  void _sendMessage() {
    if (_chatController.text.isNotEmpty) {
      setState(() {
        _chatMessages.add({'text': _chatController.text, 'isUser': true});
        // Simulate Mfethu's response
        _chatMessages.add({'text': 'Mfethu processing: "${_chatController.text}" (Placeholder response)', 'isUser': false});
        _chatController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Dashboard (Mfethu & Khanyo)'),
      ),
      body: Column(
        children: [
          // Khanyo Predictions Section - PRD 5.1, 7.1
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Khanyo's Predictions", style: Theme.of(context).textTheme.headlineSmall),
          ),
          SizedBox(
            height: 150, // Fixed height for horizontal list of predictions
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
          // Mfethu Chat Interface Section - PRD 5.1, 7.1
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Mfethu Chat", style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                return MfethuChatBubble(text: message['text'], isUser: message['isUser']);
              },
            ),
          ),
          // Placeholder for Rive loading animation - PRD 7.2
          // SizedBox(height: 50, child: RiveAnimation.asset('assets/loading.riv')) // If Rive asset is added
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
          // Placeholder for SA Compliance: Responsible gambling hotline integration - PRD 6.1
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
