import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/primary_button.dart';

/// Welcome screen shown after logout or for first-time users
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 32),

                // App Title
                const Text(
                  'Welcome to AceIt',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // App Description
                const Text(
                  'Your personalized learning companion for Nigerian national exams',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Get Started Button (Onboarding)
                PrimaryButton(
                  text: 'Get Started',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      AppConstants.onboardingRoute,
                    );
                  },
                  width: double.infinity,
                  backgroundColor: Colors.white,
                  textColor: AppTheme.primaryColor,
                  fontSize: 18,
                ),

                const SizedBox(height: 16),

                // Login Button
                PrimaryButton(
                  text: 'I Have an Account',
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(
                      AppConstants.loginRoute,
                    );
                  },
                  width: double.infinity,
                  backgroundColor: Colors.transparent,
                  textColor: Colors.white,
                  borderColor: Colors.white,
                  fontSize: 18,
                ),

                const Spacer(),

                // Footer text
                const Text(
                  'Ace your WAEC, JAMB, and NECO exams\nwith confidence',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
