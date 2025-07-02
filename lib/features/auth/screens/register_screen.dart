import 'package:flutter/material.dart';
// import 'package:betwizz_app/app.dart'; // For AppRoutes if needed for navigation back

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Betwizz - Register'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Register Screen',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Placeholder for username field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              // Placeholder for email field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              // Placeholder for password field
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              // Placeholder for FICA Verification / SA ID Scan - PRD 5.1 & 6.1
              const TextField(
                decoration: InputDecoration(
                  labelText: 'SA ID Number (for FICA)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement registration logic
                  // TODO: Implement FICA Verification Flow
                  // After successful registration and verification, navigate to login or dashboard
                  Navigator.pop(context); // Go back to login for now
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration Logic (Not Implemented)')),
                  );
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to Login Screen
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
