import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aceit/env_example.dart';

/// Service to diagnose and fix Firebase configuration issues
class FirebaseHealthChecker {
  /// Singleton instance
  static final FirebaseHealthChecker _instance =
      FirebaseHealthChecker._internal();

  /// Factory constructor
  factory FirebaseHealthChecker() => _instance;

  /// Private constructor
  FirebaseHealthChecker._internal();

  /// Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Firebase Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check Firebase Authentication health
  Future<Map<String, dynamic>> checkAuthHealth() async {
    final Map<String, dynamic> result = {
      'success': false,
      'message': '',
      'details': <String, dynamic>{},
      'needsConfiguration': false,
    };

    try {
      debugPrint('FirebaseHealthChecker: Testing Authentication...');

      // Test with dummy credentials to check if Auth is configured
      await _auth.signInWithEmailAndPassword(
          email: 'test@example.com', password: 'dummy_password');

      result['success'] = true;
      result['message'] = 'Firebase Authentication is correctly configured';
      (result['details'] as Map<String, dynamic>)['auth_status'] = 'configured';

      debugPrint('FirebaseHealthChecker: Auth test successful');
      return result;
    } catch (e) {
      if (e is FirebaseAuthException) {
        // Check specific error types
        if (e.code == 'user-not-found' || e.code == 'invalid-email') {
          // These errors actually mean Auth is working!
          result['success'] = true;
          result['message'] = 'Firebase Authentication is correctly configured';
          (result['details'] as Map<String, dynamic>)['auth_status'] =
              'configured';
          (result['details'] as Map<String, dynamic>)['error_code'] = e.code;

          debugPrint(
              'FirebaseHealthChecker: Auth test successful (user-not-found is expected)');
        } else if (e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
          // Auth is not configured in Firebase Console
          result['success'] = false;
          result['message'] = 'Firebase Authentication is not configured';
          (result['details'] as Map<String, dynamic>)['auth_status'] =
              'not_configured';
          (result['details'] as Map<String, dynamic>)['error_code'] =
              'CONFIGURATION_NOT_FOUND';
          result['needsConfiguration'] = true;

          debugPrint('FirebaseHealthChecker: Auth is not configured');
        } else {
          // Other Firebase Auth exceptions
          result['success'] = false;
          result['message'] = 'Firebase Authentication error: ${e.message}';
          (result['details'] as Map<String, dynamic>)['auth_status'] = 'error';
          (result['details'] as Map<String, dynamic>)['error_code'] = e.code;
          (result['details'] as Map<String, dynamic>)['error_message'] =
              e.message;

          debugPrint(
              'FirebaseHealthChecker: Auth error: ${e.code} - ${e.message}');
        }
      } else {
        // Non-Firebase Auth exceptions
        result['success'] = false;
        result['message'] = 'Error checking Authentication: $e';
        (result['details'] as Map<String, dynamic>)['auth_status'] = 'error';
        (result['details'] as Map<String, dynamic>)['error'] = e.toString();

        debugPrint('FirebaseHealthChecker: Unexpected error checking Auth: $e');
      }

      return result;
    }
  }

  /// Check Firestore health
  Future<Map<String, dynamic>> checkFirestoreHealth() async {
    final Map<String, dynamic> result = {
      'success': false,
      'message': '',
      'details': <String, dynamic>{},
    };

    try {
      debugPrint('FirebaseHealthChecker: Testing Firestore...');

      // Try reading from a test collection
      await _firestore.collection('_test_').limit(1).get();

      result['success'] = true;
      result['message'] = 'Firestore is correctly configured';
      (result['details'] as Map<String, dynamic>)['firestore_status'] =
          'configured';

      debugPrint('FirebaseHealthChecker: Firestore test successful');
      return result;
    } catch (e) {
      // Firestore exceptions
      result['success'] = false;
      result['message'] = 'Firestore error: $e';
      (result['details'] as Map<String, dynamic>)['firestore_status'] = 'error';
      (result['details'] as Map<String, dynamic>)['error'] = e.toString();

      debugPrint('FirebaseHealthChecker: Firestore error: $e');
      return result;
    }
  }

  /// Check overall Firebase health
  Future<Map<String, dynamic>> checkFirebaseHealth() async {
    final Map<String, dynamic> result = {
      'success': false,
      'auth': <String, dynamic>{},
      'firestore': <String, dynamic>{},
      'firebase_core': <String, dynamic>{},
      'needs_configuration': false,
      'fix_instructions': '',
    };

    // Check if Firebase is initialized
    try {
      Firebase.app();
      result['firebase_core'] = {
        'success': true,
        'message': 'Firebase Core is initialized',
        'details': {
          'status': 'initialized',
        },
      };
    } catch (e) {
      result['firebase_core'] = {
        'success': false,
        'message': 'Firebase Core is not initialized: $e',
        'details': {
          'status': 'not_initialized',
          'error': e.toString(),
        },
      };

      // If core is not initialized, we can't check other services
      result['success'] = false;
      result['needs_configuration'] = true;
      result['fix_instructions'] = _getFirebaseCoreFixInstructions();
      return result;
    }

    // Check Auth health
    final authHealth = await checkAuthHealth();
    result['auth'] = authHealth;

    // Check Firestore health
    final firestoreHealth = await checkFirestoreHealth();
    result['firestore'] = firestoreHealth;

    // Determine overall health
    result['success'] =
        authHealth['success'] == true && firestoreHealth['success'] == true;

    // Check if configuration is needed
    if (authHealth['needsConfiguration'] == true) {
      result['needs_configuration'] = true;
      result['fix_instructions'] = _getAuthFixInstructions();
    }

    return result;
  }

  /// Launch Firebase Console for configuration
  Future<bool> launchFirebaseConsole() async {
    final url =
        'https://console.firebase.google.com/project/${FirebaseCredentials.projectId}/authentication/providers';
    if (await canLaunchUrl(Uri.parse(url))) {
      return await launchUrl(Uri.parse(url));
    }
    return false;
  }

  /// Get instructions to fix Firebase Core
  String _getFirebaseCoreFixInstructions() {
    return '''
# Fix Firebase Core Initialization

1. Check that you have the correct Firebase configuration files:
   - For Android: `android/app/google-services.json`
   - For iOS: `ios/Runner/GoogleService-Info.plist`

2. Verify your Firebase credentials in `lib/env_example.dart`

3. Make sure you're initializing Firebase in your app:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

4. Check that you've added all required dependencies to `pubspec.yaml`:
   ```yaml
   firebase_core: ^2.27.0
   firebase_auth: ^4.17.8
   cloud_firestore: ^4.15.8
   ```
''';
  }

  /// Get instructions to fix Authentication
  String _getAuthFixInstructions() {
    return '''
# Fix Firebase Authentication

## Enable Email/Password Authentication:

1. Go to [Firebase Console](https://console.firebase.google.com/project/${FirebaseCredentials.projectId}/authentication/providers)
2. Click on "Email/Password" provider
3. Toggle the switch to "Enable"
4. Click "Save"
5. Wait a few minutes for changes to propagate
6. Restart the app completely

## Additional Steps:

- Make sure your device has internet connection
- Check if the Firebase project ID (${FirebaseCredentials.projectId}) is correct
- Verify that the API key (${FirebaseCredentials.apiKey}) hasn't been restricted
''';
  }

  /// Show a detailed Firebase health check dialog
  void showHealthCheckDialog(BuildContext context) async {
    // Show loading dialog first
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Checking Firebase Configuration'),
          content: SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Diagnosing Firebase setup...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Perform health check
    final result = await checkFirebaseHealth();

    // Close loading dialog
    if (context.mounted) {
      Navigator.of(context).pop();
    }

    // Show results dialog
    if (context.mounted) {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              result['success'] == true
                  ? 'Firebase is Configured Correctly'
                  : 'Firebase Configuration Issues',
              style: TextStyle(
                color: result['success'] == true ? Colors.green : Colors.red,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Firebase Core status
                  _buildStatusItem(
                    'Firebase Core',
                    result['firebase_core']['success'] == true,
                    result['firebase_core']['message']?.toString() ?? '',
                  ),
                  const SizedBox(height: 8),

                  // Authentication status
                  _buildStatusItem(
                    'Authentication',
                    result['auth']['success'] == true,
                    result['auth']['message']?.toString() ?? '',
                  ),
                  const SizedBox(height: 8),

                  // Firestore status
                  _buildStatusItem(
                    'Firestore',
                    result['firestore']['success'] == true,
                    result['firestore']['message']?.toString() ?? '',
                  ),

                  // Fix instructions if needed
                  if (result['needs_configuration'] == true) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'How to Fix:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result['fix_instructions']?.toString() ?? '',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
              if (result['needs_configuration'] == true)
                ElevatedButton(
                  onPressed: () {
                    launchFirebaseConsole();
                  },
                  child: const Text('Open Firebase Console'),
                ),
            ],
          );
        },
      );
    }
  }

  /// Build a status item widget
  Widget _buildStatusItem(String title, bool success, String message) {
    return Row(
      children: [
        Icon(
          success ? Icons.check_circle : Icons.error,
          color: success ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
