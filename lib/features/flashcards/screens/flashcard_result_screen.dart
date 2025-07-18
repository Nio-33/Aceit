import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:aceit/models/study_session_model.dart';
import 'package:aceit/core/services/flashcard_service.dart';
import 'package:aceit/widgets/common/primary_button.dart';
import 'package:aceit/core/theme/app_colors.dart';
import 'package:aceit/core/constants/app_constants.dart';
import 'package:aceit/features/dashboard/screens/dashboard_screen.dart';
import 'package:aceit/features/flashcards/screens/flashcard_list_screen.dart';

class FlashcardResultScreen extends StatefulWidget {
  final String sessionId;

  const FlashcardResultScreen({
    super.key,
    required this.sessionId,
  });

  @override
  State<FlashcardResultScreen> createState() => _FlashcardResultScreenState();
}

class _FlashcardResultScreenState extends State<FlashcardResultScreen> {
  final FlashcardService _flashcardService = FlashcardService();
  FlashcardSessionModel? _session;
  bool _isLoading = true;
  String? _error;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _loadSession();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    try {
      _session = await _flashcardService.getFlashcardSession(widget.sessionId);

      // Show confetti if good performance
      if (_session!.accuracy >= 80) {
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
        title: const Text('Study Session Results'),
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
                  Text('Loading results...'),
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
                    onPressed: _loadSession,
                  ),
                ],
              ),
            )
          else if (_session != null)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResultHeader(),
                  const SizedBox(height: 24),
                  _buildPerformanceCard(),
                  const SizedBox(height: 24),
                  _buildStudyTimeCard(),
                  const SizedBox(height: 24),
                  _buildConfidenceAnalysis(),
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
    final accuracy = _session!.accuracy;
    final isGoodPerformance = accuracy >= 80;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGoodPerformance
              ? [Colors.green[400]!, Colors.green[600]!]
              : accuracy >= 60
                  ? [Colors.orange[400]!, Colors.orange[600]!]
                  : [Colors.red[400]!, Colors.red[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            isGoodPerformance ? Icons.celebration : Icons.lightbulb_outline,
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            isGoodPerformance ? 'Great Job!' : 'Keep Practicing!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isGoodPerformance
                ? 'You\'re mastering this subject!'
                : 'Every study session makes you stronger!',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            '${_session!.subject} Study Session',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Accuracy circle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_session!.accuracy.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        'Accuracy',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(
                  'Correct',
                  _session!.correctCount.toString(),
                  Colors.green,
                  Icons.check_circle,
                ),
                _buildStatColumn(
                  'Incorrect',
                  _session!.incorrectCount.toString(),
                  Colors.red,
                  Icons.cancel,
                ),
                _buildStatColumn(
                  'Skipped',
                  _session!.skippedCount.toString(),
                  Colors.orange,
                  Icons.skip_next,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Progress bar
            Text(
              'Cards Studied: ${_session!.studiedCards} / ${_session!.totalCards}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _session!.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
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

  Widget _buildStudyTimeCard() {
    final duration = _session!.baseSession.actualDuration;
    final studyRate =
        _session!.studiedCards / (duration.inMinutes.clamp(1, double.infinity));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Study Time Analysis',
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
                  _session!.baseSession.formattedDuration,
                  Icons.timer,
                ),
                _buildTimeItem(
                  'Study Rate',
                  '${studyRate.toStringAsFixed(1)} cards/min',
                  Icons.speed,
                ),
                _buildTimeItem(
                  'Points Earned',
                  _session!.baseSession.pointsEarned.toString(),
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

  Widget _buildConfidenceAnalysis() {
    final confidenceLevels = <int, int>{};

    // Count confidence levels
    for (final progress in _session!.cardProgress.values) {
      confidenceLevels[progress.confidenceLevel] =
          (confidenceLevels[progress.confidenceLevel] ?? 0) + 1;
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confidence Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (confidenceLevels.isNotEmpty) ...[
              ...confidenceLevels.entries.map((entry) {
                final level = entry.key;
                final count = entry.value;
                final percentage = (count / _session!.studiedCards) * 100;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          'Level $level',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getConfidenceColor(level),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count (${percentage.toStringAsFixed(0)}%)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ] else ...[
              const Text(
                'No confidence data available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getConfidenceColor(int level) {
    switch (level) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        PrimaryButton(
          text: 'Study Again',
          onPressed: () {
            // Go back to flashcard list to start new session
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const FlashcardListScreen()),
              (route) => false,
            );
          },
          icon: Icons.refresh,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  // Show detailed review
                  _showDetailedReview();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Review Cards'),
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
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _session!.cardProgress.length,
                    itemBuilder: (context, index) {
                      final entry =
                          _session!.cardProgress.entries.elementAt(index);
                      final cardId = entry.key;
                      final progress = entry.value;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: progress.wasCorrect
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            child: Icon(
                              progress.wasCorrect ? Icons.check : Icons.close,
                              color: progress.wasCorrect
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text('Card ${index + 1}'),
                          subtitle: Text(
                            'Confidence: ${progress.confidenceLevel}/5 • ${progress.timeSpentInSeconds}s',
                          ),
                          trailing: Container(
                            width: 60,
                            height: 24,
                            decoration: BoxDecoration(
                              color:
                                  _getConfidenceColor(progress.confidenceLevel),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'L${progress.confidenceLevel}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
