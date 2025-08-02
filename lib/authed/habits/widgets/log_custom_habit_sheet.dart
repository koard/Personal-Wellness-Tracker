import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/providers/habit_provider.dart';

const customIcons = ['📖', '🧘‍♂️', '🎨', '🎸', '📝', '🏆', '📚', '🧹', '🧑‍💻', '🧑‍🍳'];

class LogCustomHabitSheet extends ConsumerStatefulWidget {
  final Habit habit;
  const LogCustomHabitSheet({super.key, required this.habit});

  @override
  ConsumerState<LogCustomHabitSheet> createState() => _LogCustomHabitSheetState();
}

class _LogCustomHabitSheetState extends ConsumerState<LogCustomHabitSheet> {
  String icon = customIcons[0];
  String name = '';
  int duration = 10;
  String note = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add Custom Habit', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: customIcons.map((e) => GestureDetector(
                  onTap: () => setState(() => icon = e),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: icon == e ? Colors.teal[100] : null,
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 28)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Habit Name'),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => duration = int.tryParse(val) ?? duration,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Note (optional)'),
                onChanged: (val) => note = val,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (name.trim().isEmpty) return;
                  final updated = widget.habit.copyWith(
                    customHabits: [
                      ...widget.habit.customHabits,
                      CustomHabit(
                        name: name.trim(),
                        durationMinutes: duration,
                        note: note.isEmpty ? null : note,
                        icon: icon,
                      ),
                    ],
                  );
                  await ref.read(submitHabitProvider(updated));
                  ref.invalidate(habitTodayProvider);
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}