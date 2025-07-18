import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aceit/features/quiz/providers/quiz_provider.dart';
import 'package:aceit/features/quiz/screens/quiz_result_screen.dart';
import 'package:aceit/models/question_model.dart';
import 'package:aceit/widgets/common/primary_button.dart';
import 'package:aceit/core/theme/app_colors.dart';

class QuizTakingScreen extends StatefulWidget {
  final String userId;
  final String quizType;
  final String subject;
  final String examType;
  final int durationInMinutes;
  final String? mockExamId;

  const QuizTakingScreen({
    super.key,
    required this.userId,
    required this.quizType,
    required this.subject,
    required this.examType,
    required this.durationInMinutes,
    this.mockExamId,
  });

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  int? _selectedAnswerIndex;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startQuiz();
    });
  }

  Future<void> _startQuiz() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);
    await quizProvider.startQuiz(
      userId: widget.userId,
      quizType: widget.quizType,
      subject: widget.subject,
      examType: widget.examType,
      durationInMinutes: widget.durationInMinutes,
      mockExamId: widget.mockExamId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Quiz'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<QuizProvider>(
            builder: (context, quizProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      quizProvider.formattedRemainingTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, child) {
          if (quizProvider.isLoading && quizProvider.currentSession == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading quiz...'),
                ],
              ),
            );
          }

          if (quizProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${quizProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Retry',
                    onPressed: _startQuiz,
                  ),
                ],
              ),
            );
          }

          if (quizProvider.currentQuestion == null) {
            return const Center(
              child: Text('No questions available'),
            );
          }

          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(quizProvider),

              // Question content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuestionCard(quizProvider.currentQuestion!),
                      const SizedBox(height: 24),
                      _buildOptionsSection(quizProvider.currentQuestion!),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(quizProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${quizProvider.currentQuestionNumber} of ${quizProvider.totalQuestions}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${quizProvider.answeredQuestions} answered',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: quizProvider.progressPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionModel question) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    question.examType,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(question.difficultyLevel)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyText(question.difficultyLevel),
                    style: TextStyle(
                      color: _getDifficultyColor(question.difficultyLevel),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            if (question.imageUrl != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  question.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 48,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(QuestionModel question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose the correct answer:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...question.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAnswerIndex = index;
              });
            },
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _selectedAnswerIndex == index
                      ? AppColors.primary
                      : Colors.grey[300]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: _selectedAnswerIndex == index
                    ? AppColors.primary.withOpacity(0.05)
                    : Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedAnswerIndex == index
                            ? AppColors.primary
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                      color: _selectedAnswerIndex == index
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                    child: _selectedAnswerIndex == index
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedAnswerIndex == index
                          ? AppColors.primary
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedAnswerIndex == index
                            ? AppColors.primary
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNavigationButtons(QuizProvider quizProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Skip button
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _isSubmitting ? null : () => _skipQuestion(quizProvider),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey[400]!),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Submit/Next button
          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: _isSubmitting
                  ? 'Submitting...'
                  : (quizProvider.hasNextQuestion
                      ? 'Next Question'
                      : 'Finish Quiz'),
              onPressed: _selectedAnswerIndex != null && !_isSubmitting
                  ? () => _submitAnswer(quizProvider)
                  : null,
              icon: _isSubmitting ? null : Icons.arrow_forward,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitAnswer(QuizProvider quizProvider) async {
    if (_selectedAnswerIndex == null) return;

    setState(() {
      _isSubmitting = true;
    });

    await quizProvider.submitAnswer(_selectedAnswerIndex!);

    setState(() {
      _isSubmitting = false;
      _selectedAnswerIndex = null;
    });

    // Check if quiz is completed
    if (quizProvider.isQuizCompleted) {
      _navigateToResults(quizProvider);
    }
  }

  Future<void> _skipQuestion(QuizProvider quizProvider) async {
    await quizProvider.skipQuestion();

    setState(() {
      _selectedAnswerIndex = null;
    });

    // Check if quiz is completed
    if (quizProvider.isQuizCompleted) {
      _navigateToResults(quizProvider);
    }
  }

  void _navigateToResults(QuizProvider quizProvider) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          sessionId: quizProvider.currentSession!.id,
        ),
      ),
    );
  }

  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }
}
