import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/app_theme.dart';
import '../../../providers/daily_content_provider.dart';
import '../../../models/daily_content_models.dart';
import '../../../providers/meals_provider.dart';
import '../../../models/meal_model.dart';

class AIMealSuggestionsCard extends ConsumerWidget {
  const AIMealSuggestionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealSuggestions = ref.watch(todayMealSuggestionsProvider);
    final dailyContentState = ref.watch(dailyContentProvider);

    if (dailyContentState.isLoading) {
      return _buildLoadingCard(context);
    }

    if (mealSuggestions.isEmpty) {
      return _buildEmptyCard(context, ref);
    }

    return _buildSuggestionsCard(context, mealSuggestions, ref);
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors(context).surfaceBackground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            'AI is preparing your meal suggestions...',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors(context).surfaceBackground.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.auto_awesome,
            size: 32,
            color: AppTheme.colors(context).primaryBackground,
          ),
          const SizedBox(height: 12),
          Text(
            'No AI suggestions today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.colors(context).surfaceForeground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate personalized meal suggestions with AI',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(dailyContentProvider.notifier).generateTodayContent();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Suggestions'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.colors(context).primaryBackground,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsCard(
    BuildContext context,
    List<DailyMealSuggestion> suggestions,
    WidgetRef ref,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.colors(context).surfaceBackground.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.colors(context).mutedBackground.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppTheme.colors(context).primaryBackground,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Meal Suggestions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.colors(context).surfaceForeground,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  ref.read(dailyContentProvider.notifier).generateTodayContent();
                },
                icon: Icon(
                  Icons.refresh,
                  color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.7),
                ),
                tooltip: 'Regenerate Suggestions',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Suggestions List
          ...suggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSuggestionItem(context, suggestion, ref),
          )),

          const SizedBox(height: 8),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(dailyContentProvider.notifier).generateTodayContent();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Get New Suggestions'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppTheme.colors(context).primaryBackground,
                ),
                foregroundColor: AppTheme.colors(context).primaryBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    DailyMealSuggestion suggestion,
    WidgetRef ref,
  ) {
    final mealTypeColor = _getMealTypeColor(suggestion.mealType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.colors(context).surfaceBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: mealTypeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: mealTypeColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  suggestion.mealType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: mealTypeColor,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.colors(context).primaryBackground.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${suggestion.estimatedCalories} cal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors(context).primaryBackground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Meal Name
          Text(
            suggestion.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors(context).surfaceForeground,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            suggestion.description,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),

          // Details Row
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                suggestion.cookingTime,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.bar_chart,
                size: 14,
                color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              Text(
                suggestion.difficulty,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.colors(context).surfaceForeground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _logSuggestedMeal(suggestion, ref);
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Log This Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: mealTypeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logSuggestedMeal(DailyMealSuggestion suggestion, WidgetRef ref) {
    // Create a Meal object from the suggestion
    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: suggestion.name,
      calories: suggestion.estimatedCalories,
      imagePath: '', // No image for AI suggestions
      timestamp: DateTime.now(),
      mealType: suggestion.mealType,
    );

    // Add to meals provider
    ref.read(mealsProvider.notifier).addMeal(meal);

    // Show confirmation
    // Note: Context would need to be passed from parent widget for SnackBar
  }

  Color _getMealTypeColor(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.red;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}
