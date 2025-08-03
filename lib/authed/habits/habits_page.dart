import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wellness/providers/habit_provider.dart';
import 'package:wellness/authed/habits/widgets/log_exercise_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_water_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_sleep_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_mood_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_custom_habit_sheet.dart';
import 'package:flutter/cupertino.dart';

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
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      backgroundColor: const Color(0xFFF6F8FB),
      body: habitAsync.when(
        data: (habit) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // วันที่
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.indigo, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    formatter.format(habit.date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Card: Exercise
              _buildCard(
                icon: Icons.directions_run,
                iconColor: Colors.green,
                gradient: const LinearGradient(colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)]),
                title: 'Exercise',
                content: habit.exercises.isEmpty
                    ? const Text("No exercise logged", style: TextStyle(color: Colors.black54))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: habit.exercises
                            .map((e) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Text("${e.type}  ", style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text("${e.durationMinutes} min", style: const TextStyle(color: Colors.black54)),
                                      if (e.calories > 0) ...[
                                        const SizedBox(width: 8),
                                        const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                                        Text(" ${e.calories} cal", style: const TextStyle(color: Colors.orange)),
                                      ]
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                action: ElevatedButton.icon(
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
                  icon: const Icon(Icons.add),
                  label: const Text("Log Exercise"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Card: Water Intake
              _buildCard(
                icon: Icons.water_drop,
                iconColor: Colors.blue,
                gradient: const LinearGradient(colors: [Color(0xFF74EBD5), Color(0xFFACB6E5)]),
                title: 'Water Intake',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          "${habit.waterLiters.toStringAsFixed(2)} / ${habit.waterGoalLiters.toStringAsFixed(1)} L",
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: (habit.waterLiters / habit.waterGoalLiters).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Note: 1 glass = 250 ml",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
                action: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        final updated = habit.copyWith(
                          waterLiters: (habit.waterLiters + 0.25).clamp(0, 5.0),
                        );
                        await ref.read(submitHabitProvider(updated));
                        ref.invalidate(habitTodayProvider); // refresh ข้อมูล
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("1 Glass"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[400], // เปลี่ยนเป็นสีหลัก
                        foregroundColor: Colors.white,     // ตัวหนังสือขาว
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
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
                      child: const Text("Adjust Amount"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue[900],
                        side: BorderSide(color: Colors.blue[200]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Card: Sleep
              _buildCard(
                icon: Icons.bedtime,
                iconColor: Colors.deepPurple,
                gradient: const LinearGradient(colors: [Color(0xFFD3CCE3), Color(0xFFE9E4F0)]),
                title: 'Sleep',
                content: habit.sleep != null
                    ? Row(
                        children: [
                          const SizedBox(width: 6),
                          Text(
                            '${habit.sleep!.bedtime.format(context)} - ${habit.sleep!.wakeup.format(context)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                          ...List.generate(
                            habit.sleep!.quality,
                            (i) => const Icon(Icons.star, color: Colors.amber, size: 20),
                          ),
                          ...List.generate(
                            5 - habit.sleep!.quality,
                            (i) => const Icon(Icons.star_border, color: Colors.amber, size: 20),
                          ),
                        ],
                      )
                    : const Text("No sleep data", style: TextStyle(color: Colors.black54)),
                action: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => LogSleepSheet(habit: habit),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Log Sleep"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Card: Mood
              _buildCard(
                icon: Icons.emoji_emotions,
                iconColor: Colors.orange,
                gradient: const LinearGradient(colors: [Color(0xFFFFE29F), Color(0xFFFFA99F)]),
                title: 'Mood',
                content: habit.mood != null
                    ? Row(
                        children: [
                          Text(habit.mood!.emoji, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 8),
                          Text(habit.mood!.note ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      )
                    : const Text("No mood tracked", style: TextStyle(color: Colors.black54)),
                action: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => LogMoodSheet(habit: habit),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Log Mood"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Card: Custom Habits
              _buildCard(
                icon: Icons.checklist,
                iconColor: Colors.teal,
                gradient: const LinearGradient(colors: [Color(0xFFB7F8DB), Color(0xFF50A7C2)]),
                title: 'Other Habits',
                content: habit.customHabits.isEmpty
                    ? const Text("No custom habits", style: TextStyle(color: Colors.black54))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: habit.customHabits
                            .map((h) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Text(h.icon, style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 6),
                                      Text(h.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 8),
                                      Text("(${h.durationMinutes} min)", style: const TextStyle(color: Colors.black54)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                action: ElevatedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (_) => LogCustomHabitSheet(habit: habit),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Habit"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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
    Gradient? gradient,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? Colors.white : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(icon, color: iconColor, size: 26),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              content,
              if (action != null) ...[
                const SizedBox(height: 14),
                action,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
