import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool isLoading = false;

  // สำหรับ toggle password visibility
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        final success = await ref.read(authServiceProvider).registerWithEmail(
          email: emailCtrl.text.trim(),
          password: passwordCtrl.text.trim(),
        );

        setState(() => isLoading = false);

        if (!mounted) return;

        if (success) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.green[50],
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Registration Successful!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.of(context)
              ..pop() // ปิด dialog
              ..pop(); // กลับไปหน้า login
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration failed.')),
          );
        }
      } on Exception catch (e) {
        setState(() => isLoading = false);

        // แสดง SnackBar แจ้ง error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) =>
                        val != null && val.contains('@') ? null : 'Enter valid email',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      labelText: 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) =>
                        val != null && val.length >= 6 ? null : 'Minimum 6 characters',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline),
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (val) =>
                        val == passwordCtrl.text ? null : 'Passwords do not match',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isLoading ? 'Registering...' : 'Register',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
