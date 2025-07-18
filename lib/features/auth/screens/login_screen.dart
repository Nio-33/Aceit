import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

import '../providers/auth_provider.dart';

/// Login screen for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirebaseConfig();
    });
  }

  Future<void> _checkFirebaseConfig() async {
    try {
      // Wait a moment for Firebase to initialize
      await Future.delayed(const Duration(seconds: 1));

      // Try to check if Firebase Auth is initialized
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isInitialized = await authProvider.isFirebaseInitialized();

      if (!isInitialized && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Firebase Authentication may not be properly configured. Some features may not work."),
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error checking Firebase configuration: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address")),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your password")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('LoginScreen: Starting login process...');

      // Set a timeout to prevent infinite loading
      bool timeoutOccurred = false;
      Future.delayed(const Duration(seconds: 10), () {
        if (_isLoading && mounted) {
          print('LoginScreen: Login timeout occurred');
          timeoutOccurred = true;
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Login attempt timed out. Firebase may not be properly configured."),
              duration: Duration(seconds: 5),
            ),
          );
        }
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Only proceed with login if timeout hasn't occurred
      if (!timeoutOccurred) {
        await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        print('LoginScreen: Login successful, checking verification status...');

        if (mounted && !timeoutOccurred) {
          if (authProvider.isEmailNotVerified) {
            print(
                'LoginScreen: Email not verified, navigating to verification screen');
            Navigator.pushReplacementNamed(
                context, AppConstants.emailVerificationRoute);
          } else {
            print('LoginScreen: Email verified, navigating to dashboard');
            Navigator.pushReplacementNamed(
                context, AppConstants.dashboardRoute);
          }
        }
      }
    } catch (e) {
      print('LoginScreen: Login error: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        String errorMessage = "Login failed";
        if (e.toString().contains('user-not-found')) {
          errorMessage = "No account found with this email address";
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = "Incorrect password";
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = "Network error. Please check your internet connection";
        } else if (e.toString().contains('CONFIGURATION_NOT_FOUND')) {
          errorMessage =
              "Firebase Authentication is not properly configured. Please check Firebase setup.";
        } else {
          errorMessage = "Login failed: ${e.toString()}";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        print('LoginScreen: Clearing loading state');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Add Firebase diagnostic button in the app bar
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            tooltip: 'Check Firebase Health',
            onPressed: () {
              // FirebaseHealthChecker().showHealthCheckDialog(context); // This line is removed
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    const Center(
                      child: Icon(
                        Icons.school,
                        size: 80,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password field with visibility toggle
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                    ),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, AppConstants.forgotPasswordRoute);
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: AppTheme.primaryColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Login button
                    ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child:
                          const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 32),

                    // Divider
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppConstants.registerRoute,
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
