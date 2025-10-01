import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/achievement_model.dart';

/// Service for managing achievements, streaks, and gamification
class AchievementService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  static CollectionReference get _achievementsCollection =>
      _db.collection('users').doc(_uid).collection('achievements');

  static CollectionReference get _streaksCollection =>
      _db.collection('users').doc(_uid).collection('streaks');

  static DocumentReference get _progressDoc =>
      _db.collection('users').doc(_uid).collection('progress').doc('data');

  /// Get all user achievements
  static Future<List<Achievement>> getUserAchievements() async {
    try {
      final snapshot = await _achievementsCollection
          .orderBy('isCompleted')
          .orderBy('currentProgress', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  /// Get achievements by category
  static Future<List<Achievement>> getAchievementsByCategory(String category) async {
    try {
      final snapshot = await _achievementsCollection
          .where('category', isEqualTo: category)
          .orderBy('isCompleted')
          .get();

      return snapshot.docs
          .map((doc) => Achievement.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting achievements by category: $e');
      return [];
    }
  }

  /// Update achievement progress
  static Future<bool> updateAchievementProgress({
    required String achievementId,
    required int newProgress,
  }) async {
    try {
      final achievementRef = _achievementsCollection.doc(achievementId);
      final achievement = await achievementRef.get();
      
      if (!achievement.exists) return false;

      final achievementData = Achievement.fromFirestore(achievement);
      final isNowCompleted = newProgress >= achievementData.targetValue;

      await achievementRef.update({
        'currentProgress': newProgress,
        'isCompleted': isNowCompleted,
        'completedAt': isNowCompleted ? Timestamp.fromDate(DateTime.now()) : null,
      });

      // Award points if completed
      if (isNowCompleted && !achievementData.isCompleted) {
        await _awardPoints(achievementData.rewardPoints, achievementData.category);
      }

      return true;
    } catch (e) {
      print('Error updating achievement progress: $e');
      return false;
    }
  }

  /// Create or update streak
  static Future<bool> updateStreak({
    required String habitType,
    required bool activityCompleted,
  }) async {
    try {
      final streakRef = _streaksCollection.doc(habitType);
      final streakDoc = await streakRef.get();

      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      if (streakDoc.exists) {
        final streak = StreakTracker.fromFirestore(streakDoc);
        
        if (activityCompleted && streak.isEligibleForUpdate) {
          // Increment streak
          int newStreak = streak.isStreakBroken ? 1 : streak.currentStreak + 1;
          int newLongest = newStreak > streak.longestStreak ? newStreak : streak.longestStreak;
          
          List<DateTime> updatedDates = [...streak.activityDates, today];
          if (updatedDates.length > 30) {
            updatedDates = updatedDates.sublist(updatedDates.length - 30); // Keep last 30 days
          }

          await streakRef.update({
            'currentStreak': newStreak,
            'longestStreak': newLongest,
            'lastActivityDate': Timestamp.fromDate(today),
            'activityDates': updatedDates.map((d) => Timestamp.fromDate(d)).toList(),
          });

          // Check for streak achievements
          await _checkStreakAchievements(habitType, newStreak);
        }
      } else if (activityCompleted) {
        // Create new streak
        final newStreak = StreakTracker(
          id: habitType,
          userId: _uid,
          habitType: habitType,
          currentStreak: 1,
          longestStreak: 1,
          lastActivityDate: today,
          activityDates: [today],
        );

        await streakRef.set(newStreak.toFirestore());
      }

      return true;
    } catch (e) {
      print('Error updating streak: $e');
      return false;
    }
  }

  /// Get streak for specific habit
  static Future<StreakTracker?> getStreak(String habitType) async {
    try {
      final doc = await _streaksCollection.doc(habitType).get();
      if (doc.exists) {
        return StreakTracker.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting streak: $e');
      return null;
    }
  }

  /// Get all user streaks
  static Future<List<StreakTracker>> getAllStreaks() async {
    try {
      final snapshot = await _streaksCollection
          .where('isActive', isEqualTo: true)
          .orderBy('currentStreak', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => StreakTracker.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all streaks: $e');
      return [];
    }
  }

  /// Get user progress (points, level, etc.)
  static Future<UserProgress?> getUserProgress() async {
    try {
      final doc = await _progressDoc.get();
      if (doc.exists) {
        return UserProgress.fromFirestore(doc);
      } else {
        // Create initial progress
        final initialProgress = UserProgress(
          userId: _uid,
          lastUpdated: DateTime.now(),
        );
        await _progressDoc.set(initialProgress.toFirestore());
        return initialProgress;
      }
    } catch (e) {
      print('Error getting user progress: $e');
      return null;
    }
  }

  /// Award points and update level
  static Future<bool> _awardPoints(int points, String category) async {
    try {
      final progress = await getUserProgress();
      if (progress == null) return false;

      final newTotalPoints = progress.totalPoints + points;
      final newLevel = (newTotalPoints / 1000).floor() + 1;
      final pointsInLevel = newTotalPoints % 1000;
      final pointsForNext = 1000 - pointsInLevel;

      Map<String, int> updatedCategoryPoints = Map.from(progress.categoryPoints);
      updatedCategoryPoints[category] = (updatedCategoryPoints[category] ?? 0) + points;

      await _progressDoc.update({
        'totalPoints': newTotalPoints,
        'currentLevel': newLevel,
        'pointsInCurrentLevel': pointsInLevel,
        'pointsNeededForNextLevel': pointsForNext,
        'categoryPoints': updatedCategoryPoints,
        'lastUpdated': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      print('Error awarding points: $e');
      return false;
    }
  }

  /// Check and award streak achievements
  static Future<void> _checkStreakAchievements(String habitType, int streakCount) async {
    final streakMilestones = [3, 7, 14, 30, 100];
    
    for (int milestone in streakMilestones) {
      if (streakCount == milestone) {
        await _createStreakAchievement(habitType, milestone);
      }
    }
  }

  /// Create streak achievement
  static Future<void> _createStreakAchievement(String habitType, int days) async {
    try {
      final achievementId = '${habitType}_streak_$days';
      
      // Check if achievement already exists
      final existingDoc = await _achievementsCollection.doc(achievementId).get();
      if (existingDoc.exists) return;

      final achievement = Achievement(
        id: achievementId,
        userId: _uid,
        milestoneId: achievementId,
        name: '$days Day $habitType Streak',
        description: 'Complete $habitType for $days consecutive days',
        category: 'streak',
        currentProgress: days,
        targetValue: days,
        unit: 'days',
        isCompleted: true,
        completedAt: DateTime.now(),
        rewardPoints: days * 10, // 10 points per day
        badgeIcon: days >= 30 ? '🔥' : '⭐',
      );

      await _achievementsCollection.doc(achievementId).set(achievement.toFirestore());
      await _awardPoints(achievement.rewardPoints, 'streak');
    } catch (e) {
      print('Error creating streak achievement: $e');
    }
  }

  /// Stream user progress
  static Stream<UserProgress?> streamUserProgress() {
    return _progressDoc.snapshots().map((doc) {
      if (doc.exists) {
        return UserProgress.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Stream user achievements
  static Stream<List<Achievement>> streamUserAchievements() {
    return _achievementsCollection
        .orderBy('isCompleted')
        .orderBy('currentProgress', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Achievement.fromFirestore(doc))
            .toList());
  }

  /// Get completed achievements count
  static Future<int> getCompletedAchievementsCount() async {
    try {
      final snapshot = await _achievementsCollection
          .where('isCompleted', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting completed achievements count: $e');
      return 0;
    }
  }
}
