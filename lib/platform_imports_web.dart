/// Platform-specific file implementation for web platforms
/// Web platform doesn't have direct file system access, so we provide dummy implementations
class PlatformSpecificFile {
  /// Check if a file exists - always returns false on web
  static Future<bool> exists(String path) async {
    // Web platform can't access local file system
    return false;
  }

  /// Create a file with content - always returns false on web
  static Future<bool> create(String path, String content) async {
    // Web platform can't create files in the local file system
    return false;
  }
}
