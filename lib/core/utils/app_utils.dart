import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Format a date to a readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format a time to a readable string
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  // Show a snackbar message
  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show a loading dialog
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }

  // Parse a duration string (e.g., "45m" to Duration)
  static Duration parseDuration(String durationStr) {
    if (durationStr.contains('h')) {
      final hours = int.parse(durationStr.split('h')[0]);
      return Duration(hours: hours);
    } else if (durationStr.contains('m')) {
      final minutes = int.parse(durationStr.split('m')[0]);
      return Duration(minutes: minutes);
    } else {
      // Default: 30 minutes
      return const Duration(minutes: 30);
    }
  }

  // Format a duration to a readable string (e.g., 1h 30m)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours${hours == 1 ? 'hr' : 'hrs'} ${minutes > 0 ? '$minutes${minutes == 1 ? 'min' : 'mins'}' : ''}';
    } else {
      return '$minutes${minutes == 1 ? 'min' : 'mins'}';
    }
  }

  // Format a percentage (e.g., 0.75 to 75%)
  static String formatPercentage(double percentage) {
    return '${(percentage * 100).toInt()}%';
  }

  // Check if user streak is maintained (used for streak calculations)
  static bool isStreakMaintained(DateTime lastLoginDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastLogin = DateTime(
      lastLoginDate.year,
      lastLoginDate.month,
      lastLoginDate.day,
    );

    // Streak is maintained if user logged in today or yesterday
    return lastLogin.isAtSameMomentAs(today) ||
        lastLogin.isAtSameMomentAs(yesterday);
  }

  // Convert milliseconds to seconds:minutes:seconds format
  static String formatMilliseconds(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;

    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = remainingSeconds.toString().padLeft(2, '0');

    return '$minutesStr:$secondsStr';
  }

  // Generate a random quiz ID
  static String generateQuizId() {
    return 'quiz_${DateTime.now().millisecondsSinceEpoch}';
  }
}
