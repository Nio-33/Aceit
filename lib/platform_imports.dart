import 'package:flutter/foundation.dart';

// Import dart:io only on non-web platforms
import 'platform_imports_io.dart'
    if (dart.library.html) 'platform_imports_web.dart';

/// PlatformFile class that abstracts platform-specific file operations
class PlatformFile {
  /// Check if a file exists, handling web and non-web platforms
  static Future<bool> exists(String path) async {
    if (kIsWeb) {
      // Web implementation from platform_imports_web.dart
      return PlatformSpecificFile.exists(path);
    } else {
      // Native implementation from platform_imports_io.dart
      return PlatformSpecificFile.exists(path);
    }
  }

  /// Create a file with content, handling web and non-web platforms
  static Future<bool> create(String path, String content) async {
    if (kIsWeb) {
      // Web implementation
      return PlatformSpecificFile.create(path, content);
    } else {
      // Native implementation
      return PlatformSpecificFile.create(path, content);
    }
  }
}
