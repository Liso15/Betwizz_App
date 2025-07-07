import 'package:google_ml_kit_text_recognition/google_ml_kit_text_recognition.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

abstract class OcrService {
  /// Extracts text from an image file specified by its path.
  /// Returns the recognized text as a single string.
  Future<String> extractTextFromImage(String imagePath);
}

class GoogleMlKitOcrService implements OcrService {
  final TextRecognizer _textRecognizer;

  GoogleMlKitOcrService({TextRecognizer? textRecognizer})
      : _textRecognizer = textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);
      // Defaulting to Latin script. Other scripts like Devanagari, Chinese, etc., are available.

  @override
  Future<String> extractTextFromImage(String imagePath) async {
    if (imagePath.isEmpty) {
      throw ArgumentError('Image path cannot be empty.');
    }

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // For debugging, print the structure of the recognized text
      // for (TextBlock block in recognizedText.blocks) {
      //   debugPrint("Block: ${block.text}");
      //   for (TextLine line in block.lines) {
      //     debugPrint("  Line: ${line.text}");
      //     for (TextElement element in line.elements) {
      //       debugPrint("    Element: ${element.text}");
      //     }
      //   }
      // }

      return recognizedText.text; // Returns the full text block
    } catch (e) {
      debugPrint('Error during text recognition: ${e.toString()}');
      throw Exception('Failed to extract text from image: ${e.toString()}');
      // Consider more specific error types or messages if needed
    }
  }

  /// Call this method when the service is no longer needed, or when the app is disposed,
  /// to release resources used by the TextRecognizer.
  Future<void> dispose() async {
    await _textRecognizer.close();
    debugPrint("TextRecognizer closed.");
  }
}

// --- Riverpod Provider ---
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ocrServiceProvider = Provider<OcrService>((ref) {
  final ocrService = GoogleMlKitOcrService();
  // It's important to manage the lifecycle of TextRecognizer.
  // Since this provider creates the instance, it should also be responsible for disposing it.
  // Riverpod's `onDispose` is perfect for this.
  ref.onDispose(() {
    ocrService.dispose();
    debugPrint("ocrServiceProvider: Disposed GoogleMlKitOcrService.");
  });
  return ocrService;
});
