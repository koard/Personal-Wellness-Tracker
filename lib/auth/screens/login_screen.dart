import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../../widgets/shared/custom_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final success = await ref.read(authServiceProvider).signInWithEmail(
            email: emailCtrl.text.trim(),
            password: passwordCtrl.text.trim(),
          );
      setState(() => isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (val) =>
                    val != null && val.contains('@') ? null : 'Enter valid email',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) =>
                    val != null && val.length >= 6 ? null : 'Password too short',
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Login',
                onPressed: isLoading ? null : _login,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('No account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
