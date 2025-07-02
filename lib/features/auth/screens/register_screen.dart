import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/app.dart'; // For AppRoutes
import 'package:betwizz_app/features/auth/notifiers/auth_notifier.dart';
import 'package:betwizz_app/features/auth/models/auth_state.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final saIdController = TextEditingController();

    // Listen to auth state changes for navigation and error messages
    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (_, state) {
      state.whenData((authState) {
        if (authState is Authenticated) {
          // PRD implies FICA check might be next. For now, direct to dashboard.
          // Actual flow might be: Register -> Prompt FICA -> Dashboard
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.channelDashboard, (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration successful! Welcome ${authState.user.displayName ?? authState.user.email}')),
          );
        } else if (authState is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Error: ${authState.message}')),
          );
        }
      });
    });

    final authStateAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Betwizz - Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username (Optional)',
                  // Note: Firebase Auth doesn't directly use username for email/password auth.
                  // This would typically be saved to a user profile in Firestore.
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (min. 6 characters)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: saIdController,
                decoration: const InputDecoration(
                  labelText: 'SA ID Number (for FICA - Placeholder)',
                  // Note: This data needs to be handled by a separate FICA verification flow.
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              if (authStateAsync.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    // final String username = usernameController.text.trim(); // For profile
                    // final String saId = saIdController.text.trim(); // For FICA flow

                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter email and password.')),
                      );
                      return;
                    }
                    // Basic password validation (Firebase will also validate)
                    if (password.length < 6) {
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password must be at least 6 characters.')),
                      );
                      return;
                    }

                    ref.read(authNotifierProvider.notifier).signUpWithEmailAndPassword(email, password);
                  },
                  child: const Text('Register'),
                ),
              TextButton(
                onPressed: authStateAsync.isLoading ? null : () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // Go back to Login Screen
                  }
                },
                child: const Text('Already have an account? Login'),
              ),
              const SizedBox(height: 20),
              // SA Compliance: Age verification gate (SA ID scan) - Placeholder
              const Text(
                'Compliance: Age verification and FICA are required.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
