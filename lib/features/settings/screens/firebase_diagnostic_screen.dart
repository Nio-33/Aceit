import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../env_example.dart';

/// A diagnostic screen for Firebase configuration issues
class FirebaseDiagnosticScreen extends StatefulWidget {
  const FirebaseDiagnosticScreen({super.key});

  @override
  State<FirebaseDiagnosticScreen> createState() => _FirebaseDiagnosticScreenState();
}

class _FirebaseDiagnosticScreenState extends State<FirebaseDiagnosticScreen> {
  bool _isLoading = true;
  String _firebaseStatus = 'Checking Firebase status...';
  String _authStatus = 'Checking Auth status...';
  String _firestoreStatus = 'Checking Firestore status...';
  String _projectId = 'Unknown';
  
  @override
  void initState() {
    super.initState();
    _checkFirebaseStatus();
  }
  
  Future<void> _checkFirebaseStatus() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      // 1. Check Firebase initialization
      try {
        final app = Firebase.app();
        _firebaseStatus = '✅ Firebase initialized: ${app.name}';
        _projectId = FirebaseCredentials.projectId;
      } catch (e) {
        _firebaseStatus = '❌ Firebase initialization error: $e';
      }
      
      // 2. Check Auth status
      try {
        await FirebaseAuth.instance.fetchSignInMethodsForEmail('test@example.com');
        _authStatus = '✅ Firebase Auth is working properly';
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          _authStatus = '✅ Firebase Auth is configured (user-not-found is expected)';
        } else if (e.toString().contains('CONFIGURATION_NOT_FOUND')) {
          _authStatus = '❌ Firebase Auth is not configured. Enable Email/Password sign-in method.';
        } else {
          _authStatus = '❌ Firebase Auth error: $e';
        }
      }
      
      // 3. Check Firestore status
      try {
        await FirebaseFirestore.instance.collection('test').get();
        _firestoreStatus = '✅ Firestore is working properly';
      } catch (e) {
        _firestoreStatus = '❌ Firestore error: $e';
      }
    } catch (e) {
      print('Error in diagnostic check: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  Future<void> _openFirebaseConsole() async {
    try {
      final url = 'https://console.firebase.google.com/project/$_projectId/authentication/users';
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening URL: $e')),
      );
    }
  }
  
  Future<void> _copyFirebaseCredentials() async {
    try {
      final text = '''
Project ID: ${FirebaseCredentials.projectId}
API Key: ${FirebaseCredentials.apiKey}
Auth Domain: ${FirebaseCredentials.authDomain}
''';
      
      await Clipboard.setData(ClipboardData(text: text));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Firebase credentials copied to clipboard')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error copying credentials: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Diagnostics'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Firebase Configuration Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Firebase Status
                _buildStatusCard(
                  title: 'Firebase Core',
                  status: _firebaseStatus,
                  icon: Icons.cloud,
                ),
                
                // Auth Status
                _buildStatusCard(
                  title: 'Authentication',
                  status: _authStatus,
                  icon: Icons.lock,
                ),
                
                // Firestore Status
                _buildStatusCard(
                  title: 'Firestore Database',
                  status: _firestoreStatus,
                  icon: Icons.storage,
                ),
                
                const SizedBox(height: 24),
                
                // Project Credentials
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Firebase Project',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: _copyFirebaseCredentials,
                              tooltip: 'Copy credentials',
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Project ID: $_projectId'),
                        const Text('App ID: ${FirebaseCredentials.appId}'),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.open_in_browser),
                          label: const Text('Open Firebase Console'),
                          onPressed: _openFirebaseConsole,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // User data access information
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'How to View User Accounts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'To view all registered users (including incomplete signups):',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Go to the Firebase Console (button above)\n'
                          '2. Navigate to Authentication > Users\n'
                          '3. You\'ll see a list of all registered emails\n'
                          '4. Check the "Email verified" column to see verification status',
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Note: Flutter apps cannot directly list all user accounts due to security restrictions. '
                          'User management must be done through the Firebase Console or a secure backend service.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
  
  Widget _buildStatusCard({
    required String title,
    required String status,
    required IconData icon,
  }) {
    final isSuccess = status.startsWith('✅');
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSuccess ? Colors.green : Colors.red,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 