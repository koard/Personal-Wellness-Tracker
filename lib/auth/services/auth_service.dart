import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<bool> signInWithEmail({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> registerWithEmail({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<void> signOut() async => _auth.signOut();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
