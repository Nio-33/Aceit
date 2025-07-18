import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/error_handler.dart';
import '../../../widgets/common/primary_button.dart';
import '../providers/auth_provider.dart';
import '../screens/department_selection_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// Email verification screen that guides users through the email verification process
class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerifying = false;
  bool _isResending = false;
  Timer? _timer;
  int _timerSeconds = 0;
  int _pollAttempts = 0;
  final int _maxPollAttempts =
      30; // Check for 5 minutes (30 attempts * 10 seconds)
  final int _resendCooldown = 60; // 60 seconds cooldown for resend button

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Start checking if the email has been verified at regular intervals
  void _startVerificationCheck() {
    // Reset poll attempts
    _pollAttempts = 0;

    // Check immediately first time
    _checkEmailVerification();

    // Then start polling every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      _pollAttempts++;

      // Stop checking after max attempts
      if (_pollAttempts >= _maxPollAttempts) {
        timer.cancel();
        return;
      }

      await _checkEmailVerification();
    });
  }

  /// Check if the user's email has been verified
  Future<void> _checkEmailVerification() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoading) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      // Force user reload before checking verification status
      await authProvider.reloadUser();

      // Add a timeout to prevent hanging
      final isVerified = await authProvider
          .checkEmailVerified()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        print('Email verification check timed out');
        return false;
      });

      if (!mounted) return;

      if (isVerified) {
        _timer?.cancel();
        // Add a short delay to ensure we're ready to navigate
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          // Navigate to department selection instead of dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DepartmentSelectionScreen(),
            ),
          );
        }
      } else {
        // Show a message to the user that they need to check their email
        if (_pollAttempts % 3 == 0 && mounted) {
          // Show every 3 attempts (30 seconds)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Please check your email and click the verification link'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error during verification check: $e');
      if (mounted) {
        // Only show dialog for serious errors, not timeouts
        if (e is! TimeoutException) {
          ErrorHandler.showErrorDialog(
            context,
            'Verification Check Failed',
            e,
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// Force verification manual check with user feedback
  Future<void> _forceVerificationCheck() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoading) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      // Show feedback that we're checking
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checking verification status...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Force user reload
      await authProvider.reloadUser();

      // Add a timeout to prevent hanging
      final isVerified = await authProvider
          .checkEmailVerified()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        print('Manual email verification check timed out');
        return false;
      });

      if (!mounted) return;

      if (isVerified) {
        _timer?.cancel();
        // Add a short delay to ensure we're ready to navigate
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          // Navigate to department selection
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DepartmentSelectionScreen(),
            ),
          );
        }
      } else {
        // Show a clearer message about what to do
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Email not verified yet. Please check your inbox and click the verification link.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      print('Error during manual verification check: $e');
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          'Verification Check Failed',
          e,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  /// Resend verification email
  Future<void> _resendVerificationEmail() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isLoading) return;

    setState(() {
      _isResending = true;
    });

    try {
      await authProvider.sendEmailVerification();

      // Start cooldown timer
      setState(() {
        _timerSeconds = _resendCooldown;
      });

      // Setup timer for cooldown
      Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timerSeconds <= 0) {
          timer.cancel();
        } else {
          setState(() {
            _timerSeconds--;
          });
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          'Email Sending Failed',
          e,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  /// Sign out user
  Future<void> _signOut() async {
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signOut();

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorDialog(
          context,
          'Sign Out Failed',
          e,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final email = user?.email ?? 'your email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
          // Add a debug option to bypass verification in development mode
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.developer_mode),
              onPressed: () {
                _timer?.cancel();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DepartmentSelectionScreen(),
                  ),
                );
              },
              tooltip: 'Dev Override - Skip to Department Selection',
            ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Debug bypass button for development
              if (kDebugMode)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade800),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Development Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _timer?.cancel();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DepartmentSelectionScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.skip_next),
                        label: const Text('Bypass Email Verification'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

              // Email Verification Animation/Image
              SizedBox(
                height: 200,
                child: FutureBuilder(
                  future: _lottieExists(
                      'assets/animations/email_verification.json'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData &&
                        snapshot.data == true) {
                      return Lottie.asset(
                        'assets/animations/email_verification.json',
                        fit: BoxFit.contain,
                      );
                    } else {
                      // Fallback to icon if animation not available
                      return Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(24),
                        child: const Icon(
                          Icons.mark_email_read,
                          size: 100,
                          color: AppTheme.primaryColor,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verify Your Email',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 16),

              // Instructions
              Text(
                'We\'ve sent a verification email to:',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),

              // Email display
              Text(
                email,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Instructions
              Text(
                'Please check your email and click the verification link to continue.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Verify button
              PrimaryButton(
                text: 'I\'ve Verified My Email',
                isLoading: _isVerifying,
                onPressed: _forceVerificationCheck,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 16),

              // Resend email button
              TextButton.icon(
                onPressed: _timerSeconds > 0 || _isResending
                    ? null
                    : _resendVerificationEmail,
                icon: const Icon(Icons.refresh),
                label: Text(
                  _timerSeconds > 0
                      ? 'Resend Email (${_timerSeconds}s)'
                      : 'Resend Verification Email',
                ),
              ),
              const SizedBox(height: 32),

              // Help text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Can\'t find the email?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Check your spam or junk folder\n'
                      '• Make sure your email address is correct\n'
                      '• Try resending the verification email\n'
                      '• Contact support if the issue persists',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check if Lottie animation file exists
  Future<bool> _lottieExists(String assetPath) async {
    try {
      // For the sake of this example, we're assuming the file exists
      // In a real app, we might need to check if the file actually exists
      return true;
    } catch (e) {
      return false;
    }
  }
}
