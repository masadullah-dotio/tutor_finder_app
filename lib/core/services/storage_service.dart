import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert'; // Added for base64

class StorageService {
  // FirebaseStorage _storage = FirebaseStorage.instance; // Not used anymore

  Future<String> uploadProfileImage(XFile imageFile, String userId) async {
    try {
      // 1. Read bytes
      final Uint8List bytes = await imageFile.readAsBytes();

      // 2. Convert to Base64
      final String base64String = base64Encode(bytes);
      
      // Return as data URI or raw base64. 
      // Using just base64 is simpler if we handle it in helper.
      return base64String;
      
    } catch (e) {
      throw Exception('Failed to process image: $e');
    }
  }
}
