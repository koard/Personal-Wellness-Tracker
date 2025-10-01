import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';

/// Service for managing comprehensive user profiles
class UserProfileService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  static DocumentReference get _userProfileDoc =>
      _db.collection('users').doc(_uid).collection('profile').doc('data');

  /// Get user profile
  static Future<UserProfile?> getUserProfile([String? userId]) async {
    try {
      final uid = userId ?? _uid;
      final doc = await _db
          .collection('users')
          .doc(uid)
          .collection('profile')
          .doc('data')
          .get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Create or update user profile
  static Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );

      await _userProfileDoc.set(
        updatedProfile.toFirestore(),
        SetOptions(merge: true),
      );

      // Update the basic user model to mark profile as complete
      await _db.collection('users').doc(_uid).set({
        'isProfileSetupComplete': updatedProfile.isProfileComplete,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  /// Update specific profile fields
  static Future<bool> updateProfileFields(Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());
      await _userProfileDoc.set(updates, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating profile fields: $e');
      return false;
    }
  }

  /// Stream user profile changes
  static Stream<UserProfile?> streamUserProfile([String? userId]) {
    final uid = userId ?? _uid;
    return _db
        .collection('users')
        .doc(uid)
        .collection('profile')
        .doc('data')
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Check if profile setup is complete
  static Future<bool> isProfileComplete([String? userId]) async {
    try {
      final profile = await getUserProfile(userId);
      return profile?.isProfileComplete ?? false;
    } catch (e) {
      print('Error checking profile completion: $e');
      return false;
    }
  }

  /// Calculate and update AI targets (BMR, TDEE, water intake)
  static Future<bool> calculateAndUpdateTargets(UserProfile profile) async {
    try {
      final calculatedTargets = {
        'targetCalories': profile.tdee,
        'targetWaterIntake': profile.recommendedWaterIntake,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await _userProfileDoc.set(calculatedTargets, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error calculating targets: $e');
      return false;
    }
  }

  /// Get profile completion percentage for onboarding progress
  static double getProfileCompletionPercentage(UserProfile profile) {
    int completedFields = 0;
    int totalFields = 15; // Essential fields for AI analysis

    if (profile.name.isNotEmpty) completedFields++;
    if (profile.age > 0) completedFields++;
    if (profile.gender.isNotEmpty) completedFields++;
    if (profile.weight > 0) completedFields++;
    if (profile.height > 0) completedFields++;
    if (profile.primaryGoal.isNotEmpty) completedFields++;
    if (profile.fitnessLevel.isNotEmpty) completedFields++;
    if (profile.availableWorkoutTime > 0) completedFields++;
    if (profile.preferredActivities.isNotEmpty) completedFields++;
    if (profile.targetSleepHours > 0) completedFields++;
    if (profile.workSchedule.isNotEmpty) completedFields++;
    if (profile.activityLevel.isNotEmpty) completedFields++;
    if (profile.dietaryPreferences.preferredCuisines.isNotEmpty) completedFields++;
    if (profile.sleepPreferences.currentSleepQuality > 0) completedFields++;
    if (profile.exerciseIntensity > 0) completedFields++;

    return completedFields / totalFields;
  }

  /// Mark profile as complete and ready for AI analysis
  static Future<bool> markProfileComplete() async {
    try {
      await _userProfileDoc.set({
        'isProfileComplete': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      await _db.collection('users').doc(_uid).set({
        'isProfileSetupComplete': true,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error marking profile complete: $e');
      return false;
    }
  }

  /// Delete user profile
  static Future<bool> deleteUserProfile() async {
    try {
      await _userProfileDoc.delete();
      return true;
    } catch (e) {
      print('Error deleting user profile: $e');
      return false;
    }
  }

  /// Create initial profile from basic user data
  static Future<UserProfile> createInitialProfile({
    required String name,
    String email = '',
  }) async {
    return UserProfile(
      userId: _uid,
      name: name,
      age: 25, // Default values that user will update
      gender: 'other',
      weight: 70.0,
      height: 170.0,
      primaryGoal: 'general_fitness',
      fitnessLevel: 'beginner',
      availableWorkoutTime: 30,
      targetSleepHours: 8,
      preferredBedtime: const TimeOfDay(hour: 22, minute: 0),
      preferredWakeup: const TimeOfDay(hour: 6, minute: 0),
      workSchedule: 'flexible',
      activityLevel: 'lightly_active',
      dietaryPreferences: DietaryPreferences(),
      sleepPreferences: SleepPreferences(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
