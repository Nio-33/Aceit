import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../models/user_model.dart';

/// Authentication status enum
enum AuthStatus {
  /// Initial state, not yet determined
  uninitialized,
  
  /// User is authenticated
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
  
  /// User is authenticated but email not verified
  emailNotVerified,
}

/// Provider for managing authentication state and operations
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;
  
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  bool _isLoading = false;
  
  /// Current authentication status
  AuthStatus get status => _status;
  
  /// Current user data
  UserModel? get user => _user;
  
  /// Whether an authentication operation is in progress
  bool get isLoading => _isLoading;
  
  /// Whether the user is authenticated
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  
  /// Whether the user email is not verified
  bool get isEmailNotVerified => _status == AuthStatus.emailNotVerified;
  
  /// Constructor - sets up auth state listener
  AuthProvider() {
    try {
      // Listen for auth state changes
      _authService.authStateChanges.listen(_onAuthStateChanged);
    } catch (e) {
      // If Firebase is not initialized, just set status to unauthenticated
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
    // Try to get user from shared preferences
    _initializeUser();
  }
  
  /// Public method to reload the Firebase user
  Future<void> reloadUser() async {
    await _authService.reloadUser();
  }
  
  /// Handle Firebase auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }
    
    try {
      final user = await _authService.getUserFromFirestore(firebaseUser.uid);
      
      if (user != null) {
        _user = user;
        
        // Check if email is verified
        if (firebaseUser.emailVerified) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.emailNotVerified;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthProvider._onAuthStateChanged', e, stackTrace);
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }
  
  /// Initialize user from shared preferences or current Firebase user
  Future<void> _initializeUser() async {
    try {
      // First try to get user from shared preferences
      final prefsUser = await _authService.getUserFromPrefs();
      
      // If Firebase shows user is logged in, use that
      if (_authService.currentUser != null) {
        final firebaseUser = _authService.currentUser!;
        final firestoreUser = await _authService.getUserFromFirestore(firebaseUser.uid);
        
        if (firestoreUser != null) {
          _user = firestoreUser;
          
          // Check if email is verified
          if (firebaseUser.emailVerified) {
            _status = AuthStatus.authenticated;
          } else {
            _status = AuthStatus.emailNotVerified;
          }
          
          notifyListeners();
          return;
        }
      }
      
      // If no Firebase user but we have cached user, use that
      if (prefsUser != null) {
        _user = prefsUser;
        
        // If we have a cached user, respect the cached emailVerified flag
        if (prefsUser.emailVerified) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.emailNotVerified;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthProvider._initializeUser', e, stackTrace);
      _status = AuthStatus.unauthenticated;
    }
    
    notifyListeners();
  }
  
  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      print('AuthProvider.signIn: Attempting to sign in with email: $email');
      
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('AuthProvider.signIn: Sign in successful, got user: ${user.email}');
      
      _user = user;
      
      // Check if email is verified
      if (user.emailVerified) {
        print('AuthProvider.signIn: Email is verified, setting status to authenticated');
        _status = AuthStatus.authenticated;
      } else {
        print('AuthProvider.signIn: Email is NOT verified, setting status to emailNotVerified');
        _status = AuthStatus.emailNotVerified;
      }
    } catch (e, stackTrace) {
      print('AuthProvider.signIn: Error during sign in: $e');
      ErrorHandler.logError('AuthProvider.signIn', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('AuthProvider.signIn: Finished sign in process, isLoading set to false');
    }
  }
  
  /// Register with email and password
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String department,
    required List<String> selectedSubjects,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      print('AuthProvider.register: Starting registration for: $email');
      
      final user = await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        department: department,
        selectedSubjects: selectedSubjects,
      );
      
      print('AuthProvider.register: Registration successful for: $email');
      
      _user = user;
      _status = AuthStatus.emailNotVerified;
    } catch (e, stackTrace) {
      print('AuthProvider.register: Registration failed: $e');
      ErrorHandler.logError('AuthProvider.register', e, stackTrace);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      print('AuthProvider.register: Registration process completed');
    }
  }
  
  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.sendEmailVerification();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Check if current user's email is verified
  Future<bool> checkEmailVerified() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final bool isVerified = await _authService.checkEmailVerified();
      
      if (isVerified) {
        _status = AuthStatus.authenticated;
        
        // Update our local user model
        if (_user != null) {
          _user = _user!.copyWith(emailVerified: true);
        }
        
        notifyListeners();
      }
      
      return isVerified;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Sign out the current user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.signOut();
      _status = AuthStatus.unauthenticated;
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Reset password for the given email
  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _authService.resetPassword(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Check if an email already exists in Firebase
  /// 
  /// This method attempts to verify if the provided email is registered.
  /// If there's an error during verification (except for user-not-found),
  /// the method returns true to allow password reset attempts to proceed.
  /// This avoids revealing whether an email exists for security reasons
  /// and prevents legitimate reset attempts from being blocked by errors.
  Future<bool> checkEmailExists(String email) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      return await _authService.doesEmailExist(email);
    } catch (e, stackTrace) {
      // Log the error but don't present it to the user
      ErrorHandler.logError('AuthProvider.checkEmailExists', e, stackTrace);
      
      // Default to true for most errors to allow password reset to proceed
      // Firebase will handle non-existent emails gracefully in the resetPassword flow
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update the user's profile information
  Future<void> updateUserProfile({
    String? name,
    String? department,
    List<String>? selectedSubjects,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      if (_user == null) {
        throw Exception('No user is logged in');
      }
      
      final updatedUser = await _authService.updateUserProfile(
        userId: _user!.id,
        name: name,
        department: department,
        selectedSubjects: selectedSubjects,
      );
      
      _user = updatedUser;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update user data locally only (for when Firebase fails)
  void updateLocalUserData(UserModel user) {
    print('AuthProvider.updateLocalUserData: Updating user data locally');
    // Just update the in-memory user object
    _user = user;
    notifyListeners();
    print('AuthProvider.updateLocalUserData: Local user data updated');
  }
  
  /// Check if Firebase is initialized and Authentication is properly configured
  Future<bool> isFirebaseInitialized() async {
    try {
      // A simple way to check if Firebase Auth is working
      // If this doesn't throw an error, Firebase Auth is probably initialized
      await _authService.checkFirebaseInitialized();
      return true;
    } catch (e) {
      print('AuthProvider.isFirebaseInitialized: Firebase may not be initialized - $e');
      return false;
    }
  }
} 