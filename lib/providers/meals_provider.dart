import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_model.dart';
import '../services/gemini_service.dart';
import '../services/ai_service.dart';

// Services providers
final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());
final aiServiceProvider = Provider<AiService>((ref) => AiService(ref.read(geminiServiceProvider)));

// Meals state notifier
class MealsNotifier extends StateNotifier<List<Meal>> {
  MealsNotifier() : super([]);

  void addMeal(Meal meal) {
    state = [...state, meal];
  }

  void removeMeal(String mealId) {
    state = state.where((meal) => meal.id != mealId).toList();
  }

  void updateMeal(Meal updatedMeal) {
    state = state.map((meal) => meal.id == updatedMeal.id ? updatedMeal : meal).toList();
  }

  List<Meal> getMealsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return state.where((meal) => 
      meal.timestamp.isAfter(startOfDay) && 
      meal.timestamp.isBefore(endOfDay)
    ).toList();
  }
}

// Providers
final mealsProvider = StateNotifierProvider<MealsNotifier, List<Meal>>((ref) => MealsNotifier());

final recognizedFoodProvider = StateProvider<String>((ref) => 'Identifying...');

// Calculate total calories for today
final caloriesProvider = Provider<Map<String, int>>((ref) {
  final meals = ref.watch(mealsProvider);
  final today = DateTime.now();
  final todaysMeals = meals.where((meal) {
    final mealDate = meal.timestamp;
    return mealDate.year == today.year &&
           mealDate.month == today.month &&
           mealDate.day == today.day;
  }).toList();

  final totalCalories = todaysMeals.fold<int>(0, (sum, meal) => sum + meal.calories);
  const targetCalories = 2000; // Default target

  return {
    'current': totalCalories,
    'target': targetCalories,
  };
});

// Calculate macronutrients for today
final nutrientsProvider = Provider<Map<String, Map<String, double>>>((ref) {
  final meals = ref.watch(mealsProvider);
  final today = DateTime.now();
  final todaysMeals = meals.where((meal) {
    final mealDate = meal.timestamp;
    return mealDate.year == today.year &&
           mealDate.month == today.month &&
           mealDate.day == today.day;
  }).toList();

  final totalCarbs = todaysMeals.fold<double>(0.0, (sum, meal) => sum + meal.carbs);
  final totalProtein = todaysMeals.fold<double>(0.0, (sum, meal) => sum + meal.protein);
  final totalFat = todaysMeals.fold<double>(0.0, (sum, meal) => sum + meal.fat);

  // Default daily targets (these could be made configurable later)
  const targetCarbs = 225.0; // 45% of 2000 calories
  const targetProtein = 150.0; // 30% of 2000 calories  
  const targetFat = 67.0; // 25% of 2000 calories

  return {
    'carbs': {
      'current': totalCarbs,
      'target': targetCarbs,
    },
    'protein': {
      'current': totalProtein,
      'target': targetProtein,
    },
    'fat': {
      'current': totalFat,
      'target': targetFat,
    },
  };
});

// Get today's meals grouped by meal type
final todaysMealsProvider = Provider<List<Meal>>((ref) {
  final meals = ref.watch(mealsProvider);
  final today = DateTime.now();
  
  return meals.where((meal) {
    final mealDate = meal.timestamp;
    return mealDate.year == today.year &&
           mealDate.month == today.month &&
           mealDate.day == today.day;
  }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
});
