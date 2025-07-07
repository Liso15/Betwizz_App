import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/features/auth/models/auth_state.dart';
import 'package:betwizz_app/features/auth/models/user_model.dart';
import 'package:betwizz_app/features/auth/services/auth_service.dart';
import 'package:betwizz_app/features/user_profile/services/user_db_service.dart'; // Import UserDbService provider

// Provider for the AuthService implementation
// This allows us to easily swap out the implementation if needed (e.g., for testing)
final authServiceProvider = Provider<AuthService>((ref) {
  // FirebaseAuthService now depends on UserDbService
  final userDbService = ref.watch(userDbServiceProvider);
  return FirebaseAuthService(userDbService: userDbService);
});

// The AuthNotifier using AsyncNotifier for managing asynchronous auth state
class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthService _authService;

  @override
  FutureOr<AuthState> build() {
    _authService = ref.watch(authServiceProvider);
    // Listen to the stream of authentication state changes from the service
    // This helps in automatically updating state if auth changes outside of direct calls
    // (e.g. token expiry, external sign out)
    ref.listenSelf((_, next) {
      if (next is AsyncData<AuthState>) {
        final authStateValue = next.value;
        if (authStateValue is Authenticated) {
          print("AuthNotifier: User Authenticated - ${authStateValue.user}");
        } else if (authStateValue is Unauthenticated) {
          print("AuthNotifier: User Unauthenticated");
        }
      }
    });

    // Initial check for current user state
    return _checkInitialAuthState();
  }

  Future<AuthState> _checkInitialAuthState() async {
    try {
      final UserModel? user = await _authService.getCurrentUser();
      if (user != null) {
        return Authenticated(user: user);
      } else {
        return const Unauthenticated();
      }
    } catch (e) {
      return AuthError(message: e.toString());
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading(); // Set state to loading
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      state = AsyncValue.data(Authenticated(user: user)); // Update state to authenticated
    } catch (e) {
      state = AsyncValue.data(AuthError(message: e.toString())); // Update state with error
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.signUpWithEmailAndPassword(email, password);
      // Typically after sign up, you might want to auto-sign-in or ask user to verify email.
      // For now, we'll treat it as authenticated.
      state = AsyncValue.data(Authenticated(user: user));
    } catch (e) {
      state = AsyncValue.data(AuthError(message: e.toString()));
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(Unauthenticated()); // Update state to unauthenticated
    } catch (e) {
      state = AsyncValue.data(AuthError(message: e.toString()));
    }
  }

  // A method to manually trigger re-checking auth state if needed
  Future<void> checkAuthState() async {
    state = const AsyncLoading(); // Use Riverpod's AsyncLoading
    state = await AsyncValue.guard(() async { // AsyncValue.guard handles try-catch for us
      final user = await _authService.getCurrentUser();
      if (user != null) {
        return Authenticated(user: user);
      }
      return const Unauthenticated();
    });
  }
}

// The global provider for the AuthNotifier and its state
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
