import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'core/theme/app_theme.dart';
import 'features/app.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/auth/screens/email_verification_screen.dart';

import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/settings/screens/firebase_diagnostic_screen.dart';
import 'core/config/firebase_config.dart';

import 'core/constants/app_constants.dart';
import 'env_example.dart';


// Global key for navigator to use in error handling
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Global error information for error screen
String? globalErrorMessage;
bool appStartupFailed = false;

void main() async {
  // Catch Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER ERROR: ${details.exception}');
    debugPrint('STACK TRACE: ${details.stack}');
    
    // Record the error for display
    globalErrorMessage = 'Flutter Error: ${details.exception}\n${details.stack}';
    appStartupFailed = true;
  };
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Flutter binding initialized');
    
    // Initialize Firebase with try-catch to gracefully handle errors
    bool firebaseInitialized = false;
    
    try {
      // Load hardcoded credentials first
      _loadHardcodedCredentials();
      debugPrint('Loaded hardcoded Firebase credentials');
      
      // Attempt to initialize Firebase but don't block app startup if it fails
      try {
        // For iOS, we need to handle the missing GoogleService-Info.plist gracefully
        if (FirebaseConfig.isConfigured) {
          await Firebase.initializeApp(
            options: FirebaseConfig.options,
          );
          firebaseInitialized = true;
          debugPrint('Firebase initialized successfully with configuration');
          
          // Check authentication setup
          await _checkAuthenticationSetup();
        } else {
          // Try default initialization for iOS
          try {
            await Firebase.initializeApp();
            firebaseInitialized = true;
            debugPrint('Firebase initialized with default configuration');
            
            // Check authentication setup
            await _checkAuthenticationSetup();
          } catch (firebaseError) {
            debugPrint('Firebase initialization failed: $firebaseError');
            debugPrint('App will run in demo mode without Firebase');
            // Don't re-throw the error, just continue without Firebase
          }
        }
      } catch (e) {
        debugPrint('Error initializing Firebase: $e');
        debugPrint('The app will run in demo mode without Firebase');
        // Don't re-throw the error, just continue without Firebase
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
      debugPrint('App will continue without full initialization');
      // Don't re-throw the error, just continue without Firebase
    }
    
    // Run the app, even with initialization failures
    runApp(MyApp(firebaseInitialized: firebaseInitialized));
    debugPrint('App started successfully');
  } catch (e, stackTrace) {
    // Capture any errors during startup
    debugPrint('CRITICAL ERROR DURING APP STARTUP: $e');
    debugPrint('STACK TRACE: $stackTrace');
    
    // Set global error info
    globalErrorMessage = 'Startup Error: $e\n$stackTrace';
    appStartupFailed = true;
    
    // Still try to run the app with an error screen
    runApp(const ErrorApp());
  }
}

/// Simple error app to show when startup fails
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AceIt Error',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'App Failed to Start',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  globalErrorMessage ?? 'Unknown error occurred',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    debugPrint('Attempting to restart app...');
                    main();
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Check if Email/Password authentication is properly set up
Future<void> _checkAuthenticationSetup() async {
  try {
    // Try to fetch sign-in methods to check if authentication is configured
    await firebase_auth.FirebaseAuth.instance.fetchSignInMethodsForEmail("test@example.com");
    debugPrint('✅ Firebase Authentication is properly configured');
  } catch (e) {
    if (e is firebase_auth.FirebaseAuthException) {
      if (e.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
        debugPrint('❌ FIREBASE AUTHENTICATION ERROR: ${e.message}');
        debugPrint('');
        debugPrint('👉 HOW TO FIX:');
        debugPrint('1. Go to the Firebase Console: https://console.firebase.google.com/');
        debugPrint('2. Select your project: "aceit-bd1c9"');
        debugPrint('3. Go to Authentication > Sign-in method');
        debugPrint('4. Enable the "Email/Password" sign-in method');
        debugPrint('5. Save the changes');
        debugPrint('');
      } else {
        debugPrint('⚠️ Firebase Auth check: ${e.message}');
      }
    } else {
      debugPrint('⚠️ Error checking authentication setup: $e');
    }
  }
}

/// Load hardcoded Firebase credentials into dotenv
void _loadHardcodedCredentials() {
  try {
    // Initialize dotenv if not already done
    if (!dotenv.isInitialized) {
      dotenv.testLoad();
    }
    
    // Set the environment variables
    dotenv.env['FIREBASE_API_KEY'] = FirebaseCredentials.apiKey;
    dotenv.env['FIREBASE_AUTH_DOMAIN'] = FirebaseCredentials.authDomain;
    dotenv.env['FIREBASE_PROJECT_ID'] = FirebaseCredentials.projectId;
    dotenv.env['FIREBASE_STORAGE_BUCKET'] = FirebaseCredentials.storageBucket;
    dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] = FirebaseCredentials.messagingSenderId;
    dotenv.env['FIREBASE_APP_ID'] = FirebaseCredentials.appId;
    dotenv.env['FIREBASE_MEASUREMENT_ID'] = FirebaseCredentials.measurementId;
    debugPrint('Firebase credentials loaded into dotenv successfully');
  } catch (e) {
    debugPrint('Error loading hardcoded credentials: $e');
    // Continue without dotenv if it fails
  }
}

class MyApp extends StatelessWidget {
  final bool firebaseInitialized;
  final bool forceOnboarding;
  
  const MyApp({super.key, this.firebaseInitialized = false, this.forceOnboarding = false});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire MaterialApp with MultiProvider to ensure all routes have access to providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'AceIt',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        // Show error screen if startup failed
        home: appStartupFailed 
            ? const ErrorApp() 
            : (forceOnboarding ? const OnboardingScreen() : const TestScreen()),
        routes: {
          AppConstants.loginRoute: (context) => const LoginScreen(),
          AppConstants.registerRoute: (context) => const RegisterScreen(),
          AppConstants.forgotPasswordRoute: (context) => const ForgotPasswordScreen(),
          AppConstants.emailVerificationRoute: (context) => const EmailVerificationScreen(),
          AppConstants.dashboardRoute: (context) => const DashboardScreen(),
          AppConstants.firebaseDiagnosticRoute: (context) => const FirebaseDiagnosticScreen(),
          AppConstants.onboardingRoute: (context) => const OnboardingScreen(),
          // This route will need parameters, so we don't use it directly in named routes
          // Instead we'll use MaterialPageRoute in the register screen
        },
      ),
    );
  }
}

/// Simple test screen to isolate crash issues
class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AceIt Test'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.school,
              size: 100,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            const Text(
              'AceIt App',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'App is running successfully!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.onboardingRoute);
              },
              child: const Text('Go to Onboarding'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(AppConstants.loginRoute);
              },
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
