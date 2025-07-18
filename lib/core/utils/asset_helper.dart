import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Helper class to manage and ensure assets are available in the app
class AssetHelper {
  /// Ensure critical assets exist by creating placeholders if needed
  static Future<void> ensureAssetsExist() async {
    // Skip asset creation on web platform
    if (kIsWeb) {
      debugPrint('Running on web platform - skipping asset directory creation');
      return;
    }

    try {
      // Only create directories on native platforms
      final assetsDir = Directory('assets');
      final imagesDir = Directory('assets/images');
      final iconsDir = Directory('assets/icons');

      if (!assetsDir.existsSync()) {
        await assetsDir.create(recursive: true);
        debugPrint('Created assets directory: ${assetsDir.path}');
      }

      if (!imagesDir.existsSync()) {
        await imagesDir.create(recursive: true);
        debugPrint('Created images directory: ${imagesDir.path}');
      }

      if (!iconsDir.existsSync()) {
        await iconsDir.create(recursive: true);
        debugPrint('Created icons directory: ${iconsDir.path}');
      }

      // Create placeholder assets
      final logoFile = File('assets/images/logo.png');
      if (!logoFile.existsSync()) {
        // Create a placeholder logo file
        final ByteData data = await rootBundle.load(
            'packages/flutter/lib/assets/flutter_assets/flutter_logo.png');
        final bytes = data.buffer.asUint8List();
        await logoFile.writeAsBytes(bytes);
        debugPrint('Created placeholder logo: ${logoFile.path}');
      }

      // Create placeholder files if needed
      _createPlaceholderTextFile('assets/images/placeholder.txt',
          'This directory contains image assets for the AceIt app.');
      _createPlaceholderTextFile('assets/icons/placeholder.txt',
          'This directory contains icon assets for the AceIt app.');

      debugPrint('Asset directories and placeholders verified successfully');
    } catch (e) {
      debugPrint('Error ensuring assets exist: $e');
    }
  }

  /// Create a placeholder text file if it doesn't exist
  static void _createPlaceholderTextFile(String path, String content) {
    if (kIsWeb) return; // Skip on web

    final file = File(path);
    if (!file.existsSync()) {
      file.writeAsStringSync(content);
      debugPrint('Created placeholder file: ${file.path}');
    }
  }
}
