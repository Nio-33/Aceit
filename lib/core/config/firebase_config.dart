import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../../env_example.dart';

class FirebaseConfig {
  // Firebase options for initialization
  static FirebaseOptions get options {
    // For Android/iOS, we should prefer using the platform-specific config files
    // This is a fallback for when those aren't available
    try {
      return FirebaseOptions(
        apiKey: _getEnvOrDefault('FIREBASE_API_KEY', FirebaseCredentials.apiKey),
        appId: _getEnvOrDefault('FIREBASE_APP_ID', FirebaseCredentials.appId),
        messagingSenderId: _getEnvOrDefault('FIREBASE_MESSAGING_SENDER_ID', FirebaseCredentials.messagingSenderId),
        projectId: _getEnvOrDefault('FIREBASE_PROJECT_ID', FirebaseCredentials.projectId),
        authDomain: _getEnvOrDefault('FIREBASE_AUTH_DOMAIN', FirebaseCredentials.authDomain),
        storageBucket: _getEnvOrDefault('FIREBASE_STORAGE_BUCKET', FirebaseCredentials.storageBucket),
        measurementId: _getEnvOrDefault('FIREBASE_MEASUREMENT_ID', FirebaseCredentials.measurementId),
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error creating Firebase options: $e");
      }
      // Return web-only configuration as fallback in debug mode
      return FirebaseOptions(
        apiKey: FirebaseCredentials.apiKey,
        appId: FirebaseCredentials.appId,
        messagingSenderId: FirebaseCredentials.messagingSenderId,
        projectId: FirebaseCredentials.projectId,
        authDomain: FirebaseCredentials.authDomain,
        storageBucket: FirebaseCredentials.storageBucket,
        measurementId: FirebaseCredentials.measurementId,
      );
    }
  }

  // Helper function to safely get env values
  static String _getEnvOrDefault(String key, String defaultValue) {
    try {
      final value = dotenv.env[key];
      return (value != null && value.isNotEmpty) ? value : defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  // Check if Firebase is properly configured
  static bool get isConfigured {
    try {
      // In debug mode, always consider it configured for development purposes
      if (kDebugMode) {
        return true;
      }
      
      // Check if we have valid credentials from any source
      final hasCredentials = FirebaseCredentials.apiKey.isNotEmpty &&
                            FirebaseCredentials.appId.isNotEmpty &&
                            FirebaseCredentials.projectId.isNotEmpty;
      
      // We'll consider it configured if we have basic credentials
      return hasCredentials;
    } catch (e) {
      // On any error, we'll assume not configured in production, but always configured in debug
      return kDebugMode;
    }
  }
} 