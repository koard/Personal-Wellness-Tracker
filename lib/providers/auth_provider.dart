import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Test provider with delay to ensure splash screen is visible
final authStateChangesWithDelayProvider = StreamProvider<User?>((ref) async* {
  await Future.delayed(const Duration(seconds: 3)); // 3 second delay for testing
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    yield user;
  }
});
