import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/providers/habit_provider.dart';

class LogWaterSheet extends ConsumerStatefulWidget {
  final Habit habit;

  const LogWaterSheet({super.key, required this.habit});

  @override
  ConsumerState<LogWaterSheet> createState() => _LogWaterSheetState();
}

class _LogWaterSheetState extends ConsumerState<LogWaterSheet> {
  late double liters;
  late double goal;

  @override
  void initState() {
    super.initState();
    liters = widget.habit.waterLiters;
    goal = widget.habit.waterGoalLiters;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Log Water Intake', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // ปริมาณน้ำ
            TextFormField(
              decoration: const InputDecoration(labelText: 'Water (liters)'),
              initialValue: liters.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => liters = double.tryParse(val) ?? liters),
            ),

            const SizedBox(height: 16),

            // เป้าหมาย
            TextFormField(
              decoration: const InputDecoration(labelText: 'Goal (liters)'),
              initialValue: goal.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => goal = double.tryParse(val) ?? goal),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final updated = widget.habit.copyWith(
                  waterLiters: liters,
                  waterGoalLiters: goal,
                );
                ref.read(submitHabitProvider(updated));
                ref.invalidate(habitTodayProvider); // refresh ข้อมูล
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}
