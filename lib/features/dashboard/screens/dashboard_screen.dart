import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/streak_card.dart';
import '../../profile/screens/profile_screen.dart';
import '../../mock_exams/screens/mock_exam_list_screen.dart';
import '../../quizzes/screens/daily_quiz_screen.dart';
import '../../flashcards/screens/flashcard_list_screen.dart';
import '../../leaderboard/screens/leaderboard_screen.dart';
import '../../admin/screens/admin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _DashboardHomeScreen(),
    const MockExamListScreen(),
    const DailyQuizScreen(),
    const FlashcardListScreen(),
    const LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Mock Exams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            activeIcon: Icon(Icons.quiz),
            label: 'Quizzes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flip_outlined),
            activeIcon: Icon(Icons.flip),
            label: 'Flashcards',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
        ],
      ),
    );
  }
}

class _DashboardHomeScreen extends StatelessWidget {
  const _DashboardHomeScreen();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Add debug print to see user state
    print('DashboardScreen: Current user data: ${user?.toJson()}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                // Refresh dashboard data
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Welcome Text
                  Text(
                    'Hello, ${user.name}!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Let\'s continue your preparation for ${user.department} subjects.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Streak Card
                  StreakCard(
                    currentStreak: user.currentStreak,
                    lastLoginDate: user.lastLoginDate,
                  ),
                  const SizedBox(height: 24),

                  // Section: Quick Actions
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Dashboard Cards - Quick Actions
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      DashboardCard(
                        title: 'Daily Quiz',
                        icon: Icons.quiz,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DailyQuizScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Mock Exams',
                        icon: Icons.assignment,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MockExamListScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Flashcards',
                        icon: Icons.flip,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FlashcardListScreen(),
                            ),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Leaderboard',
                        icon: Icons.leaderboard,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section: Your Subjects
                  const Text(
                    'Your Subjects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Subjects List
                  ...user.selectedSubjects.map((subject) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.book),
                        title: Text(subject),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to subject details
                        },
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
