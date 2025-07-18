import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aceit/features/quiz/providers/quiz_provider.dart';
import 'package:aceit/models/exam_result_model.dart';
import 'package:aceit/widgets/common/primary_button.dart';
import 'package:aceit/core/theme/app_colors.dart';
import 'package:aceit/core/services/quiz_service.dart';
import 'package:aceit/core/constants/app_constants.dart';
import 'package:aceit/features/dashboard/screens/dashboard_screen.dart';
import 'package:confetti/confetti.dart';

class QuizResultScreen extends StatefulWidget {
  final String sessionId;

  const QuizResultScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  final QuizService _quizService = QuizService();
  ExamResultModel? _result;
  bool _isLoading = true;
  String? _error;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _loadResult();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadResult() async {
    try {
      _result = await _quizService.completeQuizSession(widget.sessionId);

      // Show confetti if passed
      if (_result!.passed) {
        _confettiController.play();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Calculating results...'),
                ],
              ),
            )
          else if (_error != null)
            Center(
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
                    'Error: $_error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Retry',
                    onPressed: _loadResult,
                  ),
                ],
              ),
            )
          else if (_result != null)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResultHeader(),
                  const SizedBox(height: 24),
                  _buildScoreCard(),
                  const SizedBox(height: 24),
                  _buildPerformanceBreakdown(),
                  const SizedBox(height: 24),
                  _buildTimeAnalysis(),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),

          // Confetti animation
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57, // pi/2 (downward)
              particleDrag: 0.05,
              emissionFrequency: 0.02,
              numberOfParticles: 50,
              gravity: 0.3,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultHeader() {
    final passed = _result!.passed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: passed
              ? [Colors.green[400]!, Colors.green[600]!]
              : [Colors.red[400]!, Colors.red[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            passed ? 'Congratulations!' : 'Better Luck Next Time!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            passed
                ? 'You have successfully passed the quiz!'
                : 'Don\'t worry, practice makes perfect!',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${_result!.score.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getGradeColor(_result!.grade).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Grade: ${_result!.grade}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: _getGradeColor(_result!.grade),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Correct',
                  _result!.correctAnswers.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatItem(
                  'Wrong',
                  _result!.wrongAnswers.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
                _buildStatItem(
                  'Skipped',
                  _result!.skippedQuestions.toString(),
                  Colors.orange,
                  Icons.skip_next,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformanceItem(
              'Accuracy',
              '${_result!.accuracy.toStringAsFixed(1)}%',
              _result!.accuracy / 100,
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildPerformanceItem(
              'Completion',
              '${(_result!.totalQuestions - _result!.skippedQuestions) / _result!.totalQuestions * 100}%',
              (_result!.totalQuestions - _result!.skippedQuestions) /
                  _result!.totalQuestions,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPerformanceItem(
              'Speed',
              '${_result!.averageTimePerQuestion.inSeconds}s per question',
              1.0, // Always full for demonstration
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(
      String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildTimeAnalysis() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Time Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeItem(
                  'Total Time',
                  _result!.formattedTime,
                  Icons.timer,
                ),
                _buildTimeItem(
                  'Avg per Question',
                  '${_result!.averageTimePerQuestion.inSeconds}s',
                  Icons.speed,
                ),
                _buildTimeItem(
                  'Points Earned',
                  _result!.pointsEarned.toString(),
                  Icons.stars,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: 'View Detailed Review',
          onPressed: () {
            // Navigate to detailed review screen
            _showDetailedReview();
          },
          icon: Icons.visibility,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Try again
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Try Again'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Go to dashboard by replacing the entire navigation stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const DashboardScreen()),
                    (route) => false,
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[400]!),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Dashboard'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showDetailedReview() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detailed Review',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (_result!.incorrectQuestionIds.isNotEmpty) ...[
                  const Text(
                    'Questions to Review:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: _result!.incorrectQuestionIds.length,
                      itemBuilder: (context, index) {
                        final questionId = _result!.incorrectQuestionIds[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red.withOpacity(0.1),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text('Question ${index + 1}'),
                            subtitle: Text('ID: $questionId'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              // Navigate to question review
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.celebration,
                          size: 64,
                          color: Colors.green,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Perfect Score!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('You answered all questions correctly!'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      case 'F':
        return Colors.red[800]!;
      default:
        return Colors.grey;
    }
  }
}
