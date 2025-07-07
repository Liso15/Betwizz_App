import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:betwizz_app/app.dart'; // For AppRoutes
import 'package:betwizz_app/features/auth/notifiers/auth_notifier.dart';
import 'package:betwizz_app/features/auth/models/auth_state.dart';

class LoginScreen extends ConsumerWidget { // Changed to ConsumerWidget
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // Listen to the auth state for navigation and error handling
    ref.listen<AsyncValue<AuthState>>(authNotifierProvider, (_, state) {
      state.whenData((authState) {
        if (authState is Authenticated) {
          Navigator.pushReplacementNamed(context, AppRoutes.channelDashboard);
        } else if (authState is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login Error: ${authState.message}')),
          );
        }
      });
    });

    final authStateAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Betwizz - Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Login Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField( // Changed to stateful TextField
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (test@example.com)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField( // Changed to stateful TextField
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password (password)',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              if (authStateAsync.isLoading) // Show loading indicator
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () {
                    final email = emailController.text;
                    final password = passwordController.text;
                    if (email.isNotEmpty && password.isNotEmpty) {
                      ref.read(authNotifierProvider.notifier).signInWithEmailAndPassword(email, password);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter email and password')),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
              TextButton(
                onPressed: authStateAsync.isLoading ? null : () { // Disable button when loading
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                child: const Text('Don\'t have an account? Register'),
              ),
              const SizedBox(height: 20),
              // SA Compliance: Age verification gate (SA ID scan) - Placeholder
              const Text(
                'Note: Age verification (SA ID scan) will be required.',
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
