import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:betwizz_app/core/config/agora_config.dart'; // Using our config file
import 'package:flutter/foundation.dart'; // For debugPrint

// Define a callback type for engine events if needed more broadly
// typedef AgoraEngineEventHandler = Function(String eventName, Map<String, dynamic> data);

class AgoraService {
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isInChannel = false;

  // Store current channel details if needed
  String? _currentChannelId;
  int? _currentUid;

  // Add event listeners or streams for UI to react to connection state, user join/leave etc.
  // Example:
  // final StreamController<String> _eventStreamController = StreamController<String>.broadcast();
  // Stream<String> get eventStream => _eventStreamController.stream;

  Future<bool> initializeEngine({String? appIdOverride}) async {
    if (_isInitialized) {
      debugPrint("AgoraService: Engine already initialized.");
      return true;
    }
    final appIdToUse = appIdOverride ?? AgoraConfig.appId;
    if (appIdToUse == "YOUR_AGORA_APP_ID" || appIdToUse.isEmpty) {
      debugPrint("AgoraService: ERROR - Agora App ID is not set. Please set it in AgoraConfig.appId");
      // _eventStreamController.add("Error: App ID not set");
      return false;
    }

    try {
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appIdToUse,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting, // Common for streaming
      ));
      debugPrint("AgoraService: Engine initialized successfully with App ID: $appIdToUse");

      _addEventHandlers(); // Setup event handlers

      // Enable video by default, can be configured further
      await _engine!.enableVideo();
      // Set client role - default to Audience, can be changed before joining
      await _engine!.setClientRole(role: ClientRoleType.clientRoleAudience);

      _isInitialized = true;
      // _eventStreamController.add("Engine Initialized");
      return true;
    } catch (e) {
      debugPrint("AgoraService: ERROR - Failed to initialize Agora engine: ${e.toString()}");
      // _eventStreamController.add("Error: Engine initialization failed - ${e.toString()}");
      _engine = null;
      _isInitialized = false;
      return false;
    }
  }

  void _addEventHandlers() {
    if (_engine == null) return;
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("AgoraService: Successfully joined channel ${connection.channelId} as uid ${connection.localUid}");
          _isInChannel = true;
          _currentChannelId = connection.channelId;
          _currentUid = connection.localUid;
          // _eventStreamController.add("Joined channel: ${connection.channelId}");
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          debugPrint("AgoraService: Left channel ${connection.channelId}");
          _isInChannel = false;
          // _eventStreamController.add("Left channel: ${connection.channelId}");
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint("AgoraService: Agora Engine Error - Code: $err, Message: $msg");
          // _eventStreamController.add("Error: $err - $msg");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("AgoraService: User $remoteUid joined channel ${connection.channelId}");
          // _eventStreamController.add("User joined: $remoteUid");
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("AgoraService: User $remoteUid left channel ${connection.channelId} due to $reason");
          // _eventStreamController.add("User offline: $remoteUid");
        },
        // Add more handlers as needed: e.g., onConnectionStateChanged, onRemoteVideoStateChanged etc.
      ),
    );
  }

  Future<bool> joinChannel({
    required String channelId,
    String? token, // Token is crucial for production
    int uid = AgoraConfig.defaultUid, // 0 for auto-assign by Agora
    ClientRoleType clientRole = ClientRoleType.clientRoleAudience,
  }) async {
    if (!_isInitialized || _engine == null) {
      debugPrint("AgoraService: ERROR - Engine not initialized. Call initializeEngine() first.");
      // _eventStreamController.add("Error: Engine not initialized for joinChannel");
      return false;
    }
    if (_isInChannel && _currentChannelId == channelId) {
      debugPrint("AgoraService: Already in channel $channelId.");
      return true;
    }
    if (_isInChannel) { // If in a different channel, leave first
      await leaveChannel();
    }

    final tokenToUse = token ?? (AgoraConfig.temporaryToken == "YOUR_TEMPORARY_TOKEN" ? null : AgoraConfig.temporaryToken);
     if (tokenToUse == null) {
      debugPrint("AgoraService: WARNING - Joining channel without a token. This is not secure for production.");
      // For some Agora project settings, a token might be mandatory even for testing.
    }


    try {
      await _engine!.setClientRole(role: clientRole);
      await _engine!.joinChannel(
        token: tokenToUse, // Use null if no token (for testing with App Certificate disabled)
        channelId: channelId,
        uid: uid,
        options: const ChannelMediaOptions(
          // Configure media options as needed
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true, // Set to true if clientRole is Broadcaster
          publishMicrophoneTrack: true, // Set to true if clientRole is Broadcaster
          clientRoleType: ClientRoleType.clientRoleBroadcaster, // Must match setClientRole
        ),
      );
      // onJoinChannelSuccess handler will confirm actual join
      return true; // Indicates attempt to join was made
    } catch (e) {
      debugPrint("AgoraService: ERROR - Failed to join channel $channelId: ${e.toString()}");
      // _eventStreamController.add("Error: Failed to join channel - ${e.toString()}");
      return false;
    }
  }

  Future<void> leaveChannel() async {
    if (!_isInitialized || _engine == null || !_isInChannel) {
      debugPrint("AgoraService: Not in a channel or engine not initialized.");
      return;
    }
    try {
      await _engine!.leaveChannel();
      debugPrint("AgoraService: Leave channel command issued.");
      _isInChannel = false; // Tentatively set, onLeaveChannel confirms
    } catch (e) {
      debugPrint("AgoraService: ERROR - Failed to leave channel: ${e.toString()}");
      // _eventStreamController.add("Error: Failed to leave channel - ${e.toString()}");
    }
  }

  Future<void> setClientRole(ClientRoleType role) async {
    if (!_isInitialized || _engine == null) {
      debugPrint("AgoraService: Engine not initialized. Cannot set client role.");
      return;
    }
    try {
      await _engine!.setClientRole(role: role);
      debugPrint("AgoraService: Client role set to $role");
    } catch (e) {
      debugPrint("AgoraService: ERROR - Failed to set client role: ${e.toString()}");
    }
  }

  // Expose engine for direct access if needed by UI (e.g. for video views)
  RtcEngine? get engine => _engine;

  bool get isInitialized => _isInitialized;
  bool get isInChannel => _isInChannel;


  Future<void> disposeEngine() async {
    if (_engine != null) {
      if (_isInChannel) {
        await leaveChannel();
      }
      await _engine!.release(); // Use release() instead of destroy() in Agora SDK v4+
      debugPrint("AgoraService: Engine released.");
    }
    _engine = null;
    _isInitialized = false;
    _isInChannel = false;
    // _eventStreamController.close();
  }
}

// --- Riverpod Provider ---
// Import Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';

final agoraServiceProvider = Provider<AgoraService>((ref) {
  // This provides a new instance of AgoraService.
  // If AgoraService had dependencies, they would be resolved here using ref.watch or ref.read.
  return AgoraService();
});
