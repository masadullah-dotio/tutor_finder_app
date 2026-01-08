import 'package:flutter/material.dart';
import 'dart:convert';

class ImageHelper {
  /// Returns an ImageProvider based on the string content.
  /// Supports Network URL (http/https) and Base64 encoded strings.
  /// Returns null if path is null or empty.
  static ImageProvider? getUserImageProvider(String? path) {
    if (path == null || path.isEmpty) return null;

    try {
      if (path.startsWith('http') || path.startsWith('https')) {
        return NetworkImage(path);
      } else {
        // Assume Base64
        // Remove data:image/jpeg;base64, prefix if present
        String base64String = path;
        if (path.contains(',')) {
          base64String = path.split(',').last;
        }
        return MemoryImage(base64Decode(base64String));
      }
    } catch (e) {
      print('Error decoding image: $e');
      return null;
    }
  }
}
