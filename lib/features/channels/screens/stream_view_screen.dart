import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:betwizz_app/features/channels/services/agora_service.dart';
import 'package:betwizz_app/core/config/agora_config.dart'; // For default channel name
// import 'package:agora_rtc_engine/agora_rtc_engine.dart'; // For RtcEngine, VideoViewController, AgoraVideoView etc.

// Placeholder for ZAR formatting utility - PRD 6.1
String formatZAR(double amount) {
  return 'R ${amount.toStringAsFixed(2)}';
}

// Removed agoraServiceProvider from here, it will be in agora_service.dart

class StreamViewScreen extends ConsumerStatefulWidget {
  const StreamViewScreen({super.key});

  @override
  ConsumerState<StreamViewScreen> createState() => _StreamViewScreenState();
}

class _StreamViewScreenState extends ConsumerState<StreamViewScreen> {
  late AgoraService _agoraService;
  String _statusMessage = "Initializing...";
  bool _permissionsGranted = false;
  // int? _localUid; // To store local user ID after joining channel
  // Set<int> _remoteUids = {}; // To store remote user IDs

  @override
  void initState() {
    super.initState();
    _agoraService = ref.read(agoraServiceProvider);
    _initAgora();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    if (statuses[Permission.camera]!.isGranted && statuses[Permission.microphone]!.isGranted) {
      setState(() {
        _permissionsGranted = true;
        _statusMessage = "Permissions granted. Initializing Agora...";
      });
    } else {
      setState(() {
        _permissionsGranted = false;
        _statusMessage = "Permissions denied. Camera and Microphone are required for streaming.";
      });
      // Optionally, guide user to app settings
      if (statuses[Permission.camera]!.isPermanentlyDenied || statuses[Permission.microphone]!.isPermanentlyDenied) {
        // openAppSettings(); // Consider guiding user to settings
         _statusMessage += "\nPlease enable them in app settings.";
      }
    }
  }

  Future<void> _initAgora() async {
    await _requestPermissions();
    if (!_permissionsGranted) return;

    bool initialized = await _agoraService.initializeEngine();
    if (initialized) {
      setState(() {
        _statusMessage = "Agora engine initialized. Joining channel...";
      });
      // Example: Join a default channel as a broadcaster
      // In a real app, channelId, token, and uid would be dynamic
      bool joined = await _agoraService.joinChannel(
        channelId: AgoraConfig.defaultChannelName,
        // token: AgoraConfig.temporaryToken, // Use actual token if required by your Agora project
        // uid: AgoraConfig.defaultUid,
        // clientRole: ClientRoleType.clientRoleBroadcaster, // Example role
      );
      if (joined && mounted) {
         setState(() {
          _statusMessage = "Attempted to join channel: ${AgoraConfig.defaultChannelName}. Waiting for connection...";
          // Listen to agoraService events or use engine directly for local/remote UID updates
          // For example, if AgoraService exposes a stream of UIDs or connection states.
          // _localUid = _agoraService. // get current local UID if available after join attempt
        });
      } else if(mounted) {
        setState(() {
          _statusMessage = "Failed to join channel.";
        });
      }
    } else if (mounted) {
      setState(() {
        _statusMessage = "Failed to initialize Agora engine. Check App ID.";
      });
    }
  }

  @override
  void dispose() {
    _agoraService.disposeEngine(); // Ensure engine is released
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder data, would come from state/backend
    final currentStake = 100.50;
    final currentOdds = 2.5;
    final viewerCount = 1234; // This would be dynamic
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Stream'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Chip(
              avatar: const Icon(Icons.remove_red_eye_outlined, size: 16),
              label: Text('$viewerCount'),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          // Main video view area
          Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_statusMessage, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  // Placeholder for Local Video View
                  // if (_agoraService.isInitialized && _agoraService.isInChannel && _localUid != null)
                  //   Expanded(
                  //     child: AgoraVideoView(
                  //       controller: VideoViewController(
                  //         rtcEngine: _agoraService.engine!,
                  //         canvas: const VideoCanvas(uid: 0), // 0 for local view
                  //       ),
                  //     ),
                  //   ),
                  // Placeholder for Remote Video Views
                  // ..._remoteUids.map((uid) => Expanded(
                  //   child: AgoraVideoView(
                  //     controller: VideoViewController.remote(
                  //       rtcEngine: _agoraService.engine!,
                  //       canvas: VideoCanvas(uid: uid),
                  //       connection: RtcConnection(channelId: AgoraConfig.defaultChannelName),
                  //     ),
                  //   ),
                  // )).toList(),
                  if (!_permissionsGranted)
                    ElevatedButton(
                        onPressed: _requestPermissions,
                        child: const Text("Request Permissions"))
                ],
              ),
            ),
          ),

          // --- Other UI elements from previous version ---
          Positioned(
            top: isPortrait ? 80 : 20,
            left: 20,
            child: Card(
              color: Colors.black.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stake: ${formatZAR(currentStake)}', style: const TextStyle(color: Colors.white)),
                    Text('Odds: ${currentOdds.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: isPortrait ? 150 : 80,
            right: 20,
            child: Opacity(
              opacity: 0.3,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orangeAccent),
                  borderRadius: BorderRadius.circular(8)
                ),
                child: const Center(child: Text('Engagement Heatmap Area', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10))),
              ),
            ),
          ),
          Positioned(
            bottom: isPortrait ? 80 : 20,
            left: 20,
            right: 20,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Real-time Bet Slip', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Selected Bet: Team A to Win'),
                    const SizedBox(height: 4),
                    Text('Stake: ${formatZAR(50.00)}'),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: () {}, child: const Text('Place Bet'))
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: isPortrait ? 80 : 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.monetization_on),
              label: Text('Donate ${formatZAR(10)}'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Donation (Not Implemented)')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ),
          Positioned(
            bottom: 10,
            left: isPortrait ? 10 : null,
            right: 10,
            width: isPortrait ? null : 250,
            height: isPortrait ? 120 : null,
            child: Opacity(
              opacity: 0.8,
              child: Card(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text("Live Chat", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    Expanded(child: ListView(children: const [Text("User1: Hello!", style: TextStyle(fontSize: 10)), Text("User2: Great stream!", style: TextStyle(fontSize: 10))])),
                    const TextField(decoration: InputDecoration(hintText: "Send message...", contentPadding: EdgeInsets.all(4), isDense: true, border: OutlineInputBorder())),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// Removed redundant WidgetRef placeholder
