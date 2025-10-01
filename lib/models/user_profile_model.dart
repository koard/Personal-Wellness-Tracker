import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Comprehensive user profile model for AI-powered personalization
class UserProfile {
  final String userId;
  final String name;
  final int age;
  final String gender; // 'male', 'female', 'other'
  final double weight; // in kg
  final double height; // in cm
  final String primaryGoal; // AI-analyzed goal
  final List<String> secondaryGoals;
  final String fitnessLevel; // 'beginner', 'intermediate', 'advanced'
  final int availableWorkoutTime; // minutes per day
  final List<String> preferredActivities; 
  final int targetSleepHours; // 6-10 hours
  final TimeOfDay preferredBedtime;
  final TimeOfDay preferredWakeup;
  final String workSchedule; // 'morning', 'evening', 'flexible', 'shift'
  final String activityLevel; // 'sedentary', 'lightly_active', 'moderately_active', 'very_active'
  final List<String> healthConditions;
  final DietaryPreferences dietaryPreferences;
  final SleepPreferences sleepPreferences;
  final double targetCalories; // calculated by AI
  final double targetWaterIntake; // calculated by AI (liters)
  final int exerciseIntensity; // 1-5 scale (gentle to challenging)
  final bool isProfileComplete;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.primaryGoal,
    this.secondaryGoals = const [],
    required this.fitnessLevel,
    required this.availableWorkoutTime,
    this.preferredActivities = const [],
    required this.targetSleepHours,
    required this.preferredBedtime,
    required this.preferredWakeup,
    required this.workSchedule,
    required this.activityLevel,
    this.healthConditions = const [],
    required this.dietaryPreferences,
    required this.sleepPreferences,
    this.targetCalories = 0.0,
    this.targetWaterIntake = 0.0,
    this.exerciseIntensity = 3,
    this.isProfileComplete = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate BMR using Harris-Benedict equation
  double get bmr {
    if (gender.toLowerCase() == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  double get tdee {
    double activityFactor;
    switch (activityLevel) {
      case 'sedentary':
        activityFactor = 1.2;
        break;
      case 'lightly_active':
        activityFactor = 1.375;
        break;
      case 'moderately_active':
        activityFactor = 1.55;
        break;
      case 'very_active':
        activityFactor = 1.725;
        break;
      default:
        activityFactor = 1.2;
    }
    return bmr * activityFactor;
  }

  /// Calculate recommended water intake (35ml per kg + exercise adjustment)
  double get recommendedWaterIntake {
    double baseWater = weight * 0.035; // 35ml per kg in liters
    double exerciseAdjustment = (availableWorkoutTime / 60) * 0.5; // 500ml per hour of exercise
    return baseWater + exerciseAdjustment;
  }

  UserProfile copyWith({
    String? userId,
    String? name,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? primaryGoal,
    List<String>? secondaryGoals,
    String? fitnessLevel,
    int? availableWorkoutTime,
    List<String>? preferredActivities,
    int? targetSleepHours,
    TimeOfDay? preferredBedtime,
    TimeOfDay? preferredWakeup,
    String? workSchedule,
    String? activityLevel,
    List<String>? healthConditions,
    DietaryPreferences? dietaryPreferences,
    SleepPreferences? sleepPreferences,
    double? targetCalories,
    double? targetWaterIntake,
    int? exerciseIntensity,
    bool? isProfileComplete,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      secondaryGoals: secondaryGoals ?? this.secondaryGoals,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      availableWorkoutTime: availableWorkoutTime ?? this.availableWorkoutTime,
      preferredActivities: preferredActivities ?? this.preferredActivities,
      targetSleepHours: targetSleepHours ?? this.targetSleepHours,
      preferredBedtime: preferredBedtime ?? this.preferredBedtime,
      preferredWakeup: preferredWakeup ?? this.preferredWakeup,
      workSchedule: workSchedule ?? this.workSchedule,
      activityLevel: activityLevel ?? this.activityLevel,
      healthConditions: healthConditions ?? this.healthConditions,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      sleepPreferences: sleepPreferences ?? this.sleepPreferences,
      targetCalories: targetCalories ?? this.targetCalories,
      targetWaterIntake: targetWaterIntake ?? this.targetWaterIntake,
      exerciseIntensity: exerciseIntensity ?? this.exerciseIntensity,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      userId: doc.id,
      name: data['name'] ?? '',
      age: data['age'] ?? 18,
      gender: data['gender'] ?? 'other',
      weight: (data['weight'] ?? 70.0).toDouble(),
      height: (data['height'] ?? 170.0).toDouble(),
      primaryGoal: data['primaryGoal'] ?? 'general_fitness',
      secondaryGoals: List<String>.from(data['secondaryGoals'] ?? []),
      fitnessLevel: data['fitnessLevel'] ?? 'beginner',
      availableWorkoutTime: data['availableWorkoutTime'] ?? 30,
      preferredActivities: List<String>.from(data['preferredActivities'] ?? []),
      targetSleepHours: data['targetSleepHours'] ?? 8,
      preferredBedtime: TimeOfDay(
        hour: data['preferredBedtime']?['hour'] ?? 22,
        minute: data['preferredBedtime']?['minute'] ?? 0,
      ),
      preferredWakeup: TimeOfDay(
        hour: data['preferredWakeup']?['hour'] ?? 6,
        minute: data['preferredWakeup']?['minute'] ?? 0,
      ),
      workSchedule: data['workSchedule'] ?? 'flexible',
      activityLevel: data['activityLevel'] ?? 'lightly_active',
      healthConditions: List<String>.from(data['healthConditions'] ?? []),
      dietaryPreferences: DietaryPreferences.fromMap(data['dietaryPreferences'] ?? {}),
      sleepPreferences: SleepPreferences.fromMap(data['sleepPreferences'] ?? {}),
      targetCalories: (data['targetCalories'] ?? 0.0).toDouble(),
      targetWaterIntake: (data['targetWaterIntake'] ?? 0.0).toDouble(),
      exerciseIntensity: data['exerciseIntensity'] ?? 3,
      isProfileComplete: data['isProfileComplete'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'primaryGoal': primaryGoal,
      'secondaryGoals': secondaryGoals,
      'fitnessLevel': fitnessLevel,
      'availableWorkoutTime': availableWorkoutTime,
      'preferredActivities': preferredActivities,
      'targetSleepHours': targetSleepHours,
      'preferredBedtime': {
        'hour': preferredBedtime.hour,
        'minute': preferredBedtime.minute,
      },
      'preferredWakeup': {
        'hour': preferredWakeup.hour,
        'minute': preferredWakeup.minute,
      },
      'workSchedule': workSchedule,
      'activityLevel': activityLevel,
      'healthConditions': healthConditions,
      'dietaryPreferences': dietaryPreferences.toMap(),
      'sleepPreferences': sleepPreferences.toMap(),
      'targetCalories': targetCalories,
      'targetWaterIntake': targetWaterIntake,
      'exerciseIntensity': exerciseIntensity,
      'isProfileComplete': isProfileComplete,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

/// Thai food and dietary preferences
class DietaryPreferences {
  final List<String> restrictions; // 'vegetarian', 'vegan', 'halal', 'low_carb', etc.
  final int spiceLevel; // 1-5 peppers
  final List<String> preferredCuisines; // 'central', 'northern', 'southern', 'northeastern'
  final String cookingFrequency; // 'never', 'rarely', 'sometimes', 'often', 'always'
  final List<String> allergies;
  final List<String> dislikedFoods;

  DietaryPreferences({
    this.restrictions = const [],
    this.spiceLevel = 3,
    this.preferredCuisines = const ['central'],
    this.cookingFrequency = 'sometimes',
    this.allergies = const [],
    this.dislikedFoods = const [],
  });

  factory DietaryPreferences.fromMap(Map<String, dynamic> data) {
    return DietaryPreferences(
      restrictions: List<String>.from(data['restrictions'] ?? []),
      spiceLevel: data['spiceLevel'] ?? 3,
      preferredCuisines: List<String>.from(data['preferredCuisines'] ?? ['central']),
      cookingFrequency: data['cookingFrequency'] ?? 'sometimes',
      allergies: List<String>.from(data['allergies'] ?? []),
      dislikedFoods: List<String>.from(data['dislikedFoods'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'restrictions': restrictions,
      'spiceLevel': spiceLevel,
      'preferredCuisines': preferredCuisines,
      'cookingFrequency': cookingFrequency,
      'allergies': allergies,
      'dislikedFoods': dislikedFoods,
    };
  }
}

/// Sleep preferences and challenges
class SleepPreferences {
  final int currentSleepQuality; // 1-5 stars
  final List<String> sleepChallenges; // 'hard_to_fall_asleep', 'wake_frequently', 'wake_tired'
  final bool usesSleepAids;
  final String sleepEnvironment; // 'quiet', 'white_noise', 'music'
  final bool isConsistentSchedule;

  SleepPreferences({
    this.currentSleepQuality = 3,
    this.sleepChallenges = const [],
    this.usesSleepAids = false,
    this.sleepEnvironment = 'quiet',
    this.isConsistentSchedule = true,
  });

  factory SleepPreferences.fromMap(Map<String, dynamic> data) {
    return SleepPreferences(
      currentSleepQuality: data['currentSleepQuality'] ?? 3,
      sleepChallenges: List<String>.from(data['sleepChallenges'] ?? []),
      usesSleepAids: data['usesSleepAids'] ?? false,
      sleepEnvironment: data['sleepEnvironment'] ?? 'quiet',
      isConsistentSchedule: data['isConsistentSchedule'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currentSleepQuality': currentSleepQuality,
      'sleepChallenges': sleepChallenges,
      'usesSleepAids': usesSleepAids,
      'sleepEnvironment': sleepEnvironment,
      'isConsistentSchedule': isConsistentSchedule,
    };
  }
}
