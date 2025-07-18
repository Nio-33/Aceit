import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/flashcard_provider.dart';
import '../screens/flashcard_study_screen.dart';
import '../../../widgets/common/primary_button.dart';

class FlashcardListScreen extends StatefulWidget {
  const FlashcardListScreen({super.key});

  @override
  State<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends State<FlashcardListScreen> {
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFlashcardData();
    });
  }

  Future<void> _loadFlashcardData() async {
    final flashcardProvider =
        Provider.of<FlashcardProvider>(context, listen: false);
    await flashcardProvider.loadSubjects();
    await flashcardProvider.loadAllFlashcards();
  }

  void _startStudySession(String subject) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to start studying')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashcardStudyScreen(
          userId: user.id,
          subject: subject,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search
            },
          ),
        ],
      ),
      body: Consumer<FlashcardProvider>(
        builder: (context, flashcardProvider, child) {
          return RefreshIndicator(
            onRefresh: _loadFlashcardData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                const Text(
                  'Study with Flashcards',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Flashcards are a great way to memorize key concepts and formulas',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Loading state
                if (flashcardProvider.isLoading) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],

                // Error state
                if (flashcardProvider.error != null) ...[
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[600],
                            size: 48,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            flashcardProvider.error!,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            text: 'Retry',
                            onPressed: _loadFlashcardData,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Subjects
                if (flashcardProvider.subjects.isNotEmpty) ...[
                  const Text(
                    'Study by Subject',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subject cards
                  ...flashcardProvider.subjects.map((subject) {
                    final subjectFlashcards = flashcardProvider.allFlashcards
                        .where((card) => card.subject == subject)
                        .toList();

                    return _buildSubjectCard(
                      subject: subject,
                      cardCount: subjectFlashcards.length,
                      flashcardProvider: flashcardProvider,
                    );
                  }).toList(),
                ] else if (!flashcardProvider.isLoading &&
                    flashcardProvider.error == null) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.style_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Flashcards Available',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Please seed sample data from the admin panel to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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

  Widget _buildSubjectCard({
    required String subject,
    required int cardCount,
    required FlashcardProvider flashcardProvider,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          child: Text(
            subject[0],
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(subject),
        subtitle: Text('$cardCount flashcards available'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _startStudySession(subject),
      ),
    );
  }

  Widget _buildRecentFlashcardSet({
    required String subject,
    required int cardCount,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          // Navigate to flashcard set
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Stacked cards effect
            Positioned(
              top: 4,
              left: 4,
              right: 0,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              right: 0,
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Main card
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.flip,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  Text(
                    subject,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$cardCount cards',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
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
