import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/daily_content_provider.dart';
import '../../../models/daily_content_models.dart';

class DailyContentCard extends ConsumerWidget {
  const DailyContentCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyContentState = ref.watch(dailyContentProvider);
    final todayStats = ref.watch(dailyStatsProvider);

    if (dailyContentState.isLoading) {
      return _buildLoadingCard(context);
    }

    if (dailyContentState.error != null) {
      return _buildErrorCard(context, dailyContentState.error!, ref);
    }

    if (dailyContentState.todayContent == null) {
      return _buildGenerateCard(context, ref);
    }

    return _buildContentCard(context, dailyContentState.todayContent!, todayStats, ref);
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading your daily wellness plan...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 32),
          const SizedBox(height: 12),
          Text(
            'Failed to load daily content',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(dailyContentProvider.notifier).clearError();
              ref.read(dailyContentProvider.notifier).refreshContent();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.auto_awesome, color: Colors.blue[400], size: 32),
          const SizedBox(height: 12),
          Text(
            'Generate Today\'s Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let AI create personalized meal suggestions, activities, and habits for you today!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(dailyContentProvider.notifier).generateTodayContent();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    BuildContext context,
    DailyContent content,
    Map<String, dynamic> stats,
    WidgetRef ref,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue[600], size: 24),
              const SizedBox(width: 8),
              Text(
                'Your AI Wellness Plan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  ref.read(dailyContentProvider.notifier).generateTodayContent();
                },
                icon: Icon(Icons.refresh, color: Colors.grey[600]),
                tooltip: 'Regenerate Plan',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Motivational Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Text(
              content.motivationalMessage,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.blue[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Meals',
                  '${content.mealSuggestions.length}',
                  Icons.restaurant,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Activities',
                  '${content.activitySuggestions.length}',
                  Icons.fitness_center,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Habits',
                  '${content.habitReminders.length}',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Preview
          if (content.mealSuggestions.isNotEmpty) ...[
            Text(
              'Today\'s Meal Highlights',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ...content.mealSuggestions.take(2).map((meal) => _buildMealPreview(meal)),
          ],

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to meals page
                    // This will be handled by the parent widget
                  },
                  icon: const Icon(Icons.restaurant),
                  label: const Text('View Meals'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to habits page
                    // This will be handled by the parent widget
                  },
                  icon: const Icon(Icons.track_changes),
                  label: const Text('Track Habits'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealPreview(DailyMealSuggestion meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(
              color: _getMealTypeColor(meal.mealType),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${meal.estimatedCalories} cal • ${meal.cookingTime}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            meal.mealType.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _getMealTypeColor(meal.mealType),
            ),
          ),
        ],
      ),
    );
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
