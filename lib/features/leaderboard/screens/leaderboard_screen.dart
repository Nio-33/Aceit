import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;
    
    // Create mock leaderboard data
    final leaderboardUsers = List.generate(
      20,
      (index) => LeaderboardUser(
        id: 'user_$index',
        name: 'User ${index + 1}',
        points: 1000 - (index * 42),
        rank: index + 1,
        department: index % 3 == 0 
            ? 'Science' 
            : (index % 3 == 1 ? 'Arts' : 'Commercial'),
      ),
    );
    
    // Find current user's position
    int currentUserPosition = -1;
    if (currentUser != null) {
      for (int i = 0; i < leaderboardUsers.length; i++) {
        if (leaderboardUsers[i].points <= currentUser.points) {
          currentUserPosition = i;
          break;
        }
      }
      
      if (currentUserPosition == -1) {
        currentUserPosition = leaderboardUsers.length;
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter options
            },
          ),
        ],
      ),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header section with user's rank
                _buildUserRankCard(
                  context,
                  currentUser.name,
                  currentUser.points,
                  currentUserPosition + 1,
                  currentUser.department,
                ),
                
                // Tabs for switching between Weekly/Monthly/All-time
                _buildLeaderboardTabs(context),
                
                // Leaderboard list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: leaderboardUsers.length,
                    itemBuilder: (context, index) {
                      final user = leaderboardUsers[index];
                      
                      return _buildLeaderboardItem(
                        context: context,
                        user: user,
                        isCurrentUser: index == currentUserPosition,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
  
  Widget _buildUserRankCard(
    BuildContext context,
    String name,
    int points,
    int rank,
    String department,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Trophy icon or medal depending on rank
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Icon(
              rank <= 3 ? Icons.emoji_events : Icons.military_tech,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        department,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Your current rank: #$rank',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total points: $points',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLeaderboardTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          _buildTab(context, 'Weekly', isSelected: false),
          _buildTab(context, 'Monthly', isSelected: false),
          _buildTab(context, 'All Time', isSelected: true),
        ],
      ),
    );
  }
  
  Widget _buildTab(BuildContext context, String title, {required bool isSelected}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          // Switch tab
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeaderboardItem({
    required BuildContext context,
    required LeaderboardUser user,
    required bool isCurrentUser,
  }) {
    // Determine medal color for top 3
    Color? medalColor;
    IconData rankIcon = Icons.emoji_events;
    
    if (user.rank == 1) {
      medalColor = Colors.amber; // Gold
    } else if (user.rank == 2) {
      medalColor = const Color(0xFFC0C0C0); // Silver
    } else if (user.rank == 3) {
      medalColor = const Color(0xFFCD7F32); // Bronze
    } else {
      rankIcon = Icons.military_tech;
      medalColor = Colors.grey[700];
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: isCurrentUser 
                  ? AppTheme.primaryColor.withOpacity(0.2) 
                  : Colors.grey[200],
              child: user.rank <= 3 
                  ? Icon(
                      rankIcon,
                      color: medalColor,
                      size: 24,
                    )
                  : Text(
                      '${user.rank}',
                      style: TextStyle(
                        color: isCurrentUser 
                            ? AppTheme.primaryColor 
                            : Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(user.department),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isCurrentUser 
                ? AppTheme.primaryColor 
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${user.points} pts',
            style: TextStyle(
              color: isCurrentUser ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class LeaderboardUser {
  final String id;
  final String name;
  final int points;
  final int rank;
  final String department;
  
  LeaderboardUser({
    required this.id,
    required this.name,
    required this.points,
    required this.rank,
    required this.department,
  });
} 