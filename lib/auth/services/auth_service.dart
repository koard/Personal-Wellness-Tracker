import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import 'dart:developer' as developer;

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<bool> signInWithEmail({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthService');
      return false;
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      if (userCredential.user != null) {
        final success = await FirestoreService.createUserFromAuth(userCredential.user!);
        if (!success) {
          developer.log('Failed to create user document in Firestore', name: 'AuthService');
        }
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('This email is already registered.');
      } else {
        throw Exception(e.message ?? 'An unknown error occurred.');
      }
    } catch (e) {
      developer.log('Registration error: $e', name: 'AuthService');
      return false;
    }
  }


  Future<void> signOut() async => _auth.signOut();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
