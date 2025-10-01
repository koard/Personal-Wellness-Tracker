import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ai_recommendations_model.dart';

/// Service for managing AI-generated recommendations
class AIRecommendationsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  static CollectionReference get _recommendationsCollection =>
      _db.collection('users').doc(_uid).collection('aiRecommendations');

  /// Get current valid recommendations
  static Future<AIRecommendations?> getCurrentRecommendations() async {
    try {
      final snapshot = await _recommendationsCollection
          .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .orderBy('expiresAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return AIRecommendations.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting current recommendations: $e');
      return null;
    }
  }

  /// Save new AI recommendations
  static Future<bool> saveRecommendations(AIRecommendations recommendations) async {
    try {
      await _recommendationsCollection.add(recommendations.toFirestore());
      return true;
    } catch (e) {
      print('Error saving recommendations: $e');
      return false;
    }
  }

  /// Get recommendations by profile version
  static Future<AIRecommendations?> getRecommendationsByVersion(String profileVersion) async {
    try {
      final snapshot = await _recommendationsCollection
          .where('profileVersion', isEqualTo: profileVersion)
          .orderBy('generatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return AIRecommendations.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting recommendations by version: $e');
      return null;
    }
  }

  /// Stream current recommendations
  static Stream<AIRecommendations?> streamCurrentRecommendations() {
    return _recommendationsCollection
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('expiresAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return AIRecommendations.fromFirestore(snapshot.docs.first);
      }
      return null;
    });
  }

  /// Check if recommendations need refresh
  static Future<bool> needsRefresh() async {
    try {
      final current = await getCurrentRecommendations();
      return current == null || current.isExpired;
    } catch (e) {
      print('Error checking if recommendations need refresh: $e');
      return true;
    }
  }

  /// Delete expired recommendations
  static Future<void> cleanupExpiredRecommendations() async {
    try {
      final expiredQuery = await _recommendationsCollection
          .where('expiresAt', isLessThan: Timestamp.fromDate(DateTime.now()))
          .get();

      final batch = _db.batch();
      for (final doc in expiredQuery.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error cleaning up expired recommendations: $e');
    }
  }

  /// Get meal suggestions for specific day
  static Future<List<ThaiMealSuggestion>> getMealSuggestionsForDay(String dayOfWeek) async {
    try {
      final recommendations = await getCurrentRecommendations();
      if (recommendations == null) return [];

      return recommendations.weeklyMealSuggestions
          .where((meal) => meal.dayOfWeek.toLowerCase() == dayOfWeek.toLowerCase())
          .toList();
    } catch (e) {
      print('Error getting meal suggestions for day: $e');
      return [];
    }
  }

  /// Get exercise plan for specific day
  static Future<ExerciseRecommendation?> getExerciseForDay(String dayOfWeek) async {
    try {
      final recommendations = await getCurrentRecommendations();
      if (recommendations == null) return null;

      return recommendations.weeklyExercisePlan
          .where((exercise) => exercise.dayOfWeek.toLowerCase() == dayOfWeek.toLowerCase())
          .firstOrNull;
    } catch (e) {
      print('Error getting exercise for day: $e');
      return null;
    }
  }

  /// Get quick activities for stress relief
  static Future<List<QuickActivity>> getQuickActivities({int limit = 5}) async {
    try {
      final recommendations = await getCurrentRecommendations();
      if (recommendations == null) return [];

      return recommendations.dailyActivities.take(limit).toList();
    } catch (e) {
      print('Error getting quick activities: $e');
      return [];
    }
  }

  /// Update recommendation usage/feedback
  static Future<bool> recordRecommendationUsage({
    required String recommendationId,
    required String type, // 'meal', 'exercise', 'activity'
    required bool wasUseful,
    String? feedback,
  }) async {
    try {
      await _db.collection('users').doc(_uid).collection('recommendationFeedback').add({
        'recommendationId': recommendationId,
        'type': type,
        'wasUseful': wasUseful,
        'feedback': feedback,
        'timestamp': Timestamp.fromDate(DateTime.now()),
      });
      return true;
    } catch (e) {
      print('Error recording recommendation usage: $e');
      return false;
    }
  }
}

/// Extension to add firstOrNull method for older Dart versions
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
