import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';

// Stream the comprehensive UserProfile (users/{uid}/profile/data)
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  return UserProfileService.streamUserProfile();
});

// Derived provider exposing target goals (calories and water in liters)
final userTargetGoalsProvider = Provider<Map<String, double>>((ref) {
  final profileAsync = ref.watch(userProfileStreamProvider);
  return profileAsync.maybeWhen(
    data: (profile) {
      final targetCalories = (profile != null && profile.targetCalories > 0)
          ? profile.targetCalories
          : (profile?.tdee ?? 2000.0);
      final targetWaterLiters = (profile != null && profile.targetWaterIntake > 0)
          ? profile.targetWaterIntake
          : (profile?.recommendedWaterIntake ?? 2.5);
      return {
        'targetCalories': targetCalories,
        'targetWaterLiters': targetWaterLiters,
      };
    },
    orElse: () => {
      'targetCalories': 2000.0,
      'targetWaterLiters': 2.5,
    },
  );
});
