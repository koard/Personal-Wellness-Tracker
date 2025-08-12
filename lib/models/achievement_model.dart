import 'package:cloud_firestore/cloud_firestore.dart';

/// Achievement tracking and gamification system
class Achievement {
  final String id;
  final String userId;
  final String milestoneId; // Reference to AchievementMilestone
  final String name;
  final String description;
  final String category;
  final int currentProgress;
  final int targetValue;
  final String unit;
  final bool isCompleted;
  final DateTime? completedAt;
  final int rewardPoints;
  final String badgeIcon;
  final List<String> shareMessages; // Social sharing templates

  Achievement({
    required this.id,
    required this.userId,
    required this.milestoneId,
    required this.name,
    required this.description,
    required this.category,
    this.currentProgress = 0,
    required this.targetValue,
    required this.unit,
    this.isCompleted = false,
    this.completedAt,
    this.rewardPoints = 100,
    this.badgeIcon = '🏆',
    this.shareMessages = const [],
  });

  double get progressPercentage => 
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  bool get isNearlyComplete => progressPercentage >= 0.8;

  Achievement copyWith({
    String? id,
    String? userId,
    String? milestoneId,
    String? name,
    String? description,
    String? category,
    int? currentProgress,
    int? targetValue,
    String? unit,
    bool? isCompleted,
    DateTime? completedAt,
    int? rewardPoints,
    String? badgeIcon,
    List<String>? shareMessages,
  }) {
    return Achievement(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      milestoneId: milestoneId ?? this.milestoneId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      currentProgress: currentProgress ?? this.currentProgress,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      shareMessages: shareMessages ?? this.shareMessages,
    );
  }

  factory Achievement.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Achievement(
      id: doc.id,
      userId: data['userId'] ?? '',
      milestoneId: data['milestoneId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      currentProgress: data['currentProgress'] ?? 0,
      targetValue: data['targetValue'] ?? 1,
      unit: data['unit'] ?? 'days',
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
      rewardPoints: data['rewardPoints'] ?? 100,
      badgeIcon: data['badgeIcon'] ?? '🏆',
      shareMessages: List<String>.from(data['shareMessages'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'milestoneId': milestoneId,
      'name': name,
      'description': description,
      'category': category,
      'currentProgress': currentProgress,
      'targetValue': targetValue,
      'unit': unit,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!) 
          : null,
      'rewardPoints': rewardPoints,
      'badgeIcon': badgeIcon,
      'shareMessages': shareMessages,
    };
  }
}

/// Streak tracking for consistent habits
class StreakTracker {
  final String id;
  final String userId;
  final String habitType; // 'exercise', 'water', 'sleep', 'meals', 'custom'
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActivityDate;
  final List<DateTime> activityDates; // Recent activity history
  final bool isActive;

  StreakTracker({
    required this.id,
    required this.userId,
    required this.habitType,
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastActivityDate,
    this.activityDates = const [],
    this.isActive = true,
  });

  bool get isStreakBroken {
    final now = DateTime.now();
    final difference = now.difference(lastActivityDate).inDays;
    return difference > 1; // Allow 1 day gap
  }

  bool get isEligibleForUpdate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate.year, 
      lastActivityDate.month, 
      lastActivityDate.day
    );
    return today.isAfter(lastActivity);
  }

  StreakTracker copyWith({
    String? id,
    String? userId,
    String? habitType,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActivityDate,
    List<DateTime>? activityDates,
    bool? isActive,
  }) {
    return StreakTracker(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      habitType: habitType ?? this.habitType,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      activityDates: activityDates ?? this.activityDates,
      isActive: isActive ?? this.isActive,
    );
  }

  factory StreakTracker.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StreakTracker(
      id: doc.id,
      userId: data['userId'] ?? '',
      habitType: data['habitType'] ?? '',
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      lastActivityDate: (data['lastActivityDate'] as Timestamp).toDate(),
      activityDates: (data['activityDates'] as List<dynamic>? ?? [])
          .map((e) => (e as Timestamp).toDate())
          .toList(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'habitType': habitType,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': Timestamp.fromDate(lastActivityDate),
      'activityDates': activityDates.map((e) => Timestamp.fromDate(e)).toList(),
      'isActive': isActive,
    };
  }
}

/// User points and level system
class UserProgress {
  final String userId;
  final int totalPoints;
  final int currentLevel;
  final int pointsInCurrentLevel;
  final int pointsNeededForNextLevel;
  final Map<String, int> categoryPoints; // Points by category
  final List<String> unlockedBadges;
  final DateTime lastUpdated;

  UserProgress({
    required this.userId,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.pointsInCurrentLevel = 0,
    this.pointsNeededForNextLevel = 1000,
    this.categoryPoints = const {},
    this.unlockedBadges = const [],
    required this.lastUpdated,
  });

  int get pointsForLevel => currentLevel * 1000; // 1000 points per level

  double get levelProgress => 
      pointsNeededForNextLevel > 0 
          ? (pointsInCurrentLevel / pointsNeededForNextLevel).clamp(0.0, 1.0) 
          : 0.0;

  UserProgress copyWith({
    String? userId,
    int? totalPoints,
    int? currentLevel,
    int? pointsInCurrentLevel,
    int? pointsNeededForNextLevel,
    Map<String, int>? categoryPoints,
    List<String>? unlockedBadges,
    DateTime? lastUpdated,
  }) {
    return UserProgress(
      userId: userId ?? this.userId,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      pointsInCurrentLevel: pointsInCurrentLevel ?? this.pointsInCurrentLevel,
      pointsNeededForNextLevel: pointsNeededForNextLevel ?? this.pointsNeededForNextLevel,
      categoryPoints: categoryPoints ?? this.categoryPoints,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory UserProgress.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProgress(
      userId: doc.id,
      totalPoints: data['totalPoints'] ?? 0,
      currentLevel: data['currentLevel'] ?? 1,
      pointsInCurrentLevel: data['pointsInCurrentLevel'] ?? 0,
      pointsNeededForNextLevel: data['pointsNeededForNextLevel'] ?? 1000,
      categoryPoints: Map<String, int>.from(data['categoryPoints'] ?? {}),
      unlockedBadges: List<String>.from(data['unlockedBadges'] ?? []),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalPoints': totalPoints,
      'currentLevel': currentLevel,
      'pointsInCurrentLevel': pointsInCurrentLevel,
      'pointsNeededForNextLevel': pointsNeededForNextLevel,
      'categoryPoints': categoryPoints,
      'unlockedBadges': unlockedBadges,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
