import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/daily_content_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'User';
    final l10n = AppLocalizations.of(context)!;
    
    // Get AI-generated daily data
    final dailyContentState = ref.watch(dailyContentProvider);
    final todayStats = ref.watch(dailyStatsProvider);
    final todayWaterGoal = ref.watch(todayWaterGoalProvider);
    final todayActivities = ref.watch(todayActivitiesProvider);
    final todayMotivation = ref.watch(todayMotivationProvider);
    
    // Use AI data or fallback to defaults
    final targetCalories = todayStats['totalCalories'] > 0 ? todayStats['totalCalories'] : 2000;
    final currentCalories = 1520; // This would come from logged meals
    final targetWater = (todayWaterGoal * 4).round(); // Convert liters to glasses
    final currentWater = 6; // This would come from logged water intake;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            // Greeting
            Text(
              l10n.dashboardGoodMorning(userName.toUpperCase()),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Spacer(),
            IconButton(
              icon: Icon(
                    Icons.notifications,
                    color: Colors.amber,
                    size: 28,
                  ),
              onPressed: () {},
            ),
            SizedBox(width: 8),
            Icon(Icons.person, color: Colors.grey[600], size: 36),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                  // Dashboard Title
                  Text(
                    l10n.dashboardTitle,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Tracking Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTrackingCard(
                          title: l10n.dashboardCalories,
                          current: currentCalories,
                          target: targetCalories,
                          unit: '',
                          color: Colors.orange,
                          icon: Icons.local_fire_department,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTrackingCard(
                          title: l10n.dashboardWater,
                          current: currentWater,
                          target: targetWater,
                          unit: "",
                          color: Colors.blue,
                          icon: Icons.water_drop,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  // Exercise Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Exercise',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Generate exercise suggestions
                          ref.read(dailyContentProvider.notifier).generateTodayContent();
                        },
                        icon: Icon(Icons.fitness_center, size: 16),
                        label: Text('Generate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[50],
                          foregroundColor: Colors.orange[700],
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Show AI-generated exercises or empty state
                  if (todayActivities.isNotEmpty) ...[
                    ...todayActivities.map((activity) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: _buildExerciseCard(
                        name: activity.name,
                        description: activity.description,
                        duration: '${activity.durationMinutes} min',
                        difficulty: activity.difficulty,
                        category: activity.category,
                      ),
                    )).toList(),
                  ] else ...[
                    // Empty state for exercises
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.fitness_center, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(
                            'No exercises planned',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap "Generate" to create personalized workout plan',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 24),

                  // Daily Challenges Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Challenges',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Generate daily challenges
                          ref.read(dailyContentProvider.notifier).generateTodayContent();
                        },
                        icon: Icon(Icons.emoji_events, size: 16),
                        label: Text('Generate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[50],
                          foregroundColor: Colors.purple[700],
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Show AI motivation message
                  if (todayMotivation.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        todayMotivation,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Show daily challenges or empty state
                  if (dailyContentState.todayContent?.habitReminders.isNotEmpty == true) ...[
                    ...dailyContentState.todayContent!.habitReminders.map((habit) => Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: _buildDailyChallengeCard(
                        name: habit.name,
                        description: habit.description,
                        targetValue: habit.targetValue,
                        category: habit.category,
                      ),
                    )).toList(),
                  ] else ...[
                    // Empty state for daily challenges
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.emoji_events, size: 48, color: Colors.grey[400]),
                          SizedBox(height: 12),
                          Text(
                            'No challenges today',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap "Generate" to create fun mini-challenges',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 120), // Extra space for floating nav
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingCard({
    required String title,
    required int current,
    required int target,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    double progress = current / target;
    if (progress > 1) progress = 1;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '$current/$target',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (unit.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
          SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard({
    required String name,
    required String description,
    required String duration,
    required String difficulty,
    required String category,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        duration,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // Mark as complete (save to completed exercises)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exercise completed! 🎉')),
                  );
                  // TODO: Implement completion logic
                },
                icon: Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Complete',
              ),
              IconButton(
                onPressed: () {
                  // Cancel/Remove this exercise
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exercise removed')),
                  );
                  // TODO: Implement removal logic
                },
                icon: Icon(Icons.cancel, color: Colors.red),
                tooltip: 'Cancel',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeCard({
    required String name,
    required String description,
    required String targetValue,
    required String category,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    targetValue,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // Mark as complete (save to completed challenges)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Challenge completed! 🏆')),
                  );
                  // TODO: Implement completion logic
                },
                icon: Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Complete',
              ),
              IconButton(
                onPressed: () {
                  // Cancel/Remove this challenge
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Challenge skipped')),
                  );
                  // TODO: Implement removal logic
                },
                icon: Icon(Icons.cancel, color: Colors.red),
                tooltip: 'Skip',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
