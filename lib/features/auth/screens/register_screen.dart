import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

import '../screens/email_verification_screen.dart';
// Remove the SocialAuthButton widgets for Google and Facebook sign-in, and their associated handler methods (_handleGoogleSignIn, _handleFacebookSignIn).
import '../../../core/services/firebase_health_checker.dart';

/// Registration screen for new user signup
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _handleRegister() async {
    // Basic validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your full name")),
      );
      return;
    }
    
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address")),
      );
      return;
    }
    
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters")),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    // Set up a timeout to avoid infinite loading
    bool timeoutOccurred = false;
    Future.delayed(const Duration(seconds: 15), () {
      if (_isLoading && mounted) {
        debugPrint('RegisterScreen: Registration timeout occurred');
        timeoutOccurred = true;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration timed out. Firebase may not be properly configured."),
            duration: Duration(seconds: 5),
          ),
        );

        // Offer user the option to proceed to email verification screen after timeout
        _showFirebaseErrorDialog();
      }
    });
    
    try {
      debugPrint('RegisterScreen: Attempting to register user...');
      
      // Only proceed if timeout hasn't occurred
      if (!timeoutOccurred) {
        // Get auth provider and register with default department and subjects
        // The user will select their real department and subjects after email verification
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        
        // Try a simpler registration first for debugging
        debugPrint('RegisterScreen: Registering with email: ${_emailController.text.trim()}');
        
        await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          department: 'Science', // Temporary default, will be updated after verification
          selectedSubjects: ['Mathematics', 'English'], // Temporary defaults, will be updated after verification
        );
        
        debugPrint('RegisterScreen: Registration successful, navigating to verification screen');
        
        if (mounted && !timeoutOccurred) {
          // Cancel timeout if registration was successful
          timeoutOccurred = true;
          
          // In debug mode, directly go to email verification to debug further
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const EmailVerificationScreen(),
            ),
          );
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created! Please verify your email.")),
          );
        }
      }
    } catch (e) {
      debugPrint('RegisterScreen: Registration failed: $e');
      if (mounted) {
        // Format user-friendly error message
        String errorMessage = "Registration failed";
        
        if (e.toString().contains('email-already-in-use')) {
          errorMessage = "This email is already registered. Please use a different email or sign in.";
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = "Invalid email format. Please enter a valid email address.";
        } else if (e.toString().contains('weak-password')) {
          errorMessage = "Password is too weak. Please use a stronger password.";
        } else if (e.toString().contains('network-request-failed')) {
          errorMessage = "Network error. Please check your internet connection and try again.";
        } else if (e.toString().contains('CONFIGURATION_NOT_FOUND')) {
          errorMessage = "Firebase Authentication is not properly configured. Please try again later.";
        } else {
          errorMessage = "Registration failed: ${e.toString()}";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        // Ensure loading state is reset
        debugPrint('RegisterScreen: Resetting loading state');
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Add a new method to show Firebase error dialog
  void _showFirebaseErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Firebase Configuration Issue'),
          content: const Text(
            'There seems to be an issue with Firebase configuration. Would you like to:\n\n'
            '1. Try again with Firebase\n'
            '2. Continue in development mode (skips Firebase auth)'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Try Again'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                
                // Bypass Firebase auth and proceed to email verification
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmailVerificationScreen(),
                  ),
                );
              },
              child: const Text('Continue in Dev Mode'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Add Firebase diagnostic button in the app bar
          IconButton(
            icon: const Icon(Icons.health_and_safety),
            tooltip: 'Check Firebase Health',
            onPressed: () {
              FirebaseHealthChecker().showHealthCheckDialog(context);
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
                  
                  // Name field
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter your full name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
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
                  
                  // Already have account row
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppConstants.loginRoute,
                        );
                      },
                      child: const Text('Already have an account?'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Register button
                  ElevatedButton(
                    onPressed: _handleRegister, // Use the register handler
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Create Account', style: TextStyle(fontSize: 16)),
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
                  
                  // Remove the SOCIAL BUTTONS section and related UI
                ],
              ),
            ),
          ),
    );
  }
} 