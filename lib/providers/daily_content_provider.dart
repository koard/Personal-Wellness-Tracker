import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/daily_content_models.dart';
import '../services/daily_content_service.dart';
import '../services/user_profile_service.dart';

// Daily Content State
class DailyContentState {
  final DailyContent? todayContent;
  final bool isLoading;
  final bool isGenerating;
  final String? error;
  final DateTime? lastGenerated;

  const DailyContentState({
    this.todayContent,
    this.isLoading = false,
    this.isGenerating = false,
    this.error,
    this.lastGenerated,
  });

  DailyContentState copyWith({
    DailyContent? todayContent,
    bool? isLoading,
    bool? isGenerating,
    String? error,
    DateTime? lastGenerated,
  }) {
    return DailyContentState(
      todayContent: todayContent ?? this.todayContent,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      error: error ?? this.error,
      lastGenerated: lastGenerated ?? this.lastGenerated,
    );
  }
}

// Daily Content Notifier
class DailyContentNotifier extends StateNotifier<DailyContentState> {
  DailyContentNotifier() : super(const DailyContentState()) {
    _loadTodayContent();
  }

  Future<void> _loadTodayContent() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final content = await DailyContentService.getTodayContent();
      
      if (content != null) {
        state = state.copyWith(
          todayContent: content,
          isLoading: false,
          lastGenerated: content.generatedAt,
        );
      } else {
        // No content for today, generate it
        await generateTodayContent();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load today\'s content: $e',
      );
    }
  }

  Future<void> generateTodayContent() async {
    state = state.copyWith(isGenerating: true, error: null);
    
    try {
      final profile = await UserProfileService.getUserProfile();
      if (profile == null) {
        throw Exception('User profile not found');
      }

      final content = await DailyContentService.generateTodayContentIfNeeded(profile);
      
      if (content != null) {
        state = state.copyWith(
          todayContent: content,
          isGenerating: false,
          lastGenerated: DateTime.now(),
        );
      } else {
        throw Exception('Failed to generate content');
      }
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Failed to generate content: $e',
      );
    }
  }

  Future<void> refreshContent() async {
    await _loadTodayContent();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final dailyContentProvider = StateNotifierProvider<DailyContentNotifier, DailyContentState>(
  (ref) => DailyContentNotifier(),
);

// Computed providers for specific content types
final todayMealSuggestionsProvider = Provider<List<DailyMealSuggestion>>((ref) {
  final content = ref.watch(dailyContentProvider).todayContent;
  return content?.mealSuggestions ?? [];
});

final todayActivitiesProvider = Provider<List<DailyActivitySuggestion>>((ref) {
  final content = ref.watch(dailyContentProvider).todayContent;
  return content?.activitySuggestions ?? [];
});

final todayHabitsProvider = Provider<List<DailyHabitReminder>>((ref) {
  final content = ref.watch(dailyContentProvider).todayContent;
  return content?.habitReminders ?? [];
});

final todayWaterGoalProvider = Provider<double>((ref) {
  final content = ref.watch(dailyContentProvider).todayContent;
  return content?.waterIntakeGoal ?? 2.5;
});

final todayMotivationProvider = Provider<String>((ref) {
  final content = ref.watch(dailyContentProvider).todayContent;
  return content?.motivationalMessage ?? 'Stay committed to your wellness journey!';
});

// Daily stats provider
final dailyStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final content = ref.watch(dailyContentProvider).todayContent;
  
  if (content == null) {
    return {
      'totalCalories': 0,
      'totalActivities': 0,
      'totalHabits': 0,
      'estimatedDuration': 0,
    };
  }

  final totalCalories = content.mealSuggestions
      .fold<int>(0, (sum, meal) => sum + meal.estimatedCalories);
  
  final estimatedDuration = content.activitySuggestions
      .fold<int>(0, (sum, activity) => sum + activity.durationMinutes);

  return {
    'totalCalories': totalCalories,
    'totalActivities': content.activitySuggestions.length,
    'totalHabits': content.habitReminders.length,
    'estimatedDuration': estimatedDuration,
  };
});
