import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';
import '../services/gemini_profile_analyzer.dart';
import '../services/ai_recommendations_service.dart';

/// Provider for the profile setup wizard state
final profileSetupProvider = StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  return ProfileSetupNotifier();
});

/// Provider for user profile service
final userProfileServiceProvider = Provider<UserProfileService>((ref) {
  return UserProfileService();
});

/// State class for profile setup wizard
class ProfileSetupState {
  final int currentStep;
  final UserProfile profile;
  final bool isLoading;
  final String? error;
  final double completionPercentage;
  final bool isAnalyzing;
  final Map<String, dynamic> validationErrors;

  ProfileSetupState({
    this.currentStep = 0,
    required this.profile,
    this.isLoading = false,
    this.error,
    this.completionPercentage = 0.0,
    this.isAnalyzing = false,
    this.validationErrors = const {},
  });

  ProfileSetupState copyWith({
    int? currentStep,
    UserProfile? profile,
    bool? isLoading,
    String? error,
    double? completionPercentage,
    bool? isAnalyzing,
    Map<String, dynamic>? validationErrors,
  }) {
    return ProfileSetupState(
      currentStep: currentStep ?? this.currentStep,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

/// Notifier for managing profile setup state
class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  static const int totalSteps = 8;

  ProfileSetupNotifier() : super(ProfileSetupState(
    profile: _createInitialProfile(),
  ));

  static UserProfile _createInitialProfile() {
    return UserProfile(
      userId: '',
      name: '',
      age: 0, // ไม่มีค่าเริ่มต้น
      gender: '', // ไม่มีการเลือกเริ่มต้น
      weight: 75.0, // ตรงกลางของช่วง 30-120 kg
      height: 160.0, // ตรงกลางของช่วง 120-200 cm
      primaryGoal: '', // ไม่มีการเลือกเริ่มต้น
      secondaryGoals: const [],
      fitnessLevel: '', // ไม่มีการเลือกเริ่มต้น
      availableWorkoutTime: 0, // ไม่มีค่าเริ่มต้น
      preferredActivities: const [],
      targetSleepHours: 8, // ค่าเริ่มต้นในช่วงที่เหมาะสม (6-10 ชั่วโมง)
      preferredBedtime: const TimeOfDay(hour: 0, minute: 0), // จะให้ผู้ใช้เลือกเอง
      preferredWakeup: const TimeOfDay(hour: 0, minute: 0), // จะให้ผู้ใช้เลือกเอง
      workSchedule: '', // ไม่มีการเลือกเริ่มต้น
      activityLevel: '', // ไม่มีการเลือกเริ่มต้น
      healthConditions: const [],
      dietaryPreferences: DietaryPreferences(),
      sleepPreferences: SleepPreferences(),
      targetCalories: 0.0,
      targetWaterIntake: 0.0,
      exerciseIntensity: 3, // ตรงกลางของช่วง 1-5
      isProfileComplete: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update basic information (Step 1)
  void updateBasicInfo({
    String? name,
    int? age,
    String? gender,
    double? height,
    double? weight,
  }) {
    final updatedProfile = state.profile.copyWith(
      name: name,
      age: age,
      gender: gender,
      height: height,
      weight: weight,
      updatedAt: DateTime.now(),
    );
    
    _updateProfileAndProgress(updatedProfile);
  }

  /// Update lifestyle information (Step 2)
  void updateLifestyle({
    String? workSchedule,
    int? availableWorkoutTime,
    String? activityLevel,
  }) {
    final updatedProfile = state.profile.copyWith(
      workSchedule: workSchedule,
      availableWorkoutTime: availableWorkoutTime,
      activityLevel: activityLevel,
      updatedAt: DateTime.now(),
    );
    
    _updateProfileAndProgress(updatedProfile);
  }

  /// Update goals (Step 3)
  void updateGoals({
    String? primaryGoal,
    List<String>? secondaryGoals,
  }) {
    final updatedProfile = state.profile.copyWith(
      primaryGoal: primaryGoal,
      secondaryGoals: secondaryGoals,
      updatedAt: DateTime.now(),
    );
    
    _updateProfileAndProgress(updatedProfile);
  }

  /// Update fitness preferences (Step 4)
  void updateFitnessPreferences({
    String? fitnessLevel,
    List<String>? preferredActivities,
    int? exerciseIntensity,
  }) {
    final updatedProfile = state.profile.copyWith(
      fitnessLevel: fitnessLevel,
      preferredActivities: preferredActivities,
      exerciseIntensity: exerciseIntensity,
      updatedAt: DateTime.now(),
    );
    
    _updateProfileAndProgress(updatedProfile);
  }

  /// Update fitness information (alias for fitness step)
  void updateFitness({
    String? fitnessLevel,
    List<String>? preferredActivities,
    double? exerciseIntensity,
  }) {
    final updatedProfile = state.profile.copyWith(
      fitnessLevel: fitnessLevel,
      preferredActivities: preferredActivities,
      exerciseIntensity: exerciseIntensity?.round(),
      updatedAt: DateTime.now(),
    );
    
    _updateProfileAndProgress(updatedProfile);
  }

  /// Update sleep preferences (Step 5)
  void updateSleepPreferences({
    int? targetSleepHours,
    TimeOfDay? preferredBedtime,
    TimeOfDay? preferredWakeup,
    SleepPreferences? sleepPreferences,
  }) {
    final updatedProfile = state.profile.copyWith(
      targetSleepHours: targetSleepHours,
      preferredBedtime: preferredBedtime,
      preferredWakeup: preferredWakeup,
      sleepPreferences: sleepPreferences,
      updatedAt: DateTime.now(),
    );
    
    _updateProfileAndProgress(updatedProfile);
  }

  /// Update dietary preferences (Step 6)
  void updateDietaryPreferences(DietaryPreferences preferences) {
    final updatedProfile = state.profile.copyWith(
      dietaryPreferences: preferences,
      updatedAt: DateTime.now(),
    );
    
    _updateProfileAndProgress(updatedProfile);
  }

  /// Update health conditions (Step 7)
  void updateHealthConditions(List<String> healthConditions) {
    final updatedProfile = state.profile.copyWith(
      healthConditions: healthConditions,
      updatedAt: DateTime.now(),
    );
    
    _updateProfileAndProgress(updatedProfile);
  }

  /// Move to next step
  void nextStep() {
    if (state.currentStep < totalSteps - 1) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        error: null,
      );
    }
  }

  /// Move to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        error: null,
      );
    }
  }

  /// Jump to specific step
  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      state = state.copyWith(
        currentStep: step,
        error: null,
      );
    }
  }

  /// Validate current step
  bool validateCurrentStep() {
    Map<String, dynamic> errors = {};

    switch (state.currentStep) {
      case 0: // Basic Info
        if (state.profile.name.isEmpty) {
          errors['name'] = 'Name is required';
        }
        if (state.profile.age < 13 || state.profile.age > 100) {
          errors['age'] = 'Age must be between 13 and 100';
        }
        if (state.profile.height < 100 || state.profile.height > 250) {
          errors['height'] = 'Height must be between 100 and 250 cm';
        }
        if (state.profile.weight < 30 || state.profile.weight > 300) {
          errors['weight'] = 'Weight must be between 30 and 300 kg';
        }
        break;

      case 1: // Lifestyle
        if (state.profile.availableWorkoutTime <= 0) {
          errors['workoutTime'] = 'Please select available workout time';
        }
        break;

      case 2: // Goals
        if (state.profile.primaryGoal.isEmpty) {
          errors['primaryGoal'] = 'Please select a primary goal';
        }
        break;

      case 3: // Fitness
        if (state.profile.preferredActivities.isEmpty) {
          errors['activities'] = 'Please select at least one activity';
        }
        break;

      // Steps 4-7 are optional, no validation required
    }

    state = state.copyWith(validationErrors: errors);
    return errors.isEmpty;
  }

  /// Update profile and recalculate completion percentage
  void _updateProfileAndProgress(UserProfile updatedProfile) {
    final completion = _calculateCompletionPercentage(updatedProfile);
    state = state.copyWith(
      profile: updatedProfile,
      completionPercentage: completion,
    );
  }

  /// Calculate profile completion percentage
  double _calculateCompletionPercentage(UserProfile profile) {
    int completedFields = 0;
    const int totalFields = 15;

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

  /// Analyze profile with AI and save
  Future<void> analyzeAndSaveProfile() async {
    state = state.copyWith(isAnalyzing: true, error: null);

    try {
      // Mark profile as complete
      final completeProfile = state.profile.copyWith(
        isProfileComplete: true,
        targetCalories: state.profile.tdee,
        targetWaterIntake: state.profile.recommendedWaterIntake,
        updatedAt: DateTime.now(),
      );

      // Save profile to Firestore
      final success = await UserProfileService.saveUserProfile(completeProfile);
      if (!success) {
        throw Exception('Failed to save profile');
      }

      // Generate AI recommendations
      GeminiProfileAnalyzer.resetModel(); // Reset model to ensure fresh instance
      final recommendations = await GeminiProfileAnalyzer.analyzeProfile(completeProfile);
      if (recommendations != null) {
        await AIRecommendationsService.saveRecommendations(recommendations);
      }

      // Mark profile setup as complete in basic user model
      await UserProfileService.markProfileComplete();

      state = state.copyWith(
        profile: completeProfile,
        isAnalyzing: false,
        completionPercentage: 1.0,
      );

    } catch (e) {
      state = state.copyWith(
        isAnalyzing: false,
        error: 'Failed to analyze profile: ${e.toString()}',
      );
    }
  }

  /// Reset the profile setup
  void reset() {
    state = ProfileSetupState(
      profile: _createInitialProfile(),
    );
  }

  /// Set user ID when available
  void setUserId(String userId) {
    final updatedProfile = state.profile.copyWith(userId: userId);
    state = state.copyWith(profile: updatedProfile);
  }
}
