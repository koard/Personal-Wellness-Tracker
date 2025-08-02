import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/providers/habit_provider.dart';

class LogExerciseSheet extends ConsumerStatefulWidget {
  final Habit habit;
  const LogExerciseSheet({super.key, required this.habit});

  @override
  ConsumerState<LogExerciseSheet> createState() => _LogExerciseSheetState();
}

class _LogExerciseSheetState extends ConsumerState<LogExerciseSheet> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Jogging';
  int _duration = 30;
  int _calories = 200;

  final List<String> _exerciseOptions = [
    'Jogging',
    'Walking',
    'Cycling',
    'Swimming',
    'Gym',
    'Yoga',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Log Exercise', style: Theme.of(context).textTheme.titleLarge),

              DropdownButtonFormField<String>(
                value: _type,
                items: _exerciseOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => _type = val!),
                decoration: const InputDecoration(labelText: 'Exercise Type'),
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _duration = int.tryParse(val) ?? _duration,
              ),

              TextFormField(
                decoration: const InputDecoration(labelText: 'Calories Burned'),
                keyboardType: TextInputType.number,
                onChanged: (val) => _calories = int.tryParse(val) ?? _calories,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submit,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    final newEntry = ExerciseEntry(
      type: _type,
      durationMinutes: _duration,
      calories: _calories,
    );
    final updated = widget.habit.copyWith(
      exercises: [...widget.habit.exercises, newEntry], // เพิ่มเข้า list เดิม
    );
    await ref.read(submitHabitProvider(updated));
    ref.invalidate(habitTodayProvider); // refresh ข้อมูล
    if (context.mounted) Navigator.pop(context);
  }
}
