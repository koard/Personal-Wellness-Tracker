import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  // Get user document by UID
  static Future<UserModel?> getUserByUid(String uid) async {
    try {
      final doc = await _db.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Create or update user document
  static Future<bool> createOrUpdateUser(UserModel user) async {
    try {
      await _db.collection(_usersCollection).doc(user.uid).set(
        user.copyWith(updatedAt: DateTime.now()).toMap(),
        SetOptions(merge: true),
      );
      return true;
    } catch (e) {
      print('Error creating/updating user: $e');
      return false;
    }
  }

  // Create user document from Firebase Auth user
  static Future<bool> createUserFromAuth(User authUser) async {
    try {
      final existingUser = await getUserByUid(authUser.uid);
      if (existingUser != null) {
        // User already exists, just update basic info
        final updatedUser = existingUser.copyWith(
          name: authUser.displayName,
          email: authUser.email,
          profileImage: authUser.photoURL,
          updatedAt: DateTime.now(),
        );
        return await createOrUpdateUser(updatedUser);
      } else {
        // Create new user document
        final newUser = UserModel(
          uid: authUser.uid,
          name: authUser.displayName,
          email: authUser.email,
          profileImage: authUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        return await createOrUpdateUser(newUser);
      }
    } catch (e) {
      print('Error creating user from auth: $e');
      return false;
    }
  }

  // Update user profile (now supports onboarding flags)
  static Future<bool> updateUserProfile({
    required String uid,
    String? name,
    String? profileImage,
    bool? isProfileSetupComplete,
    bool? isOnboardingComplete,
    String? preferredLanguage,
    // Legacy fields for backwards compatibility
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? goal,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updateData['name'] = name;
      if (profileImage != null) updateData['profileImage'] = profileImage;
      if (isProfileSetupComplete != null) updateData['isProfileSetupComplete'] = isProfileSetupComplete;
      if (isOnboardingComplete != null) updateData['isOnboardingComplete'] = isOnboardingComplete;
      if (preferredLanguage != null) updateData['preferredLanguage'] = preferredLanguage;
      
      // Legacy fields
      if (age != null) updateData['age'] = age;
      if (gender != null) updateData['gender'] = gender;
      if (height != null) updateData['height'] = height;
      if (weight != null) updateData['weight'] = weight;
      if (goal != null) updateData['goal'] = goal;

      await _db.collection(_usersCollection).doc(uid).set(updateData, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  // Delete user document
  static Future<bool> deleteUser(String uid) async {
    try {
      await _db.collection(_usersCollection).doc(uid).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Stream user document changes
  static Stream<UserModel?> streamUser(String uid) {
    return _db.collection(_usersCollection).doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromDocument(doc);
      }
      return null;
    });
  }

  // Sample method to create test user data (for development purposes)
  static Future<bool> createSampleUserData(String uid) async {
    try {
      final sampleUser = UserModel(
        uid: uid,
        name: 'punsloss',
        email: 'pun@chayen.com',
        profileImage: 'https://ih1.redbubble.net/image.549834939.8099/raf,360x360,075,t,fafafa:ca443f4786.jpg',
        age: 20,
        gender: 'chayen',
        height: 200.0,
        weight: 70.0,
        goal: 'Be No.1 Chayen Drinker',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      return await createOrUpdateUser(sampleUser);
    } catch (e) {
      print('Error creating sample user data: $e');
      return false;
    }
  }
}
