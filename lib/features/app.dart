import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/quiz/providers/quiz_provider.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/email_verification_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';

/// Main app container that handles routing and initialization
class AceItApp extends StatefulWidget {
  const AceItApp({super.key});

  @override
  State<AceItApp> createState() => _AceItAppState();
}

class _AceItAppState extends State<AceItApp> {
  bool _isOnboardingCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  /// Check if onboarding has been completed
  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isOnboardingCompleted = 
            prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
        _isLoading = false;
      });
    } catch (error) {
      // Fall back to showing onboarding if there's an error
      setState(() {
        _isOnboardingCompleted = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    print('AceItApp.build: AuthProvider status: ${authProvider.status}, isLoading: ${authProvider.isLoading}');
    
    // Show loading indicator while checking preferences
    if (_isLoading) {
      print('AceItApp.build: Showing loading screen (checking preferences)');
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show onboarding if not completed
    if (!_isOnboardingCompleted) {
      print('AceItApp.build: Showing onboarding screen');
      return const OnboardingScreen();
    }

    // Show appropriate screen based on authentication status
    switch (authProvider.status) {
      case AuthStatus.uninitialized:
        print('AceItApp.build: Showing loading screen (auth uninitialized)');
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      case AuthStatus.unauthenticated:
        print('AceItApp.build: Showing welcome screen (unauthenticated)');
        return const WelcomeScreen();
      case AuthStatus.authenticated:
        print('AceItApp.build: Showing dashboard screen (authenticated)');
        return const DashboardScreen();
      case AuthStatus.emailNotVerified:
        print('AceItApp.build: Showing email verification screen');
        return const EmailVerificationScreen();
    }
  }
} 