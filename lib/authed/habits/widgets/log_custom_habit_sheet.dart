import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/providers/habit_provider.dart';

class LogCustomHabitSheet extends ConsumerStatefulWidget {
  final Habit habit;
  const LogCustomHabitSheet({super.key, required this.habit});

  @override
  ConsumerState<LogCustomHabitSheet> createState() => _LogCustomHabitSheetState();
}

class _LogCustomHabitSheetState extends ConsumerState<LogCustomHabitSheet> {
  static const String _defaultIcon = '•';
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Add Custom Habit', style: Theme.of(context).textTheme.titleLarge),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (name.trim().isEmpty) return;
                  final newCustomHabit = CustomHabit(
                    name: name.trim(),
                    durationMinutes: duration,
                    note: note.isEmpty ? null : note,
                    icon: _defaultIcon, 
                  );
                  final updated = widget.habit.copyWith(
                    customHabits: [...widget.habit.customHabits, newCustomHabit],
                  );
                  ref.read(submitHabitProvider(updated));
                  ref.invalidate(habitForDateProvider(widget.habit.date));
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