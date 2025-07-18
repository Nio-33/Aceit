import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A centralized error handling utility for the AceIt app.
/// Provides standardized error messages and logging.
class ErrorHandler {
  /// Private constructor to prevent instantiation
  ErrorHandler._();

  /// Log error to console with standardized format
  static void logError(
    String source,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    if (kDebugMode) {
      print('ERROR [$source]: $error');
      if (stackTrace != null) {
        print('STACK TRACE: $stackTrace');
      }
    }

    // TODO: Implement remote error logging with Firebase Crashlytics
  }

  /// Handle errors and return user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      return _getFirebaseAuthErrorMessage(error);
    } else if (error is SocketException || error is TimeoutException) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (error is FormatException) {
      return 'Invalid data format. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  /// Get user-friendly messages for Firebase Auth errors
  static String _getFirebaseAuthErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this email. Please check your email or sign up.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email or sign in.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'invalid-email':
        return 'Invalid email format. Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase. Please contact the app administrator to enable authentication.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      default:
        // Special handling for the configuration_not_found error
        if (error.message?.contains('CONFIGURATION_NOT_FOUND') == true) {
          return 'Firebase Authentication is not properly configured. Please contact the app administrator.';
        }
        return 'Authentication error: ${error.message}';
    }
  }

  /// Show error dialog with appropriate message
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    dynamic error,
  ) async {
    final errorMessage = getErrorMessage(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Create a catch handler for async functions
  static Function(dynamic) createCatchHandler(
    String source, {
    Function(String)? onError,
  }) {
    return (error) {
      final stackTrace = StackTrace.current;
      logError(source, error, stackTrace);

      final errorMessage = getErrorMessage(error);
      if (onError != null) {
        onError(errorMessage);
      }
    };
  }
}
