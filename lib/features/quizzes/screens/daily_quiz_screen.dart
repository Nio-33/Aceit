import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aceit/core/theme/app_theme.dart';
import 'package:aceit/features/auth/providers/auth_provider.dart';
import 'package:aceit/features/quiz/screens/quiz_taking_screen.dart';
import 'package:aceit/widgets/common/primary_button.dart';

class DailyQuizScreen extends StatefulWidget {
  const DailyQuizScreen({super.key});

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  String _selectedSubject = 'Mathematics';
  String _selectedExamType = 'WAEC';

  final List<String> _subjects = [
    'Mathematics',
    'English Language',
    'Physics',
    'Chemistry',
    'Biology',
    'Geography',
    'Economics',
    'Government',
    'Literature',
    'History',
  ];

  final List<String> _examTypes = ['WAEC', 'JAMB', 'NECO'];

  void _startDailyQuiz(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to start quiz')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuizTakingScreen(
          userId: user.id,
          quizType: 'daily',
          subject: _selectedSubject,
          examType: _selectedExamType,
          durationInMinutes: 15, // 15 minutes for daily quiz
        ),
      ),
    );
  }

  void _startSubjectQuiz(String subject) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to start quiz')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuizTakingScreen(
          userId: user.id,
          quizType: 'subject_practice',
          subject: subject,
          examType: _selectedExamType,
          durationInMinutes: 20, // 20 minutes for subject quiz
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quiz'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header with illustration
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.quiz,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Daily Quiz Challenge',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Take a 10-question quiz every day to maintain your streak and earn points!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Subject and Exam Type Selection
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quiz Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject Selection
                  const Text(
                    'Select Subject:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedSubject,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: _subjects.map((subject) {
                      return DropdownMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubject = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Exam Type Selection
                  const Text(
                    'Select Exam Type:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedExamType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: _examTypes.map((examType) {
                      return DropdownMenuItem<String>(
                        value: examType,
                        child: Text(examType),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedExamType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Start Quiz Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Start Daily Quiz',
                      onPressed: () => _startDailyQuiz(context),
                      icon: Icons.play_arrow,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Quiz History
          const Text(
            'Your Recent Quizzes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(5, (index) {
            final date = DateTime.now().subtract(Duration(days: index));
            final score = 7 + (index % 4); // Random score between 7-10
            final formattedDate = '${date.day}/${date.month}/${date.year}';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Text(
                    '${score}',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('Daily Quiz - $formattedDate'),
                subtitle: Text('Score: $score/10'),
                trailing: Icon(
                  score >= 7 ? Icons.check_circle : Icons.cancel,
                  color: score >= 7 ? Colors.green : Colors.red,
                ),
                onTap: () {
                  // Show quiz details/review
                },
              ),
            );
          }),
          const SizedBox(height: 32),

          // Subject Quizzes
          const Text(
            'Subject Quizzes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildSubjectQuizCard('Mathematics', Colors.blue),
              _buildSubjectQuizCard('English', Colors.green),
              _buildSubjectQuizCard('Physics', Colors.orange),
              _buildSubjectQuizCard('Chemistry', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectQuizCard(String subject, Color color) {
    return InkWell(
      onTap: () {
        // Navigate to subject quiz
        _startSubjectQuiz(subject);
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.book,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                subject,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                '10 Questions',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
