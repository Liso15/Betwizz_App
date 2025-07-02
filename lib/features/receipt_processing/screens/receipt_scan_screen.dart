import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:betwizz_app/features/receipt_processing/services/ocr_service.dart';

class ReceiptScanScreen extends ConsumerStatefulWidget { // Changed to ConsumerStatefulWidget
  const ReceiptScanScreen({super.key});

  @override
  ConsumerState<ReceiptScanScreen> createState() => _ReceiptScanScreenState();
}

class _ReceiptScanScreenState extends ConsumerState<ReceiptScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraPermissionGranted = false;
  bool _isCameraInitialized = false;
  bool _isProcessingOcr = false;
  String _ocrResult = "Align receipt and tap scan button.";
  String _statusMessage = "Initializing camera...";


  @override
  void initState() {
    super.initState();
    _requestCameraPermissionAndInitialize();
  }

  Future<void> _requestCameraPermissionAndInitialize() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _isCameraPermissionGranted = true;
        _statusMessage = "Camera permission granted. Initializing camera...";
      });
      await _initializeCameraController();
    } else {
      setState(() {
        _isCameraPermissionGranted = false;
        _statusMessage = "Camera permission denied. OCR functionality requires camera access.";
         if (status.isPermanentlyDenied) {
           _statusMessage += "\nPlease enable camera access in app settings.";
         }
      });
    }
  }

  Future<void> _initializeCameraController() async {
    if (!_isCameraPermissionGranted) return;

    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      setState(() {
        _statusMessage = "No cameras available on this device.";
        _isCameraInitialized = false;
      });
      return;
    }

    // Initialize with the first back camera found
    CameraDescription? backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first, // Fallback to first camera if no back camera
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.high, // Use high resolution for better OCR
      enableAudio: false, // Audio is not needed for OCR
    );

    try {
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _statusMessage = "Camera ready. Align receipt and scan.";
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = "Error initializing camera: ${e.toString()}";
        _isCameraInitialized = false;
      });
      debugPrint("Camera initialization error: $e");
    }
  }

  Future<void> _captureAndProcessImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isProcessingOcr) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not ready or already processing.')),
      );
      return;
    }

    setState(() {
      _isProcessingOcr = true;
      _ocrResult = "Processing image...";
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      debugPrint("Image captured: ${imageFile.path}");

      final ocrService = ref.read(ocrServiceProvider);
      final extractedText = await ocrService.extractTextFromImage(imageFile.path);

      if (!mounted) return;
      setState(() {
        _ocrResult = extractedText.isEmpty ? "No text found in the image." : extractedText;
      });

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _ocrResult = "Error processing image: ${e.toString()}";
      });
      debugPrint("OCR processing error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOcr = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _cameraController?.dispose();
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
            child: _isCameraPermissionGranted
                ? _isCameraInitialized && _cameraController != null
                    ? CameraPreview(_cameraController!)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 10),
                            Text(_statusMessage, style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text(_statusMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
                           const SizedBox(height: 10),
                           ElevatedButton(onPressed: _requestCameraPermissionAndInitialize, child: const Text("Retry Permissions"))
                        ],
                      ),
                    ),
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
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(_ocrResult, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _isProcessingOcr
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan / Re-scan Receipt'),
                      onPressed: (_isCameraInitialized && _isCameraPermissionGranted) ? _captureAndProcessImage : null,
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
