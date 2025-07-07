import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // VideoPlayerController will be initialized in initState
  VideoPlayerController? _controller;
  bool _isPlaying = false; // To track playback state for UI

  // Sample video URL - replace with your actual video URL
  final String _sampleVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
      // 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';


  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(_sampleVideoUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // and update the UI.
        if (mounted) {
          setState(() {});
        }
      })
      ..addListener(() {
        // Listener to update _isPlaying state for the button icon
        if (mounted && _isPlaying != _controller?.value.isPlaying) {
          setState(() {
            _isPlaying = _controller!.value.isPlaying;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller?.removeListener(() {}); // Remove listener to avoid memory leaks
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Demo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: _controller != null && _controller!.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
                  const SizedBox(height: 10),
                  VideoProgressIndicator(
                    _controller!,
                    allowScrubbing: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  ),
                  // Basic playback time display
                  ValueListenableBuilder(
                    valueListenable: _controller!,
                    builder: (context, VideoPlayerValue value, child) {
                       return Padding(
                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: <Widget>[
                             Text(_formatDuration(value.position)),
                             Text(_formatDuration(value.duration)),
                           ],
                         ),
                       );
                    },
                  ),
                ],
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller != null && _controller!.value.isInitialized) {
            setState(() {
              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
              _isPlaying = _controller!.value.isPlaying; // Update immediately for icon
            });
          }
        },
        child: Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
