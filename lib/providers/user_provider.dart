import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

// Provider for the current Firebase Auth user
final authUserProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Provider for the current user's Firestore data
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authUser = ref.watch(authUserProvider);
  
  return authUser.when(
    data: (user) {
      if (user != null) {
        return FirestoreService.streamUser(user.uid);
      }
      return Stream.value(null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// Provider for user operations
final userServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// Future provider for getting user by UID
final getUserProvider = FutureProvider.family<UserModel?, String>((ref, uid) async {
  return await FirestoreService.getUserByUid(uid);
});
