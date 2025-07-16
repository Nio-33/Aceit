import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tools/env_generator.dart';
import '../../../env_example.dart';

class FirebaseConfigScreen extends StatefulWidget {
  const FirebaseConfigScreen({super.key});

  @override
  State<FirebaseConfigScreen> createState() => _FirebaseConfigScreenState();
}

class _FirebaseConfigScreenState extends State<FirebaseConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _apiKeyController = TextEditingController();
  final _authDomainController = TextEditingController();
  final _projectIdController = TextEditingController();
  final _storageBucketController = TextEditingController();
  final _messagingSenderIdController = TextEditingController();
  final _appIdController = TextEditingController();
  final _measurementIdController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form fields with Firebase credentials from env_example.dart
    _apiKeyController.text = FirebaseCredentials.apiKey;
    _authDomainController.text = FirebaseCredentials.authDomain;
    _projectIdController.text = FirebaseCredentials.projectId;
    _storageBucketController.text = FirebaseCredentials.storageBucket;
    _messagingSenderIdController.text = FirebaseCredentials.messagingSenderId;
    _appIdController.text = FirebaseCredentials.appId;
    _measurementIdController.text = FirebaseCredentials.measurementId;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _authDomainController.dispose();
    _projectIdController.dispose();
    _storageBucketController.dispose();
    _messagingSenderIdController.dispose();
    _appIdController.dispose();
    _measurementIdController.dispose();
    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final success = await EnvGenerator.generateEnvFile(
          apiKey: _apiKeyController.text,
          authDomain: _authDomainController.text,
          projectId: _projectIdController.text,
          storageBucket: _storageBucketController.text,
          messagingSenderId: _messagingSenderIdController.text,
          appId: _appIdController.text,
          measurementId: _measurementIdController.text.isNotEmpty 
              ? _measurementIdController.text 
              : null,
        );
        
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Firebase configuration saved successfully. Restart the app to apply changes.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          
          // Return to the previous screen
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to save Firebase configuration. Please check file permissions.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Configuration'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Firebase credentials from the project are pre-filled below:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'You can review and save these credentials to generate the .env file.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // API Key
            TextFormField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'Your Firebase API key',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'API Key is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Auth Domain
            TextFormField(
              controller: _authDomainController,
              decoration: const InputDecoration(
                labelText: 'Auth Domain',
                hintText: 'your-project-id.firebaseapp.com',
                prefixIcon: Icon(Icons.domain),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Auth Domain is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Project ID
            TextFormField(
              controller: _projectIdController,
              decoration: const InputDecoration(
                labelText: 'Project ID',
                hintText: 'your-project-id',
                prefixIcon: Icon(Icons.folder),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Project ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Storage Bucket
            TextFormField(
              controller: _storageBucketController,
              decoration: const InputDecoration(
                labelText: 'Storage Bucket',
                hintText: 'your-project-id.appspot.com',
                prefixIcon: Icon(Icons.storage),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Storage Bucket is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Messaging Sender ID
            TextFormField(
              controller: _messagingSenderIdController,
              decoration: const InputDecoration(
                labelText: 'Messaging Sender ID',
                hintText: 'Your messaging sender ID',
                prefixIcon: Icon(Icons.message),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Messaging Sender ID is required';
                }
                return null;
              },
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            const SizedBox(height: 16),
            
            // App ID
            TextFormField(
              controller: _appIdController,
              decoration: const InputDecoration(
                labelText: 'App ID',
                hintText: 'Your Firebase app ID',
                prefixIcon: Icon(Icons.app_registration),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'App ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Measurement ID (optional)
            TextFormField(
              controller: _measurementIdController,
              decoration: const InputDecoration(
                labelText: 'Measurement ID (optional)',
                hintText: 'Your measurement ID for Analytics',
                prefixIcon: Icon(Icons.analytics),
              ),
            ),
            const SizedBox(height: 32),
            
            // Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveConfiguration,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            
            // Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Important',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'After saving the configuration, you need to restart the application for the changes to take effect.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 