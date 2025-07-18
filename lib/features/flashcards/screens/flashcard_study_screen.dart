import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aceit/features/flashcards/providers/flashcard_provider.dart';
import 'package:aceit/features/flashcards/screens/flashcard_result_screen.dart';
import 'package:aceit/models/flashcard_model.dart';
import 'package:aceit/widgets/common/primary_button.dart';
import 'package:aceit/core/theme/app_colors.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final String userId;
  final String subject;
  final List<String>? specificFlashcardIds;

  const FlashcardStudyScreen({
    super.key,
    required this.userId,
    required this.subject,
    this.specificFlashcardIds,
  });

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  int _selectedConfidence = 3; // Default confidence level

  @override
  void initState() {
    super.initState();

    // Initialize flip animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _flipAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));

    // Start flashcard session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startFlashcardSession();
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _startFlashcardSession() async {
    final flashcardProvider =
        Provider.of<FlashcardProvider>(context, listen: false);
    await flashcardProvider.startFlashcardSession(
      userId: widget.userId,
      subject: widget.subject,
      specificFlashcardIds: widget.specificFlashcardIds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subject} Study'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, flashcardProvider, child) {
          if (flashcardProvider.isLoading &&
              flashcardProvider.currentSession == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading flashcards...'),
                ],
              ),
            );
          }

          if (flashcardProvider.error != null) {
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
                    'Error: ${flashcardProvider.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Retry',
                    onPressed: _startFlashcardSession,
                  ),
                ],
              ),
            );
          }

          if (flashcardProvider.currentFlashcard == null) {
            return const Center(
              child: Text('No flashcards available'),
            );
          }

          // Check if session is completed
          if (flashcardProvider.isSessionCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToResults(flashcardProvider);
            });
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Session completed! Loading results...'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(flashcardProvider),

              // Flashcard content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFlashcard(flashcardProvider.currentFlashcard!),
                      const SizedBox(height: 24),
                      if (flashcardProvider.isFlipped) ...[
                        _buildConfidenceSelector(),
                        const SizedBox(height: 16),
                        _buildActionButtons(flashcardProvider),
                      ] else ...[
                        _buildFlipButton(flashcardProvider),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressIndicator(FlashcardProvider flashcardProvider) {
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
                'Card ${flashcardProvider.currentCardNumber} of ${flashcardProvider.totalCards}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${flashcardProvider.studiedCards} studied',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: flashcardProvider.progressPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatChip(
                'Correct',
                flashcardProvider.correctCount.toString(),
                Colors.green,
              ),
              _buildStatChip(
                'Incorrect',
                flashcardProvider.incorrectCount.toString(),
                Colors.red,
              ),
              _buildStatChip(
                'Skipped',
                flashcardProvider.skippedCount.toString(),
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(FlashcardModel flashcard) {
    return GestureDetector(
      onTap: () {
        final flashcardProvider =
            Provider.of<FlashcardProvider>(context, listen: false);
        flashcardProvider.flipCard();

        if (flashcardProvider.isFlipped) {
          _flipController.forward();
        } else {
          _flipController.reverse();
        }
      },
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                height: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isShowingFront
                        ? [Colors.blue[50]!, Colors.blue[100]!]
                        : [Colors.green[50]!, Colors.green[100]!],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isShowingFront
                          ? Icons.help_outline
                          : Icons.lightbulb_outline,
                      size: 48,
                      color:
                          isShowingFront ? Colors.blue[600] : Colors.green[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isShowingFront ? 'QUESTION' : 'ANSWER',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isShowingFront
                            ? Colors.blue[600]
                            : Colors.green[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateY(isShowingFront ? 0 : 3.14159),
                          child: Text(
                            isShowingFront ? flashcard.front : flashcard.back,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFlipButton(FlashcardProvider flashcardProvider) {
    return Column(
      children: [
        Icon(
          Icons.touch_app,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap the card to reveal the answer',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          text: 'Reveal Answer',
          onPressed: () {
            flashcardProvider.flipCard();
            _flipController.forward();
          },
          icon: Icons.flip_to_back,
        ),
      ],
    );
  }

  Widget _buildConfidenceSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How confident are you with this answer?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final confidence = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedConfidence = confidence;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _selectedConfidence == confidence
                          ? AppColors.primary
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        confidence.toString(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _selectedConfidence == confidence
                              ? Colors.white
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Not confident', style: TextStyle(fontSize: 12)),
                Text('Very confident', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(FlashcardProvider flashcardProvider) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: flashcardProvider.isLoading
                    ? null
                    : () => _markFlashcard(flashcardProvider, false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Incorrect',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: 'Correct',
                onPressed: flashcardProvider.isLoading
                    ? null
                    : () => _markFlashcard(flashcardProvider, true),
                backgroundColor: Colors.green,
                icon: flashcardProvider.isLoading ? null : Icons.check,
                isLoading: flashcardProvider.isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: flashcardProvider.isLoading
                ? null
                : () => _skipFlashcard(flashcardProvider),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _markFlashcard(
      FlashcardProvider flashcardProvider, bool wasCorrect) async {
    await flashcardProvider.markFlashcard(
      wasCorrect: wasCorrect,
      confidenceLevel: _selectedConfidence,
    );

    // Reset flip animation and confidence for next card
    _flipController.reset();
    setState(() {
      _selectedConfidence = 3;
    });
  }

  Future<void> _skipFlashcard(FlashcardProvider flashcardProvider) async {
    await flashcardProvider.skipFlashcard();

    // Reset flip animation and confidence for next card
    _flipController.reset();
    setState(() {
      _selectedConfidence = 3;
    });
  }

  void _navigateToResults(FlashcardProvider flashcardProvider) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FlashcardResultScreen(
          sessionId: flashcardProvider.currentSession!.id,
        ),
      ),
    );
  }
}
