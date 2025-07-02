import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/channels/models/strategy_model.dart';
import 'package:betwizz_app/features/channels/notifiers/strategy_providers.dart';
import 'package:betwizz_app/features/channels/repositories/channel_repository.dart';
import 'package:betwizz_app/features/channels/widgets/community_chat_view.dart'; // Import CommunityChatView
import 'package:intl/intl.dart';

// Placeholder for Creator data model, replace with actual model later
class Creator {
  final String name;
  const Creator({required this.name});
}

// Placeholder for ChannelHeader widget
class ChannelHeader extends StatelessWidget {
  final Creator creator;
  const ChannelHeader({super.key, required this.creator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)), // Placeholder for creator avatar
          const SizedBox(width: 8),
          Text('Channel by ${creator.name}', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

import 'package:betwizz_app/app.dart'; // For AppRoutes

// Placeholder for StartStreamButton widget
// Renaming to reflect its new purpose or making it more generic
class ManageChannelButton extends StatelessWidget { // Renamed for clarity
  const ManageChannelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // Navigate to Create Channel Screen
        Navigator.pushNamed(context, AppRoutes.createChannel);
      },
      tooltip: 'Create/Manage Channel', // Updated tooltip
      child: const Icon(Icons.add_circle_outline), // Changed icon
    );
  }
}

class StrategyVaultView extends ConsumerWidget {
  const StrategyVaultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strategiesAsyncValue = ref.watch(strategiesProvider);

    return strategiesAsyncValue.when(
      data: (strategies) {
        if (strategies.isEmpty) {
          return const Center(child: Text('No strategies found.'));
        }
        return ListView.builder(
          itemCount: strategies.length,
          itemBuilder: (context, index) {
            final strategy = strategies[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListTile(
                title: Text(strategy.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strategy.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      'By: ${strategy.authorName} - ${DateFormat.yMMMd().format(strategy.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.enhanced_encryption_outlined),
                  tooltip: 'Encrypt (Stub)',
                  onPressed: () async {
                    // Hardcoded user key for demonstration
                    const String userKey = "averysecureplaceholderkey1234567";

                    // Show loading indicator SnackBar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Encrypting strategy...'), duration: Duration(seconds: 1)),
                    );

                    try {
                      final result = await ref.read(channelRepositoryProvider).uploadEncryptedStrategy(strategy, userKey);
                      ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Remove loading SnackBar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result), duration: const Duration(seconds: 3)),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error during encryption: $e'), duration: const Duration(seconds: 3)),
                      );
                    }
                  },
                ),
                onTap: () {
                  // TODO: Implement navigation to strategy detail screen or action
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Tapped on: ${strategy.title}')),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error loading strategies: $error', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}


class ChannelDashboardScreen extends StatefulWidget {
  const ChannelDashboardScreen({super.key});

  @override
  State<ChannelDashboardScreen> createState() => _ChannelDashboardScreenState();
}

class _ChannelDashboardScreenState extends State<ChannelDashboardScreen> with SingleTickerProviderStateMixin {
  // Placeholder: In a real app, this would come from user data/state
  final Creator _creator = const Creator(name: "AwesomeStreamer");
  final bool _isCreator = true; // Placeholder: determine if current user is the creator

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channel Dashboard'),
        actions: [ // Added actions to AppBar
          IconButton(
            icon: const Icon(Icons.video_library_outlined),
            tooltip: 'Video Player Demo',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.videoPlayerDemo);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.live_tv), text: "Live"),
            Tab(icon: Icon(Icons.library_books), text: "Strategies"),
            Tab(icon: Icon(Icons.forum), text: "Chat"),
          ],
        ),
      ),
      body: Column(
        children: [
          ChannelHeader(creator: _creator),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const Center(child: Text('Live Stream Tab Content')),
                const StrategyVaultView(),
                // Provide a placeholder channelId for now.
                // In a real app, this would come from the current channel context.
                CommunityChatView(channelId: _creator.name.replaceAll(' ', '_').toLowerCase() + "_channel"),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isCreator ? const ManageChannelButton() : null, // Updated to use ManageChannelButton
    );
  }
}
