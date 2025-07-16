import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/common/primary_button.dart';
import 'package:lottie/lottie.dart';

/// Onboarding screen shown to first-time users
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _lottieController;
  int _currentPage = 0;
  bool _isLoading = true;
  String? _errorMessage;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to AceIt',
      description: 'Your personalized learning companion for Nigerian national exams. Prepare effectively for WAEC, JAMB, and NECO with our comprehensive study tools.',
      lottieAsset: 'assets/animations/study.json',
      color: AppTheme.primaryColor,
    ),
    OnboardingPage(
      title: 'Practice Makes Perfect',
      description: 'Take realistic mock exams, daily quizzes, and use flashcards to reinforce key concepts. Our questions are carefully curated to match real exam patterns.',
      lottieAsset: 'assets/animations/practice.json',
      color: const Color(0xFF4CAF50),
    ),
    OnboardingPage(
      title: 'Track Your Progress',
      description: 'Monitor your improvement over time with detailed analytics. Identify your strengths and weaknesses to focus your studies more effectively.',
      lottieAsset: 'assets/animations/progress.json',
      color: const Color(0xFFFF9800),
    ),
    OnboardingPage(
      title: 'Compete & Collaborate',
      description: 'Join the leaderboard, compete with friends, and earn achievements. Stay motivated with daily streaks and rewards for consistent studying.',
      lottieAsset: 'assets/animations/progress.json',
      color: const Color(0xFF9C27B0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    debugPrint('OnboardingScreen: initState called');
    
    try {
      _lottieController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 2),
      );
      _lottieController.forward();
      debugPrint('OnboardingScreen: Lottie controller initialized');
      
      // Set loading to false after a short delay
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      debugPrint('OnboardingScreen: Error in initState: $e');
      setState(() {
        _errorMessage = 'Error initializing: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    debugPrint('OnboardingScreen: dispose called');
    try {
      _pageController.dispose();
      _lottieController.dispose();
    } catch (e) {
      debugPrint('OnboardingScreen: Error in dispose: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('OnboardingScreen: build called');
    
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background with dynamic color
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _pages[_currentPage].color,
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                // Background pattern
                Positioned(
                  top: -screenHeight * 0.1,
                  right: -screenWidth * 0.2,
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenWidth * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -screenHeight * 0.1,
                  left: -screenWidth * 0.2,
                  child: Opacity(
                    opacity: 0.1,
                    child: Container(
                      width: screenWidth * 0.8,
                      height: screenWidth * 0.8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              debugPrint('OnboardingScreen: Page changed to $index');
              setState(() {
                _currentPage = index;
                _lottieController.reset();
                _lottieController.forward();
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: TextButton(
              onPressed: _completeOnboarding,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index == _currentPage),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      _currentPage > 0
                          ? IconButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            )
                          : const SizedBox(width: 48),
                      
                      // Next/Done button
                      PrimaryButton(
                        text: _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        width: 200,
                        backgroundColor: Colors.white,
                        textColor: _pages[_currentPage].color,
                      ),
                      
                      // Placeholder for symmetry
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPage(OnboardingPage page) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            
            // Animation
            SizedBox(
              height: 240,
              child: FutureBuilder(
                future: _loadLottieAsset(page.lottieAsset),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && 
                      snapshot.hasData && 
                      snapshot.data == true) {
                    try {
                      return Lottie.asset(
                        page.lottieAsset,
                        controller: _lottieController,
                        fit: BoxFit.contain,
                        height: 240,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('OnboardingScreen: Lottie error: $error');
                          return _buildPlaceholderIcon(page);
                        },
                      );
                    } catch (e) {
                      debugPrint('OnboardingScreen: Error loading Lottie: $e');
                      return _buildPlaceholderIcon(page);
                    }
                  } else {
                    // Placeholder if Lottie asset is not available
                    return _buildPlaceholderIcon(page);
                  }
                },
              ),
            ),
            const SizedBox(height: 48),
            
            // Title
            Text(
              page.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Description
            Text(
              page.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceholderIcon(OnboardingPage page) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          _getIconForPage(page),
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  IconData _getIconForPage(OnboardingPage page) {
    final index = _pages.indexOf(page);
    switch (index) {
      case 0:
        return Icons.school;
      case 1:
        return Icons.quiz;
      case 2:
        return Icons.trending_up;
      case 3:
        return Icons.leaderboard;
      default:
        return Icons.star;
    }
  }
  
  Future<bool> _loadLottieAsset(String asset) async {
    try {
      debugPrint('OnboardingScreen: Loading Lottie asset: $asset');
      // Check if the asset exists
      return true; // In a real app, we would actually check if the file exists
    } catch (e) {
      debugPrint('OnboardingScreen: Error checking Lottie asset: $e');
      return false;
    }
  }
  
  void _completeOnboarding() async {
    debugPrint('OnboardingScreen: Completing onboarding');
    try {
      // Save onboarding completed status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingCompletedKey, true);
      debugPrint('OnboardingScreen: Onboarding completed saved');
      
      // Navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
      }
    } catch (e) {
      debugPrint('OnboardingScreen: Error completing onboarding: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppConstants.loginRoute);
      }
    }
  }
}

/// Data class for onboarding page content
class OnboardingPage {
  final String title;
  final String description;
  final String lottieAsset;
  final Color color;
  
  OnboardingPage({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
  });
} 