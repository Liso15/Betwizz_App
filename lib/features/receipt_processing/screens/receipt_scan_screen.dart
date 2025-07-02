import 'package:flutter/material.dart';
// import 'package:camera/camera.dart'; // For CameraPreview
// import 'package:firebase_ml_vision/firebase_ml_vision.dart'; // For OCR

class ReceiptScanScreen extends StatefulWidget {
  const ReceiptScanScreen({super.key});

  @override
  State<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends State<ReceiptScanScreen> {
  // CameraController? _cameraController; // To be initialized
  bool _isCameraInitialized = false; // Placeholder
  String _ocrResult = "Scan a receipt to see OCR results here.";

  // Placeholder for camera initialization
  Future<void> _initializeCamera() async {
    // TODO: Implement camera initialization using 'camera' package
    // final cameras = await availableCameras();
    // final firstCamera = cameras.first;
    // _cameraController = CameraController(firstCamera, ResolutionPreset.high);
    // await _cameraController.initialize();
    await Future.delayed(const Duration(seconds: 1)); // Simulate init
    if (!mounted) return;
    setState(() {
      _isCameraInitialized = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera Initialized (Placeholder)')),
    );
  }

  // Placeholder for OCR processing
  Future<void> _processImageForOCR() async {
    // TODO: Capture image using _cameraController and process with Firebase ML Vision
    // final image = await _cameraController.takePicture();
    // final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFilePath(image.path);
    // final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
    // final VisionText visionText = await textRecognizer.processImage(visionImage);
    // setState(() { _ocrResult = visionText.text ?? "No text found."; });
    // await textRecognizer.close();
    await Future.delayed(const Duration(seconds: 1)); // Simulate processing
    setState(() {
      _ocrResult = "Betway OCR Parser Result (Placeholder):\nMatch: Team A vs Team B\nBet: Team A Win\nStake: R50.00";
    });
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OCR Processed (Placeholder)')),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // Attempt to initialize camera on screen load
  }

  @override
  void dispose() {
    // _cameraController?.dispose(); // Dispose camera controller
    super.dispose();
  }

  void _showManualOverrideSheet() {
    // PRD 7.1: Manual override (DraggableScrollableSheet)
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for DraggableScrollableSheet
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5, // Start at 50% height
        maxChildSize: 0.9,    // Max 90% height
        minChildSize: 0.3,    // Min 30% height
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ListView(
              controller: scrollController,
              children: <Widget>[
                Text('Manual Bet Slip Entry', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                const TextField(decoration: InputDecoration(labelText: 'Bookmaker (e.g., Betway, Hollywood Bets)')),
                const TextField(decoration: InputDecoration(labelText: 'Event (e.g., Chiefs vs Pirates)')),
                const TextField(decoration: InputDecoration(labelText: 'Bet Type (e.g., Full Time Result)')),
                const TextField(decoration: InputDecoration(labelText: 'Selection (e.g., Chiefs)')),
                const TextField(decoration: InputDecoration(labelText: 'Stake (ZAR)')),
                const TextField(decoration: InputDecoration(labelText: 'Odds')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Save manual entry
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manual Entry Saved (Placeholder)')),
                    );
                  },
                  child: const Text('Save Manual Entry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Betting Receipt'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Manual Entry',
            onPressed: _showManualOverrideSheet,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // OCR Viewfinder (CameraPreview) - PRD 7.1
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.black,
              child: _isCameraInitialized
                  // ? CameraPreview(_cameraController!) // Uncomment when camera is implemented
                  ? const Center(child: Text('CameraPreview Placeholder', style: TextStyle(color: Colors.white)))
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          // OCR Results / Controls Area
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  const Text(
                    'Align receipt within the frame. OCR will attempt to extract details.',
                    textAlign: TextAlign.center,
                  ),
                   // PRD 5.1: Betway OCR Parser, Hollywood Bets Integration
                  Text('OCR Result: $_ocrResult', style: const TextStyle(fontSize: 12)),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Scan / Re-scan Receipt'),
                    onPressed: _isCameraInitialized ? _processImageForOCR : null,
                  ),
                  // Placeholder for SA Compliance: Loss limit enforcement widgets
                  // This might appear if a scanned bet exceeds limits.
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Compliance Note: Bet amounts are checked against your loss limits.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
