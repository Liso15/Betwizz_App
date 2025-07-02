import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:betwizz_app/features/auth/models/user_model.dart';
import 'package:betwizz_app/features/user_profile/services/user_db_service.dart'; // Import UserDbService

// Abstract AuthService defining the contract
abstract class AuthService {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges;
}

// Concrete implementation using Firebase Auth
class FirebaseAuthService implements AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth;
  final UserDbService _userDbService; // Add UserDbService dependency

  // Constructor updated to accept UserDbService
  FirebaseAuthService({
    fb_auth.FirebaseAuth? firebaseAuth,
    required UserDbService userDbService, // UserDbService is now required
  })  : _firebaseAuth = firebaseAuth ?? fb_auth.FirebaseAuth.instance,
        _userDbService = userDbService;

  // Helper to convert Firebase User to our UserModel
  UserModel? _userModelFromFirebase(fb_auth.User? firebaseUser) {
    if (firebaseUser == null) {
      return null;
    }
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
    );
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map(_userModelFromFirebase);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    return _userModelFromFirebase(firebaseUser);
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        // This case should ideally not happen if signInWithEmailAndPassword succeeds
        throw Exception('Login failed: No user data received.');
      }
      return _userModelFromFirebase(firebaseUser)!; // Non-null assertion as firebaseUser is checked
    } on fb_auth.FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth exceptions or rethrow a generic one
      // Example: e.code could be 'user-not-found', 'wrong-password', etc.
      throw Exception('Login failed: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('An unexpected error occurred during login: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Sign up failed: No user data received.');
      }
      // You might want to update the user's display name here if you collect it during sign up
      // For example, if a username is collected during registration:
      // if (username != null && username.isNotEmpty) {
      //   await firebaseUser.updateDisplayName(username);
      // }
      // Create UserModel from Firebase User
      final userModel = _userModelFromFirebase(firebaseUser);
      if (userModel == null) {
        // Should not happen if firebaseUser is not null
        throw Exception('Sign up succeeded but failed to map Firebase user.');
      }

      // Create user profile in Firestore
      try {
        await _userDbService.createUserProfile(userModel);
      } catch (dbError) {
        // Decide on error handling strategy:
        // 1. Rethrow and let AuthNotifier handle it (user auth exists, but profile creation failed).
        // 2. Delete the Firebase user and rethrow (more complex, makes signUp atomic).
        // 3. Log error and proceed (user auth exists, profile can be created later).
        // For now, rethrow, AuthNotifier will show a generic error.
        // A more specific error message might be useful for the user.
        throw Exception('Sign up successful, but failed to create user profile: ${dbError.toString()}');
      }

      return userModel;
    } on fb_auth.FirebaseAuthException catch (e) {
      // Example: e.code could be 'email-already-in-use', 'weak-password', etc.
      throw Exception('Sign up failed: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up: ${e.toString()}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on fb_auth.FirebaseAuthException catch (e) {
      throw Exception('Sign out failed: ${e.message} (Code: ${e.code})');
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out: ${e.toString()}');
    }
  }
}
