import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/core/services/websocket_service.dart';

class WebSocketDemoScreen extends ConsumerStatefulWidget {
  const WebSocketDemoScreen({super.key});

  @override
  ConsumerState<WebSocketDemoScreen> createState() => _WebSocketDemoScreenState();
}

class _WebSocketDemoScreenState extends ConsumerState<WebSocketDemoScreen> {
  final TextEditingController _urlController = TextEditingController(text: 'wss://echo.websocket.org');
  // Alternative public echo server: 'wss://socketsbay.com/wss/v2/1/demo/'
  final TextEditingController _messageController = TextEditingController();

  List<String> _receivedMessages = [];
  String _connectionStatus = "Disconnected";
  StreamSubscription? _messageSubscription;
  VoidCallback? _connectionStateListener;


  @override
  void initState() {
    super.initState();
    // Get the WebSocketService instance
    final webSocketService = ref.read(webSocketServiceProvider);

    // Listener for connection state changes
    _connectionStateListener = () {
      if (mounted) {
        setState(() {
          _connectionStatus = webSocketService.isConnected.value ? "Connected" : "Disconnected";
        });
      }
    };
    webSocketService.isConnected.addListener(_connectionStateListener!);

    // Listener for incoming messages
    _messageSubscription = webSocketService.messages.listen((message) {
      if (mounted) {
        setState(() {
          _receivedMessages.insert(0, "Received: $message"); // Add to top
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _receivedMessages.insert(0, "Error: $error");
        });
      }
    });
    // Initial status based on current state
     _connectionStatus = webSocketService.isConnected.value ? "Connected" : "Disconnected";
  }

  @override
  void dispose() {
    _urlController.dispose();
    _messageController.dispose();
    _messageSubscription?.cancel();

    final webSocketService = ref.read(webSocketServiceProvider);
    if (_connectionStateListener != null) {
      webSocketService.isConnected.removeListener(_connectionStateListener!);
    }
    // The WebSocketService itself will be disposed by its provider's onDispose,
    // but if this screen initiated a connection, it might be polite to disconnect.
    // However, the service is shared, so disconnecting here might affect other listeners.
    // For a demo screen, explicit disconnect on dispose is fine if it's the sole user.
    // webSocketService.disconnect(); // Let provider handle full disposal
    super.dispose();
  }

  void _connect() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      ref.read(webSocketServiceProvider).connect(url);
      // Status will update via ValueNotifier listener
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a WebSocket URL.')),
      );
    }
  }

  void _disconnect() {
    ref.read(webSocketServiceProvider).disconnect();
    // Status will update via ValueNotifier listener
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      ref.read(webSocketServiceProvider).sendMessage(message);
      setState(() {
        _receivedMessages.insert(0, "Sent: $message");
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final webSocketService = ref.watch(webSocketServiceProvider); // To get current isConnected state for button

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Demo'),
         leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'WebSocket URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: webSocketService.isConnected.value ? null : _connect,
                  child: const Text('Connect'),
                ),
                ElevatedButton(
                  onPressed: webSocketService.isConnected.value ? _disconnect : null,
                  child: const Text('Disconnect'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Status: $_connectionStatus', style: TextStyle(fontWeight: FontWeight.bold, color: webSocketService.isConnected.value ? Colors.green : Colors.red)),
            const SizedBox(height: 20),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message to Send',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: webSocketService.isConnected.value ? _sendMessage : null,
              child: const Text('Send Message'),
            ),
            const SizedBox(height: 20),
            Text('Received Messages/Log:', style: Theme.of(context).textTheme.titleMedium),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: ListView.builder(
                  reverse: false, // Keep new messages at the top for this log style
                  itemCount: _receivedMessages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      title: Text(_receivedMessages[index]),
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
