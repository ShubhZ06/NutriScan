import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// OCR fallback service using Google ML Kit
class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from the camera and extract text
  Future<String?> captureAndExtractText() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (image == null) return null;
    return extractTextFromPath(image.path);
  }

  /// Pick an image from gallery and extract text
  Future<String?> pickAndExtractText() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image == null) return null;
    return extractTextFromPath(image.path);
  }

  /// Extract text from an image file path
  Future<String?> extractTextFromPath(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) return null;

      // Try to isolate the ingredients section
      return _extractIngredientsBlock(recognizedText.text);
    } catch (e) {
      return null;
    }
  }

  /// Attempt to find and extract just the ingredients block
  String _extractIngredientsBlock(String fullText) {
    final lower = fullText.toLowerCase();

    // Common ingredient section headers
    final markers = [
      'ingredients:',
      'ingredients -',
      'composition:',
      'contains:',
      'made with:',
    ];

    for (final marker in markers) {
      final idx = lower.indexOf(marker);
      if (idx != -1) {
        // Take everything from the marker onward
        String section = fullText.substring(idx + marker.length).trim();

        // Try to find where the next section starts
        final endMarkers = [
          'nutrition facts',
          'nutritional information',
          'allergen',
          'directions',
          'storage',
          'best before',
          'manufactured',
          'distributed',
          'net wt',
          'net weight',
        ];

        for (final end in endMarkers) {
          final endIdx = section.toLowerCase().indexOf(end);
          if (endIdx != -1) {
            section = section.substring(0, endIdx).trim();
            break;
          }
        }

        return section;
      }
    }

    // If no marker found, return the full text and let AI figure it out
    return fullText;
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
