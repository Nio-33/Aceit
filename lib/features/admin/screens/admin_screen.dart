import 'package:flutter/material.dart';
import 'package:aceit/core/services/seed_data_service.dart';
import 'package:aceit/widgets/common/primary_button.dart';
import 'package:aceit/core/theme/app_colors.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final SeedDataService _seedDataService = SeedDataService();
  bool _isLoading = false;
  String _statusMessage = '';

  Future<void> _seedData(String type) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Seeding $type...';
    });

    try {
      switch (type) {
        case 'questions':
          await _seedDataService.seedSampleQuestions();
          break;
        case 'flashcards':
          await _seedDataService.seedSampleFlashcards();
          break;
        case 'mock_exams':
          await _seedDataService.seedSampleMockExams();
          break;
        case 'all':
          await _seedDataService.seedAllSampleData();
          break;
      }

      setState(() {
        _statusMessage = 'Successfully seeded $type!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error seeding $type: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing all data...';
    });

    try {
      await _seedDataService.clearAllSampleData();
      setState(() {
        _statusMessage = 'Successfully cleared all data!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error clearing data: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sample Data Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Seed sample data for testing the quiz functionality:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Seed Questions
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Seed Questions',
                        onPressed:
                            _isLoading ? null : () => _seedData('questions'),
                        icon: Icons.quiz,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Seed Flashcards
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Seed Flashcards',
                        onPressed:
                            _isLoading ? null : () => _seedData('flashcards'),
                        icon: Icons.style,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Seed Mock Exams
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        text: 'Seed Mock Exams',
                        onPressed:
                            _isLoading ? null : () => _seedData('mock_exams'),
                        icon: Icons.assignment,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Seed All Data
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green[400]!, Colors.green[600]!],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _seedData('all'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload,
                                        color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Seed All Data',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Clear Data Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _clearData,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Clear All Data',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Status Message
            if (_statusMessage.isNotEmpty)
              Card(
                color: _statusMessage.contains('Error')
                    ? Colors.red[50]
                    : Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _statusMessage.contains('Error')
                            ? Icons.error
                            : Icons.check_circle,
                        color: _statusMessage.contains('Error')
                            ? Colors.red
                            : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage,
                          style: TextStyle(
                            color: _statusMessage.contains('Error')
                                ? Colors.red[700]
                                : Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '1. Click "Seed All Data" to populate the database with sample questions, flashcards, and mock exams.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '2. This will enable you to test the quiz functionality without manually adding content.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '3. Use "Clear All Data" to remove all sample data when needed.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '4. The system will skip seeding if data already exists.',
                      style:
                          TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
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
}
