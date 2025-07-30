import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/providers/habit_provider.dart';
import 'package:wellness/authed/habits/widgets/log_exercise_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_water_sheet.dart';

class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitAsync = ref.watch(habitTodayProvider);
    final formatter = DateFormat('d MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Habits"),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[50],
      body: habitAsync.when(
        data: (habit) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // วันที่
              Text(
                '📅 ${formatter.format(habit.date)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Card: Exercise
              _buildCard(
                icon: Icons.directions_run,
                iconColor: Colors.green,
                title: 'Exercise',
                content: habit.exercises.isEmpty
                    ? const Text("No exercise logged")
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: habit.exercises
                            .map((e) => Text("• ${e.type} - ${e.durationMinutes} min, ${e.calories} cal"))
                            .toList(),
                      ),
                action: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => LogExerciseSheet(habit: habit),
                    );
                  },
                  child: const Text("+ Log Exercise"),
                ),
              ),
              const SizedBox(height: 16),

              // Card: Water Intake
              _buildCard(
                icon: Icons.water_drop,
                iconColor: Colors.blue,
                title: 'Water Intake',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${habit.waterLiters}/${habit.waterGoalLiters} ลิตร',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: (habit.waterLiters / habit.waterGoalLiters).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
                action: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => LogWaterSheet(habit: habit),
                    );
                  },
                  child: const Text("+ Add Water"),
                ),
              ),
              const SizedBox(height: 16),

              // Card: Sleep
              _buildCard(
                icon: Icons.bedtime,
                iconColor: Colors.deepPurple,
                title: 'Sleep',
                content: habit.sleep != null
                    ? Text(
                        '🕐 ${habit.sleep!.bedtime.format(context)} - ${habit.sleep!.wakeup.format(context)} | ⭐ ${habit.sleep!.quality}/5')
                    : const Text("No sleep data"),
              ),
              const SizedBox(height: 16),

              // Card: Mood
              _buildCard(
                icon: Icons.emoji_emotions,
                iconColor: Colors.orange,
                title: 'Mood',
                content: habit.mood != null
                    ? Text("• ${habit.mood!.emoji} ${habit.mood!.note ?? ''}")
                    : const Text("No mood tracked"),
              ),
              const SizedBox(height: 16),

              // Card: Custom Habits
              _buildCard(
                icon: Icons.checklist,
                iconColor: Colors.teal,
                title: 'Other Habits',
                content: habit.customHabits.isEmpty
                    ? const Text("No custom habits")
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: habit.customHabits
                            .map((h) => Text("• ${h.icon} ${h.name} (${h.durationMinutes} min)"))
                            .toList(),
                      ),
                action: ElevatedButton(
                  onPressed: () {
                    // TODO: Add custom habit sheet
                  },
                  child: const Text("+ Add Habit"),
                ),
              ),

              const SizedBox(height: 100), // Space for nav bar
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          content,
          if (action != null) ...[
            const SizedBox(height: 12),
            action,
          ],
        ],
      ),
    );
  }
}
