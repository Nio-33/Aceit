import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/quiz/screens/quiz_taking_screen.dart';
import '../../../widgets/common/primary_button.dart';

class MockExamListScreen extends StatefulWidget {
  const MockExamListScreen({super.key});

  @override
  State<MockExamListScreen> createState() => _MockExamListScreenState();
}

class _MockExamListScreenState extends State<MockExamListScreen> {
  String _selectedExamType = 'WAEC';

  void _startMockExam(String subject, String examType) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to start exam')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizTakingScreen(
          userId: user.id,
          quizType: 'mock_exam',
          subject: subject,
          examType: examType,
          durationInMinutes: _getDurationForExam(examType),
        ),
      ),
    );
  }

  int _getDurationForExam(String examType) {
    switch (examType) {
      case 'JAMB':
        return 120; // 2 hours
      case 'WAEC':
        return 180; // 3 hours
      case 'NECO':
        return 150; // 2.5 hours
      default:
        return 120;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mock Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filters/Tabs for exam types (WAEC, JAMB, NECO)
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.examTypes.length,
              itemBuilder: (context, index) {
                final examType = AppConstants.examTypes[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(examType),
                    selected: examType == _selectedExamType,
                    onSelected: (selected) {
                      setState(() {
                        _selectedExamType = examType;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: examType == _selectedExamType
                          ? AppTheme.primaryColor
                          : Colors.black,
                      fontWeight: examType == _selectedExamType
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Mock Exam Cards
          ...List.generate(10, (index) {
            final subject = index % 2 == 0 ? 'Mathematics' : 'English';
            final examType = AppConstants.examTypes[index % 3];
            final duration = index % 2 == 0 ? '2 hours' : '1 hour 30 mins';
            final questions = (index + 1) * 10;

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.assignment),
                        const SizedBox(width: 8),
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            examType,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Exam Details
                        Row(
                          children: [
                            _buildExamDetail(
                              icon: Icons.timer,
                              label: 'Duration',
                              value: duration,
                            ),
                            const SizedBox(width: 16),
                            _buildExamDetail(
                              icon: Icons.help_outline,
                              label: 'Questions',
                              value: '$questions',
                            ),
                            const SizedBox(width: 16),
                            _buildExamDetail(
                              icon: Icons.star_outline,
                              label: 'Pass Mark',
                              value: '50%',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Start Button
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: 'Start Exam',
                            onPressed: () =>
                                _startMockExam(subject, _selectedExamType),
                            icon: Icons.play_arrow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildExamDetail({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
