import 'dart:async';
import 'package:flutter/foundation.dart'; // For ValueNotifier and debugPrint
import 'package:web_socket_channel/io.dart'; // Using IOWebSocketChannel for cross-platform
// Or use 'package:web_socket_channel/html.dart' for web-only.
// For conditional import: import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  IOWebSocketChannel? _channel;
  StreamSubscription? _channelSubscription;

  // StreamController to broadcast messages received from the WebSocket.
  // Using String type for messages, adjust if binary or other types are expected.
  final StreamController<String> _messageStreamController = StreamController<String>.broadcast();
  Stream<String> get messages => _messageStreamController.stream;

  // ValueNotifier to broadcast connection state.
  final ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);

  /// Connects to the WebSocket server at the given URL.
  Future<void> connect(String url) async {
    if (isConnected.value && _channel != null) {
      debugPrint('WebSocketService: Already connected to a channel. Disconnecting first.');
      await disconnect(); // Disconnect if already connected, or if connecting to a new URL
    }

    debugPrint('WebSocketService: Attempting to connect to $url...');
    try {
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      isConnected.value = true; // Assume connected initially, stream events will confirm/deny
      debugPrint('WebSocketService: Connection initiated.');

      _channelSubscription = _channel!.stream.listen(
        (message) {
          // Ensure isConnected is true when messages are flowing
          if (!isConnected.value) isConnected.value = true;
          debugPrint('WebSocketService: Received message: $message');
          if (message is String) {
            _messageStreamController.add(message);
          } else {
            // Handle binary data or other types if necessary
            _messageStreamController.add(message.toString());
             debugPrint('WebSocketService: Received non-string message, converted to string.');
          }
        },
        onError: (error) {
          debugPrint('WebSocketService: Error in WebSocket stream: $error');
          _messageStreamController.addError('Connection Error: $error');
          isConnected.value = false;
          // Consider attempting to reconnect here or notifying UI for manual reconnect
        },
        onDone: () {
          debugPrint('WebSocketService: WebSocket stream closed (onDone).');
          isConnected.value = false;
          _messageStreamController.add('Connection Closed.');
          // Consider attempting to reconnect here or notifying UI
        },
        cancelOnError: true, // Automatically cancels subscription on error
      );
      _messageStreamController.add('Connection to $url established.');

    } catch (e) {
      debugPrint('WebSocketService: Failed to connect to $url: $e');
      _messageStreamController.addError('Failed to connect: $e');
      isConnected.value = false;
    }
  }

  /// Sends a message through the WebSocket.
  void sendMessage(String message) {
    if (_channel != null && isConnected.value) {
      debugPrint('WebSocketService: Sending message: $message');
      _channel!.sink.add(message);
    } else {
      debugPrint('WebSocketService: Cannot send message, not connected.');
      _messageStreamController.addError('Cannot send message: Not connected.');
    }
  }

  /// Disconnects from the WebSocket server.
  Future<void> disconnect() async {
    if (_channel != null) {
      debugPrint('WebSocketService: Disconnecting...');
      await _channelSubscription?.cancel(); // Cancel the stream subscription
      _channelSubscription = null;
      await _channel!.sink.close(); // Close the sink
      _channel = null;
      isConnected.value = false;
      _messageStreamController.add('Disconnected.');
      debugPrint('WebSocketService: Disconnected.');
    } else {
      debugPrint('WebSocketService: Already disconnected.');
    }
  }

  /// Disposes resources used by the service.
  /// Call this when the service is no longer needed (e.g., on provider disposal).
  void dispose() {
    disconnect(); // Ensure connection is closed
    _messageStreamController.close();
    isConnected.dispose();
    debugPrint('WebSocketService: Disposed.');
  }
}

// --- Riverpod Provider ---
import 'package:flutter_riverpod/flutter_riverpod.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() {
    service.dispose();
    debugPrint("webSocketServiceProvider: Disposed WebSocketService.");
  });
  return service;
});
