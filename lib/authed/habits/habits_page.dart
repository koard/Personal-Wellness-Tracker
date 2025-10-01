import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wellness/providers/habit_provider.dart';
import 'package:wellness/authed/habits/widgets/log_exercise_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_water_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_sleep_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_mood_sheet.dart';
import 'package:wellness/authed/habits/widgets/log_custom_habit_sheet.dart';
import 'package:wellness/models/habit_model.dart';

/// HabitsPage
/// Daily overview of tracked habits for a selected date (default: today).
/// Data source: habitForDateProvider(date).
/// Logging actions open bottom sheets then invalidate the provider to refresh.
class HabitsPage extends ConsumerWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedDateProvider);
    final habitAsync = ref.watch(habitForDateProvider(date));
    final dateText = DateFormat('d MMM yyyy').format(date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habits'),
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
              children: [
                _DateSwitcher(
                  formatted: dateText,
                  date: date,
                  onPrev: () => ref.read(selectedDateProvider.notifier).state =
                      date.subtract(const Duration(days: 1)),
                  onNext: date.isBefore(_todayOnly())
                      ? () => ref.read(selectedDateProvider.notifier).state =
                          date.add(const Duration(days: 1))
                      : null,
                  onPick: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      ref.read(selectedDateProvider.notifier).state =
                          DateTime(picked.year, picked.month, picked.day);
                    }
                  },
                ),
                const SizedBox(height: 16),
                if (habit == null)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('No data for this day', style: TextStyle(color: Colors.black54)),
                  )
                else
                  Column(
                    children: [
                      _exerciseCard(habit, date, ref, context),
                      _waterCard(habit, date, ref),
                      _sleepCard(habit, date, ref, context),
                      _moodCard(habit, date, ref, context),
                      _customHabitsCard(habit, date, ref),
                      const SizedBox(height: 100),
                    ],
                  ),
              ],
            ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // -------------------- Section Cards --------------------

  Widget _exerciseCard(Habit habit, DateTime date, WidgetRef ref, BuildContext context) {
    return _buildCard(
      title: 'Exercise',
      icon: Icons.directions_run,
      iconColor: Colors.green,
      gradient: const LinearGradient(colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)]),
      content: habit.exercises.isEmpty
          ? const Text('No exercise logged', style: TextStyle(color: Colors.black54))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: habit.exercises.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.1)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(e.type, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('${e.durationMinutes} min', style: const TextStyle(color: Colors.black54)),
                            if (e.calories > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                                  Text(' ${e.calories} cal', style: const TextStyle(color: Colors.orange)),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
      action: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Log Exercise'),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => LogExerciseSheet(habit: habit),
        ),
        style: _btnStyle(Colors.green[400]),
      ),
    );
  }

  Widget _waterCard(Habit habit, DateTime date, WidgetRef ref) {
    // Mock target goal: 3.1 L (display and progress)
    const double mockWaterGoalLiters = 3.1;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: _buildCard(
        title: 'Water Intake',
        icon: Icons.water_drop,
        iconColor: Colors.blue,
        gradient: const LinearGradient(colors: [Color(0xFF74EBD5), Color(0xFFACB6E5)]),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  '${habit.waterLiters.toStringAsFixed(2)} / ${mockWaterGoalLiters.toStringAsFixed(1)} L',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: (habit.waterLiters / mockWaterGoalLiters).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 6),
            const Text('Note: 1 glass = 250 ml', style: TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        action: Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('1 Glass'),
              style: _btnStyle(Colors.blue[400]),
              onPressed: () {
                final updated = habit.copyWith(
                  waterLiters: (habit.waterLiters + 0.25).clamp(0, 5.0),
                  waterGoalLiters: mockWaterGoalLiters,
                );
                ref.read(submitHabitProvider(updated));
                ref.invalidate(habitForDateProvider(date));
              },
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _openSheet(
                builder: (c) => LogWaterSheet(habit: habit),
                context: ref.context,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue[900],
                side: BorderSide(color: Colors.blue[200]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Adjust Amount'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sleepCard(Habit habit, DateTime date, WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: _buildCard(
        title: 'Sleep',
        icon: Icons.bedtime,
        iconColor: Colors.deepPurple,
        gradient: const LinearGradient(colors: [Color(0xFFD3CCE3), Color(0xFFE9E4F0)]),
        content: habit.sleep == null
            ? const Text('No sleep data', style: TextStyle(color: Colors.black54))
            : Row(
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
              ),
        action: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Log Sleep'),
          style: _btnStyle(Colors.deepPurple[400]),
          onPressed: () => _openSheet(
            builder: (_) => LogSleepSheet(habit: habit),
            context: context,
          ),
        ),
      ),
    );
  }

  Widget _moodCard(Habit habit, DateTime date, WidgetRef ref, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: _buildCard(
        title: 'Mood',
        icon: Icons.emoji_emotions,
        iconColor: Colors.orange,
        gradient: const LinearGradient(colors: [Color(0xFFFFE29F), Color(0xFFFFA99F)]),
        content: habit.mood == null
            ? const Text('No mood tracked', style: TextStyle(color: Colors.black54))
            : Row(
                children: [
                  Text(habit.mood!.emoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 8),
                  Text(
                    habit.mood!.note ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
        action: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Log Mood'),
          style: _btnStyle(Colors.orange[400]),
          onPressed: () => _openSheet(
            builder: (_) => LogMoodSheet(habit: habit),
            context: context,
          ),
        ),
      ),
    );
  }

  Widget _customHabitsCard(Habit habit, DateTime date, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: _buildCard(
        title: 'Other Habits',
        icon: Icons.checklist,
        iconColor: Colors.teal,
        gradient: const LinearGradient(colors: [Color(0xFFB7F8DB), Color(0xFF50A7C2)]),
        content: habit.customHabits.isEmpty
            ? const Text('No custom habits', style: TextStyle(color: Colors.black54))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: habit.customHabits.map((h) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text(h.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 6),
                        Text(h.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Text('(${h.durationMinutes} min)',
                            style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  );
                }).toList(),
              ),
        action: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Habit'),
          style: _btnStyle(Colors.teal[400]),
          onPressed: () => _openSheet(
            builder: (_) => LogCustomHabitSheet(habit: habit),
            context: ref.context,
          ),
        ),
      ),
    );
  }

  // -------------------- Shared UI Helpers --------------------

  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
    Widget? action,
    Gradient? gradient,
  }) {
    return Container(
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

  ButtonStyle _btnStyle(Color? c) => ElevatedButton.styleFrom(
        backgroundColor: c,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );

  void _openSheet({
    required WidgetBuilder builder,
    required BuildContext context,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: builder,
    );
  }

  static DateTime _todayOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

/// Date selector row (prev / date picker / next).
class _DateSwitcher extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPrev;
  final VoidCallback? onNext;
  final VoidCallback onPick;
  final String formatted;
  const _DateSwitcher({
    required this.date,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
    required this.formatted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous day',
          icon: const Icon(Icons.chevron_left),
          onPressed: onPrev,
        ),
        Expanded(
          child: InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                formatted,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo,
                ),
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          icon: const Icon(Icons.chevron_right),
          onPressed: onNext,
        ),
      ],
    );
  }
}
