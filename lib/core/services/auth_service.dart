import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/user_model.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

/// Service class responsible for authentication-related operations.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  
  bool _isFirebaseInitialized = false;

  /// Initialize Firebase services
  void _initializeFirebase() {
    if (!_isFirebaseInitialized) {
      try {
        _auth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
        _isFirebaseInitialized = true;
      } catch (e) {
        print('AuthService: Firebase not initialized: $e');
        _isFirebaseInitialized = false;
      }
    }
  }

  /// Get current user
  User? get currentUser {
    _initializeFirebase();
    return _auth?.currentUser;
  }
  
  /// Stream of auth state changes
  Stream<User?> get authStateChanges {
    _initializeFirebase();
    return _auth?.authStateChanges() ?? Stream.value(null);
  }
  
  /// Register with email and password
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String department,
    required List<String> selectedSubjects,
  }) async {
    try {
      _initializeFirebase();
      
      if (!_isFirebaseInitialized || _auth == null || _firestore == null) {
        throw Exception('Firebase is not properly configured. Please check your setup.');
      }
      
      print('AuthService.registerWithEmailAndPassword: Starting registration for email: $email');
      
      // Create user with email and password
      print('AuthService.registerWithEmailAndPassword: Creating Firebase auth user');
      final UserCredential result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('AuthService.registerWithEmailAndPassword: User created in Firebase Auth');
      
      // Get user from result
      final User? user = result.user;
      
      if (user != null) {
        // Send email verification
        print('AuthService.registerWithEmailAndPassword: Sending verification email');
        await user.sendEmailVerification();
        print('AuthService.registerWithEmailAndPassword: Verification email sent');
        
        // Create user model
        final UserModel userModel = UserModel(
          id: user.uid,
          name: name,
          email: email,
          department: department,
          selectedSubjects: selectedSubjects,
          currentStreak: 0,
          lastLoginDate: DateTime.now(),
          points: 0,
          emailVerified: false,
        );
        
        // Save user to Firestore
        print('AuthService.registerWithEmailAndPassword: Saving user to Firestore');
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toJson());
        print('AuthService.registerWithEmailAndPassword: User saved to Firestore');
        
        // Save user info to shared preferences
        print('AuthService.registerWithEmailAndPassword: Saving user to SharedPreferences');
        await _saveUserLocally(userModel);
        print('AuthService.registerWithEmailAndPassword: User saved to SharedPreferences');
        
        print('AuthService.registerWithEmailAndPassword: Registration completed successfully');
        return userModel;
      }
      
      print('AuthService.registerWithEmailAndPassword: User object is null after creation');
      throw Exception('Failed to create user account.');
    } catch (e, stackTrace) {
      print('AuthService.registerWithEmailAndPassword: Error during registration: $e');
      ErrorHandler.logError('AuthService.registerWithEmailAndPassword', e, stackTrace);
      
      // Transform Firebase Auth exceptions to more user-friendly errors
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            throw Exception('This email is already registered. Please use a different email or sign in.');
          case 'invalid-email':
            throw Exception('Invalid email format. Please enter a valid email address.');
          case 'weak-password':
            throw Exception('Password is too weak. Please use a stronger password.');
          case 'operation-not-allowed':
            throw Exception('Email/password registration is not enabled. Please contact support.');
          default:
            throw Exception('Registration failed: ${e.message}');
        }
      }
      
      throw e; // Rethrow to let calling code handle the error with context
    }
  }
  
  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _initializeFirebase();
      
      if (!_isFirebaseInitialized || _auth == null || _firestore == null) {
        throw Exception('Firebase is not properly configured. Please check your setup.');
      }
      
      print('AuthService.signInWithEmailAndPassword: Starting login for email: $email');
      
      // Sign in user with email and password
      print('AuthService.signInWithEmailAndPassword: Calling Firebase auth');
      final UserCredential result = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('AuthService.signInWithEmailAndPassword: Firebase auth result received');
      
      // Get user from result
      final User? user = result.user;
      
      if (user == null) {
        print('AuthService.signInWithEmailAndPassword: User is null after sign in');
        throw Exception('Authentication failed. Please try again.');
      }
      
      print('AuthService.signInWithEmailAndPassword: Got user with ID: ${user.uid}');
      
      // Get user data from Firestore
      print('AuthService.signInWithEmailAndPassword: Fetching user data from Firestore');
      final DocumentSnapshot userDoc = await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        print('AuthService.signInWithEmailAndPassword: User document not found in Firestore');
        throw Exception('User profile not found. Please contact support.');
      }
      
      print('AuthService.signInWithEmailAndPassword: User document found in Firestore');
      
      // Create user model from document data
      final UserModel userModel = UserModel.fromJson(
        {'id': user.uid, ...userDoc.data() as Map<String, dynamic>}
      );
      
      // Update last login date and email verification status
      final updatedUser = userModel.copyWith(
        lastLoginDate: DateTime.now(),
        emailVerified: user.emailVerified,
      );
      
      // Update user in Firestore
      print('AuthService.signInWithEmailAndPassword: Updating last login date in Firestore');
      await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
            'lastLoginDate': DateTime.now(),
            'emailVerified': user.emailVerified,
          });
      
      // Save user info to shared preferences
      print('AuthService.signInWithEmailAndPassword: Saving user to SharedPreferences');
      await _saveUserLocally(updatedUser);
      
      print('AuthService.signInWithEmailAndPassword: Login successful, returning user model');
      return updatedUser;
    } catch (e, stackTrace) {
      print('AuthService.signInWithEmailAndPassword: Error during login: $e');
      ErrorHandler.logError('AuthService.signInWithEmailAndPassword', e, stackTrace);
      throw e; // Rethrow to let calling code handle the error with context
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      // Clear shared preferences
      await _clearUserLocally();
      
      // Sign out user if Firebase is initialized
      if (_isFirebaseInitialized && _auth != null) {
        await _auth!.signOut();
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService.signOut', e, stackTrace);
      throw e;
    }
  }
  
  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      _initializeFirebase();
      
      if (!_isFirebaseInitialized || _auth == null) {
        throw Exception('Firebase is not properly configured. Please check your setup.');
      }
      
      await _auth!.sendPasswordResetEmail(email: email);
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService.resetPassword', e, stackTrace);
      
      // Add specific handling for Firebase Auth exceptions
      if (e is FirebaseAuthException) {
        // Firebase will return user-not-found if the email doesn't exist
        // We rethrow this so the UI can show an appropriate message
        switch (e.code) {
          case 'user-not-found':
          case 'invalid-email':
            throw Exception('No account found with this email address: ${e.message}');
          case 'too-many-requests':
            throw Exception('Too many password reset attempts. Please try again later.');
          case 'network-request-failed':
            throw Exception('Network connection issue. Please check your internet connection.');
          default:
            throw Exception('Error sending password reset email: ${e.code} - ${e.message}');
        }
      }
      
      throw e;
    }
  }
  
  /// Send email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      _initializeFirebase();
      
      if (!_isFirebaseInitialized || _auth == null) {
        throw Exception('Firebase is not properly configured. Please check your setup.');
      }
      
      final user = _auth!.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService.sendEmailVerification', e, stackTrace);
      throw e;
    }
  }
  
  /// Check if current user's email is verified
  Future<bool> checkEmailVerified() async {
    try {
      _initializeFirebase();
      
      if (!_isFirebaseInitialized || _auth == null) {
        print('Firebase not initialized during verification check');
        return false;
      }
      
      // Reload user to get the latest email verification status
      final currentUser = _auth!.currentUser;
      if (currentUser == null) {
        print('No user is currently signed in during verification check');
        return false;
      }
      
      try {
        await currentUser.reload();
      } catch (reloadError) {
        print('Error reloading user: $reloadError');
        // Continue with the current user data even if reload fails
      }
      
      final user = _auth!.currentUser; // Get user again after reload
      
      if (user != null) {
        final bool emailVerified = user.emailVerified;
        print('Email verification status: $emailVerified');
        
        // If email is verified, update the user model in Firestore
        if (emailVerified) {
          try {
            await _firestore!
                .collection(AppConstants.usersCollection)
                .doc(user.uid)
                .update({'emailVerified': true});
                
            // Update local storage too
            final userModel = await getUserFromFirestore(user.uid);
            if (userModel != null) {
              final updatedUser = userModel.copyWith(emailVerified: true);
              await _saveUserLocally(updatedUser);
            }
          } catch (updateError) {
            print('Error updating verification status: $updateError');
            // Continue even if update fails - the important thing is we know email is verified
          }
        }
        
        return emailVerified;
      }
      print('User is null after reload during verification check');
      return false;
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService.checkEmailVerified', e, stackTrace);
      print('Error checking email verification: $e');
      return false;
    }
  }
  
  /// Force reload the current Firebase user
  Future<void> reloadUser() async {
    try {
      _initializeFirebase();
      
      if (!_isFirebaseInitialized || _auth == null) {
        print('Firebase not initialized during user reload');
        return;
      }
      
      final currentUser = _auth!.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
        print('User reloaded successfully');
      } else {
        print('Cannot reload: No user is currently signed in');
      }
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService.reloadUser', e, stackTrace);
      print('Error reloading user: $e');
      // We don't rethrow as this is meant to be a silent operation
    }
  }
  
  /// Check if email exists in Firebase Auth
  Future<bool> doesEmailExist(String email) async {
    try {
      _initializeFirebase();
      
      if (!_isFirebaseInitialized || _auth == null) {
        print('Firebase not initialized during email existence check');
        return false;
      }
      
      final List<String> methods = await _auth!.fetchSignInMethodsForEmail(email);
      return methods.isNotEmpty;
    } catch (e, stackTrace) {
      // Log the error but don't rethrow since we're just checking email existence
      ErrorHandler.logError('AuthService.doesEmailExist', e, stackTrace);
      
      // Check if it's a specific error about non-existent email
      if (e is FirebaseAuthException && e.code == 'user-not-found') {
        return false;
      }
      
      // For other errors, assume the email might exist to avoid blocking legitimate recovery attempts
      // This prevents configuration issues or network problems from blocking password resets
      print('Warning: Error checking email existence, proceeding with reset process: $e');
      return true;
    }
  }
  
  /// Save user info to shared preferences
  Future<void> _saveUserLocally(UserModel user) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(AppConstants.userIdKey, user.id);
      await prefs.setString(AppConstants.userNameKey, user.name);
      await prefs.setString(AppConstants.userEmailKey, user.email);
      await prefs.setString(AppConstants.selectedDepartmentKey, user.department);
      await prefs.setStringList(AppConstants.selectedSubjectsKey, user.selectedSubjects);
      await prefs.setInt(AppConstants.currentStreakKey, user.currentStreak);
      await prefs.setString(AppConstants.lastLoginDateKey, user.lastLoginDate.toIso8601String());
      await prefs.setInt(AppConstants.pointsKey, user.points);
      await prefs.setBool(AppConstants.emailVerifiedKey, user.emailVerified);
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService._saveUserLocally', e, stackTrace);
      // Don't rethrow as this is an internal method
    }
  }
  
  /// Clear user info from shared preferences
  Future<void> _clearUserLocally() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(AppConstants.userIdKey);
      await prefs.remove(AppConstants.userNameKey);
      await prefs.remove(AppConstants.userEmailKey);
      await prefs.remove(AppConstants.selectedDepartmentKey);
      await prefs.remove(AppConstants.selectedSubjectsKey);
      await prefs.remove(AppConstants.currentStreakKey);
      await prefs.remove(AppConstants.lastLoginDateKey);
      await prefs.remove(AppConstants.pointsKey);
      await prefs.remove(AppConstants.emailVerifiedKey);
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService._clearUserLocally', e, stackTrace);
      // Don't rethrow as this is an internal method
    }
  }
  
  /// Get user from shared preferences
  Future<UserModel?> getUserFromPrefs() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final String? userId = prefs.getString(AppConstants.userIdKey);
      
      if (userId == null) {
        return null;
      }
      
      return UserModel(
        id: userId,
        name: prefs.getString(AppConstants.userNameKey) ?? 'User',
        email: prefs.getString(AppConstants.userEmailKey) ?? '',
        department: prefs.getString(AppConstants.selectedDepartmentKey) ?? 'Science',
        selectedSubjects: prefs.getStringList(AppConstants.selectedSubjectsKey) ?? [],
        currentStreak: prefs.getInt(AppConstants.currentStreakKey) ?? 0,
        lastLoginDate: DateTime.parse(
          prefs.getString(AppConstants.lastLoginDateKey) ?? DateTime.now().toIso8601String(),
        ),
        points: prefs.getInt(AppConstants.pointsKey) ?? 0,
        emailVerified: prefs.getBool(AppConstants.emailVerifiedKey) ?? false,
      );
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService.getUserFromPrefs', e, stackTrace);
      return null;
    }
  }
  
  /// Get user from Firestore
  Future<UserModel?> getUserFromFirestore(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _firestore!
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        return UserModel.fromJson({
          'id': userId,
          ...userDoc.data() as Map<String, dynamic>,
        });
      }
      
      return null;
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService.getUserFromFirestore', e, stackTrace);
      return null;
    }
  }
  
  /// Update user profile in Firestore
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? department,
    List<String>? selectedSubjects,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      
      if (name != null) updateData['name'] = name;
      if (department != null) updateData['department'] = department;
      if (selectedSubjects != null) updateData['selectedSubjects'] = selectedSubjects;
      
      // Only update if there's something to update
      if (updateData.isNotEmpty) {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update(updateData);
      }
      
      // Get the updated user
      final updatedUser = await getUserFromFirestore(userId);
      if (updatedUser == null) {
        throw Exception('Failed to retrieve updated user profile');
      }
      
      // Update local storage
      await _saveUserLocally(updatedUser);
      
      return updatedUser;
    } catch (e, stackTrace) {
      ErrorHandler.logError('AuthService.updateUserProfile', e, stackTrace);
      throw e;
    }
  }
  
  /// Check if Firebase Auth is properly initialized
  Future<bool> checkFirebaseInitialized() async {
    try {
      // Simple check - try to get current user state
      // This shouldn't throw an error if Firebase Auth is properly initialized
      final user = _auth!.currentUser;
      print('AuthService.checkFirebaseInitialized: Firebase Auth is initialized, user: ${user?.uid ?? 'null'}');
      return true;
    } catch (e, stackTrace) {
      print('AuthService.checkFirebaseInitialized: Firebase Auth may not be initialized - $e');
      ErrorHandler.logError('AuthService.checkFirebaseInitialized', e, stackTrace);
      return false;
    }
  }
} 