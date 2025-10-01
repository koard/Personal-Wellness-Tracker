import 'package:cloud_firestore/cloud_firestore.dart';

/// Daily meal suggestion model
class DailyMealSuggestion {
  final String name;
  final String description;
  final int estimatedCalories;
  final List<String> ingredients;
  final String cookingTime;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<String> tags; // 'thai', 'vegetarian', 'low-carb'
  
  const DailyMealSuggestion({
    required this.name,
    required this.description,
    required this.estimatedCalories,
    required this.ingredients,
    required this.cookingTime,
    required this.mealType,
    this.difficulty = 'easy',
    this.tags = const [],
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'estimatedCalories': estimatedCalories,
      'ingredients': ingredients,
      'cookingTime': cookingTime,
      'mealType': mealType,
      'difficulty': difficulty,
      'tags': tags,
    };
  }
  
  factory DailyMealSuggestion.fromMap(Map<String, dynamic> map) {
    return DailyMealSuggestion(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      estimatedCalories: map['estimatedCalories'] ?? 0,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      cookingTime: map['cookingTime'] ?? '',
      mealType: map['mealType'] ?? '',
      difficulty: map['difficulty'] ?? 'easy',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}

/// Daily activity suggestion model
class DailyActivitySuggestion {
  final String name;
  final String description;
  final int durationMinutes;
  final String difficulty;
  final String category; // 'cardio', 'strength', 'flexibility', 'mindfulness'
  final List<String> equipment; // 'none', 'mat', 'weights'
  
  const DailyActivitySuggestion({
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.difficulty,
    required this.category,
    this.equipment = const [],
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
      'category': category,
      'equipment': equipment,
    };
  }
  
  factory DailyActivitySuggestion.fromMap(Map<String, dynamic> map) {
    return DailyActivitySuggestion(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      difficulty: map['difficulty'] ?? '',
      category: map['category'] ?? '',
      equipment: List<String>.from(map['equipment'] ?? []),
    );
  }
}

/// Daily habit reminder model
class DailyHabitReminder {
  final String name;
  final String description;
  final String category; // 'hydration', 'sleep', 'mindfulness', 'nutrition'
  final String reminder; // Time-based reminder text
  final String targetValue; // e.g., "8 glasses", "8 hours", "10 minutes"
  
  const DailyHabitReminder({
    required this.name,
    required this.description,
    required this.category,
    required this.reminder,
    required this.targetValue,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'reminder': reminder,
      'targetValue': targetValue,
    };
  }
  
  factory DailyHabitReminder.fromMap(Map<String, dynamic> map) {
    return DailyHabitReminder(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      reminder: map['reminder'] ?? '',
      targetValue: map['targetValue'] ?? '',
    );
  }
}

/// Complete daily content container
class DailyContent {
  final String date; // YYYY-MM-DD format
  final List<DailyMealSuggestion> mealSuggestions;
  final List<DailyActivitySuggestion> activitySuggestions;
  final List<DailyHabitReminder> habitReminders;
  final double waterIntakeGoal;
  final String motivationalMessage;
  final DateTime generatedAt;
  final String profileVersion; // To track which profile version generated this
  
  const DailyContent({
    required this.date,
    required this.mealSuggestions,
    required this.activitySuggestions,
    required this.habitReminders,
    required this.waterIntakeGoal,
    required this.motivationalMessage,
    required this.generatedAt,
    required this.profileVersion,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mealSuggestions': mealSuggestions.map((x) => x.toMap()).toList(),
      'activitySuggestions': activitySuggestions.map((x) => x.toMap()).toList(),
      'habitReminders': habitReminders.map((x) => x.toMap()).toList(),
      'waterIntakeGoal': waterIntakeGoal,
      'motivationalMessage': motivationalMessage,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'profileVersion': profileVersion,
    };
  }
  
  factory DailyContent.fromMap(Map<String, dynamic> map) {
    return DailyContent(
      date: map['date'] ?? '',
      mealSuggestions: List<DailyMealSuggestion>.from(
        map['mealSuggestions']?.map((x) => DailyMealSuggestion.fromMap(x)) ?? []
      ),
      activitySuggestions: List<DailyActivitySuggestion>.from(
        map['activitySuggestions']?.map((x) => DailyActivitySuggestion.fromMap(x)) ?? []
      ),
      habitReminders: List<DailyHabitReminder>.from(
        map['habitReminders']?.map((x) => DailyHabitReminder.fromMap(x)) ?? []
      ),
      waterIntakeGoal: map['waterIntakeGoal']?.toDouble() ?? 0.0,
      motivationalMessage: map['motivationalMessage'] ?? '',
      generatedAt: (map['generatedAt'] as Timestamp).toDate(),
      profileVersion: map['profileVersion'] ?? '',
    );
  }
}

/// Content generation metadata for tracking
class ContentGenerationMetadata {
  final String lastGeneratedDate;
  final int consecutiveDays;
  final int totalGeneratedDays;
  final DateTime lastGeneration;
  final Map<String, dynamic> preferences;
  final Map<String, dynamic> generationStats;
  
  const ContentGenerationMetadata({
    required this.lastGeneratedDate,
    required this.consecutiveDays,
    required this.totalGeneratedDays,
    required this.lastGeneration,
    required this.preferences,
    required this.generationStats,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'lastGeneratedDate': lastGeneratedDate,
      'consecutiveDays': consecutiveDays,
      'totalGeneratedDays': totalGeneratedDays,
      'lastGeneration': Timestamp.fromDate(lastGeneration),
      'preferences': preferences,
      'generationStats': generationStats,
    };
  }
  
  factory ContentGenerationMetadata.fromMap(Map<String, dynamic> map) {
    return ContentGenerationMetadata(
      lastGeneratedDate: map['lastGeneratedDate'] ?? '',
      consecutiveDays: map['consecutiveDays'] ?? 0,
      totalGeneratedDays: map['totalGeneratedDays'] ?? 0,
      lastGeneration: (map['lastGeneration'] as Timestamp).toDate(),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      generationStats: Map<String, dynamic>.from(map['generationStats'] ?? {}),
    );
  }
}
