// lib/core/config/agora_config.dart

class AgoraConfig {
  // IMPORTANT: REPLACE WITH YOUR ACTUAL AGORA APP ID
  // Obtain your App ID from the Agora Console (console.agora.io)
  static const String appId = "YOUR_AGORA_APP_ID"; // Placeholder

  // IMPORTANT: Token generation should ideally be done on a backend server for security.
  // For testing, you can generate temporary tokens from the Agora Console.
  // DO NOT hardcode tokens for production apps if they are not short-lived temp tokens.
  static const String temporaryToken = "YOUR_TEMPORARY_TOKEN"; // Placeholder, if needed for testing

  // Default channel name for testing, can be overridden
  static const String defaultChannelName = "betwizz_test_channel";

  // Default UID for testing (0 means Agora assigns a UID)
  // It's often better to assign specific UIDs if you need to map them to your app's user IDs.
  static const int defaultUid = 0;

  // You can add other Agora related configurations here,
  // such as video profiles, encryption modes, etc.
  // Example:
  // static const VideoEncoderConfiguration videoEncoderConfiguration = VideoEncoderConfiguration(
  //   dimensions: VideoDimensions(width: 640, height: 360),
  //   frameRate: FrameRate.fps15,
  //   bitrate: StandardBitrate,
  //   orientationMode: OrientationMode.orientationModeAdaptive,
  // );
}

// Note: Ensure this file is added to .gitignore if it ever contains real, sensitive tokens,
// although backend token generation is the recommended secure approach.
// For App ID, it's generally safe to be in client-side code but keep it managed.
