import 'package:cloud_firestore/cloud_firestore.dart';

/// AI-generated personalized recommendations
class AIRecommendations {
  final String userId;
  final String profileVersion; // Track which profile version these recommendations are for
  final double dailyCalorieTarget;
  final double dailyWaterTarget; // liters
  final List<ExerciseRecommendation> weeklyExercisePlan;
  final List<ThaiMealSuggestion> weeklyMealSuggestions;
  final List<String> sleepOptimizationTips;
  final List<QuickActivity> dailyActivities; // 30-minute stress relief activities
  final List<AchievementMilestone> achievementMilestones;
  final Map<String, dynamic> nutritionBreakdown; // macros, vitamins, etc.
  final DateTime generatedAt;
  final DateTime expiresAt; // recommendations refresh weekly

  AIRecommendations({
    required this.userId,
    required this.profileVersion,
    required this.dailyCalorieTarget,
    required this.dailyWaterTarget,
    required this.weeklyExercisePlan,
    required this.weeklyMealSuggestions,
    required this.sleepOptimizationTips,
    required this.dailyActivities,
    required this.achievementMilestones,
    required this.nutritionBreakdown,
    required this.generatedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory AIRecommendations.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AIRecommendations(
      userId: data['userId'] ?? '',
      profileVersion: data['profileVersion'] ?? '',
      dailyCalorieTarget: (data['dailyCalorieTarget'] ?? 2000.0).toDouble(),
      dailyWaterTarget: (data['dailyWaterTarget'] ?? 2.5).toDouble(),
      weeklyExercisePlan: (data['weeklyExercisePlan'] as List<dynamic>? ?? [])
          .map((e) => ExerciseRecommendation.fromMap(e))
          .toList(),
      weeklyMealSuggestions: (data['weeklyMealSuggestions'] as List<dynamic>? ?? [])
          .map((e) => ThaiMealSuggestion.fromMap(e))
          .toList(),
      sleepOptimizationTips: List<String>.from(data['sleepOptimizationTips'] ?? []),
      dailyActivities: (data['dailyActivities'] as List<dynamic>? ?? [])
          .map((e) => QuickActivity.fromMap(e))
          .toList(),
      achievementMilestones: (data['achievementMilestones'] as List<dynamic>? ?? [])
          .map((e) => AchievementMilestone.fromMap(e))
          .toList(),
      nutritionBreakdown: Map<String, dynamic>.from(data['nutritionBreakdown'] ?? {}),
      generatedAt: (data['generatedAt'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'profileVersion': profileVersion,
      'dailyCalorieTarget': dailyCalorieTarget,
      'dailyWaterTarget': dailyWaterTarget,
      'weeklyExercisePlan': weeklyExercisePlan.map((e) => e.toMap()).toList(),
      'weeklyMealSuggestions': weeklyMealSuggestions.map((e) => e.toMap()).toList(),
      'sleepOptimizationTips': sleepOptimizationTips,
      'dailyActivities': dailyActivities.map((e) => e.toMap()).toList(),
      'achievementMilestones': achievementMilestones.map((e) => e.toMap()).toList(),
      'nutritionBreakdown': nutritionBreakdown,
      'generatedAt': Timestamp.fromDate(generatedAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
    };
  }
}

/// Exercise recommendation for specific day
class ExerciseRecommendation {
  final String dayOfWeek; // 'monday', 'tuesday', etc.
  final String primaryActivity;
  final int durationMinutes;
  final String intensity; // 'low', 'moderate', 'high'
  final List<String> exercises; // specific exercises
  final int estimatedCaloriesBurn;
  final String focusArea; // 'cardio', 'strength', 'flexibility', 'balance'
  final List<String> equipment; // required equipment

  ExerciseRecommendation({
    required this.dayOfWeek,
    required this.primaryActivity,
    required this.durationMinutes,
    required this.intensity,
    required this.exercises,
    required this.estimatedCaloriesBurn,
    required this.focusArea,
    this.equipment = const [],
  });

  factory ExerciseRecommendation.fromMap(Map<String, dynamic> data) {
    return ExerciseRecommendation(
      dayOfWeek: data['dayOfWeek'] ?? '',
      primaryActivity: data['primaryActivity'] ?? '',
      durationMinutes: data['durationMinutes'] ?? 30,
      intensity: data['intensity'] ?? 'moderate',
      exercises: List<String>.from(data['exercises'] ?? []),
      estimatedCaloriesBurn: data['estimatedCaloriesBurn'] ?? 200,
      focusArea: data['focusArea'] ?? 'cardio',
      equipment: List<String>.from(data['equipment'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayOfWeek': dayOfWeek,
      'primaryActivity': primaryActivity,
      'durationMinutes': durationMinutes,
      'intensity': intensity,
      'exercises': exercises,
      'estimatedCaloriesBurn': estimatedCaloriesBurn,
      'focusArea': focusArea,
      'equipment': equipment,
    };
  }
}

/// Thai meal suggestion
class ThaiMealSuggestion {
  final String dayOfWeek;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  final String dishName;
  final String dishNameThai;
  final String region; // 'central', 'northern', 'southern', 'northeastern'
  final int spiceLevel; // 1-5
  final int estimatedCalories;
  final String cookingTime; // 'quick', 'medium', 'long'
  final List<String> mainIngredients;
  final Map<String, double> nutrition; // protein, carbs, fat, fiber
  final String cookingMethod; // 'stir_fry', 'curry', 'soup', 'grilled'
  final bool isHealthy;
  final String? imageUrl;

  ThaiMealSuggestion({
    required this.dayOfWeek,
    required this.mealType,
    required this.dishName,
    required this.dishNameThai,
    required this.region,
    required this.spiceLevel,
    required this.estimatedCalories,
    required this.cookingTime,
    required this.mainIngredients,
    required this.nutrition,
    required this.cookingMethod,
    this.isHealthy = true,
    this.imageUrl,
  });

  factory ThaiMealSuggestion.fromMap(Map<String, dynamic> data) {
    return ThaiMealSuggestion(
      dayOfWeek: data['dayOfWeek'] ?? '',
      mealType: data['mealType'] ?? 'lunch',
      dishName: data['dishName'] ?? '',
      dishNameThai: data['dishNameThai'] ?? '',
      region: data['region'] ?? 'central',
      spiceLevel: data['spiceLevel'] ?? 3,
      estimatedCalories: data['estimatedCalories'] ?? 400,
      cookingTime: data['cookingTime'] ?? 'medium',
      mainIngredients: List<String>.from(data['mainIngredients'] ?? []),
      nutrition: Map<String, double>.from(data['nutrition'] ?? {}),
      cookingMethod: data['cookingMethod'] ?? 'stir_fry',
      isHealthy: data['isHealthy'] ?? true,
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dayOfWeek': dayOfWeek,
      'mealType': mealType,
      'dishName': dishName,
      'dishNameThai': dishNameThai,
      'region': region,
      'spiceLevel': spiceLevel,
      'estimatedCalories': estimatedCalories,
      'cookingTime': cookingTime,
      'mainIngredients': mainIngredients,
      'nutrition': nutrition,
      'cookingMethod': cookingMethod,
      'isHealthy': isHealthy,
      'imageUrl': imageUrl,
    };
  }
}

/// Quick 30-minute activities for stress relief
class QuickActivity {
  final String name;
  final String nameThai;
  final String category; // 'meditation', 'reading', 'creative', 'social'
  final int durationMinutes;
  final String description;
  final List<String> benefits;
  final String difficulty; // 'easy', 'medium', 'challenging'
  final bool requiresEquipment;
  final List<String> equipment;
  final String icon; // emoji

  QuickActivity({
    required this.name,
    required this.nameThai,
    required this.category,
    required this.durationMinutes,
    required this.description,
    required this.benefits,
    this.difficulty = 'easy',
    this.requiresEquipment = false,
    this.equipment = const [],
    this.icon = '🧘',
  });

  factory QuickActivity.fromMap(Map<String, dynamic> data) {
    return QuickActivity(
      name: data['name'] ?? '',
      nameThai: data['nameThai'] ?? '',
      category: data['category'] ?? 'meditation',
      durationMinutes: data['durationMinutes'] ?? 15,
      description: data['description'] ?? '',
      benefits: List<String>.from(data['benefits'] ?? []),
      difficulty: data['difficulty'] ?? 'easy',
      requiresEquipment: data['requiresEquipment'] ?? false,
      equipment: List<String>.from(data['equipment'] ?? []),
      icon: data['icon'] ?? '🧘',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameThai': nameThai,
      'category': category,
      'durationMinutes': durationMinutes,
      'description': description,
      'benefits': benefits,
      'difficulty': difficulty,
      'requiresEquipment': requiresEquipment,
      'equipment': equipment,
      'icon': icon,
    };
  }
}

/// Achievement milestones for gamification
class AchievementMilestone {
  final String id;
  final String name;
  final String nameThai;
  final String description;
  final String category; // 'streak', 'weight', 'activity', 'habit', 'exploration'
  final int targetValue;
  final String unit; // 'days', 'kg', 'sessions', 'activities'
  final String badgeIcon; // emoji
  final int rewardPoints;
  final bool isCompleted;
  final DateTime? completedAt;

  AchievementMilestone({
    required this.id,
    required this.name,
    required this.nameThai,
    required this.description,
    required this.category,
    required this.targetValue,
    required this.unit,
    this.badgeIcon = '🏆',
    this.rewardPoints = 100,
    this.isCompleted = false,
    this.completedAt,
  });

  factory AchievementMilestone.fromMap(Map<String, dynamic> data) {
    return AchievementMilestone(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      nameThai: data['nameThai'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'streak',
      targetValue: data['targetValue'] ?? 1,
      unit: data['unit'] ?? 'days',
      badgeIcon: data['badgeIcon'] ?? '🏆',
      rewardPoints: data['rewardPoints'] ?? 100,
      isCompleted: data['isCompleted'] ?? false,
      completedAt: data['completedAt'] != null 
          ? (data['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'nameThai': nameThai,
      'description': description,
      'category': category,
      'targetValue': targetValue,
      'unit': unit,
      'badgeIcon': badgeIcon,
      'rewardPoints': rewardPoints,
      'isCompleted': isCompleted,
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!) 
          : null,
    };
  }
}
