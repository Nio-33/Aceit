import 'dart:io';

/// Platform-specific file implementation for IO platforms (Android, iOS, macOS, Windows, Linux)
class PlatformSpecificFile {
  /// Check if a file exists using dart:io
  static Future<bool> exists(String path) async {
    final file = File(path);
    return file.exists();
  }

  /// Create a file with content using dart:io
  static Future<bool> create(String path, String content) async {
    try {
      final file = File(path);
      await file.writeAsString(content);
      return true;
    } catch (_) {
      return false;
    }
  }
}
