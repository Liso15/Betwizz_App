import 'package:betwizz_app/features/auth/models/user_model.dart';

// Abstract AuthService defining the contract
abstract class AuthService {
  Future<UserModel?> getCurrentUser();
  Future<UserModel> signInWithEmailAndPassword(String email, String password);
  Future<UserModel> signUpWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  Stream<UserModel?> get authStateChanges; // To listen for auth state changes
}

// Concrete implementation - Placeholder for Firebase Auth
class FirebaseAuthService implements AuthService {
  // Simulate a stream of user authentication state
  // In a real app, this would wrap FirebaseAuth.instance.authStateChanges()
  @override
  Stream<UserModel?> get authStateChanges async* {
    // Initially, no user is logged in
    yield null;
    // In a real app, Firebase would emit events here. We simulate a login after some time for testing.
    // For this placeholder, it will just yield null and won't simulate a login automatically.
    // The AuthNotifier will handle the actual login simulation via signIn.
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // Simulate checking for current user
    await Future.delayed(const Duration(milliseconds: 300));
    // Return null as we assume no user is logged in initially for the placeholder
    return null;
    // Or return a dummy user if you want to simulate an already logged-in state:
    // return const UserModel(uid: 'dummyUID', email: 'test@example.com', displayName: 'Dummy User');
  }

  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (email == 'test@example.com' && password == 'password') {
      return UserModel(uid: 'testUID123', email: email, displayName: 'Test User');
    } else if (email == 'error@example.com') {
      throw Exception('Simulated login error: Invalid credentials');
    } else {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (email.contains('@') && password.length > 6) {
      // In a real app, this would create a user in Firebase
      return UserModel(uid: 'newUserUID456', email: email, displayName: 'New User');
    } else if (email == 'exists@example.com') {
      throw Exception('Simulated sign up error: Email already exists');
    }
    else {
      throw Exception('Invalid email or password format for sign up');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    // In a real app, this would call FirebaseAuth.instance.signOut()
    print('User signed out (simulated)');
  }
}
