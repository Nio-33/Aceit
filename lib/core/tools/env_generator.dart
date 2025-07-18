import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../env_example.dart';
import '../../platform_imports.dart';

/// Utility class to generate .env file
class EnvGenerator {
  /// Generate a .env file with the provided Firebase credentials
  static Future<bool> generateEnvFile({
    required String apiKey,
    required String authDomain,
    required String projectId,
    required String storageBucket,
    required String messagingSenderId,
    required String appId,
    String? measurementId,
  }) async {
    // Skip file creation on web platform
    if (kIsWeb) {
      print('Web platform - skipping .env file creation');
      return false;
    }

    try {
      // Prepare the content of the .env file
      final content = '''
# Firebase Configuration
FIREBASE_API_KEY=$apiKey
FIREBASE_AUTH_DOMAIN=$authDomain
FIREBASE_PROJECT_ID=$projectId
FIREBASE_STORAGE_BUCKET=$storageBucket
FIREBASE_MESSAGING_SENDER_ID=$messagingSenderId
FIREBASE_APP_ID=$appId
${measurementId != null ? 'FIREBASE_MEASUREMENT_ID=$measurementId' : ''}
''';

      // Create the .env file using platform-specific implementation
      final success = await PlatformFile.create('.env', content);

      if (success) {
        print('Generated .env file successfully');
      } else {
        print('Failed to generate .env file');
      }

      return success;
    } catch (e) {
      print('Error generating .env file: $e');
      return false;
    }
  }

  /// Generate a .env file with the Firebase credentials from FirebaseCredentials
  static Future<bool> generateDefaultEnvFile() async {
    return generateEnvFile(
      apiKey: FirebaseCredentials.apiKey,
      authDomain: FirebaseCredentials.authDomain,
      projectId: FirebaseCredentials.projectId,
      storageBucket: FirebaseCredentials.storageBucket,
      messagingSenderId: FirebaseCredentials.messagingSenderId,
      appId: FirebaseCredentials.appId,
      measurementId: FirebaseCredentials.measurementId,
    );
  }

  /// Show a dialog to collect Firebase configuration
  static Future<void> showConfigDialog(BuildContext context) async {
    // Pre-fill with Firebase credentials from FirebaseCredentials
    final apiKeyController =
        TextEditingController(text: FirebaseCredentials.apiKey);
    final authDomainController =
        TextEditingController(text: FirebaseCredentials.authDomain);
    final projectIdController =
        TextEditingController(text: FirebaseCredentials.projectId);
    final storageBucketController =
        TextEditingController(text: FirebaseCredentials.storageBucket);
    final messagingSenderIdController =
        TextEditingController(text: FirebaseCredentials.messagingSenderId);
    final appIdController =
        TextEditingController(text: FirebaseCredentials.appId);
    final measurementIdController =
        TextEditingController(text: FirebaseCredentials.measurementId);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Firebase Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Firebase credentials from the project are pre-filled below:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Your Firebase API key',
                ),
              ),
              TextField(
                controller: authDomainController,
                decoration: const InputDecoration(
                  labelText: 'Auth Domain',
                  hintText: 'your-project-id.firebaseapp.com',
                ),
              ),
              TextField(
                controller: projectIdController,
                decoration: const InputDecoration(
                  labelText: 'Project ID',
                  hintText: 'your-project-id',
                ),
              ),
              TextField(
                controller: storageBucketController,
                decoration: const InputDecoration(
                  labelText: 'Storage Bucket',
                  hintText: 'your-project-id.appspot.com',
                ),
              ),
              TextField(
                controller: messagingSenderIdController,
                decoration: const InputDecoration(
                  labelText: 'Messaging Sender ID',
                  hintText: 'Your messaging sender ID',
                ),
              ),
              TextField(
                controller: appIdController,
                decoration: const InputDecoration(
                  labelText: 'App ID',
                  hintText: 'Your Firebase app ID',
                ),
              ),
              TextField(
                controller: measurementIdController,
                decoration: const InputDecoration(
                  labelText: 'Measurement ID (optional)',
                  hintText: 'Your measurement ID for Analytics',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (kIsWeb) {
        // On web, we can't create files, so just show a message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Firebase configuration updated in memory for this session. Note: .env files cannot be created on web platform.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final success = await generateEnvFile(
        apiKey: apiKeyController.text,
        authDomain: authDomainController.text,
        projectId: projectIdController.text,
        storageBucket: storageBucketController.text,
        messagingSenderId: messagingSenderIdController.text,
        appId: appIdController.text,
        measurementId: measurementIdController.text.isNotEmpty
            ? measurementIdController.text
            : null,
      );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '.env file generated successfully. Please restart the app.'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to generate .env file. Please check permissions.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Dispose controllers
    apiKeyController.dispose();
    authDomainController.dispose();
    projectIdController.dispose();
    storageBucketController.dispose();
    messagingSenderIdController.dispose();
    appIdController.dispose();
    measurementIdController.dispose();
  }
}
