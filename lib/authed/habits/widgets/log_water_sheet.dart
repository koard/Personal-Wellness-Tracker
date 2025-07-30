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
            const Text("ปรับการดื่มน้ำวันนี้", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // ปริมาณน้ำ
            Text("ปริมาณที่ดื่ม (ลิตร): ${liters.toStringAsFixed(2)}"),
            Slider(
              value: liters,
              min: 0,
              max: 5,
              divisions: 20,
              label: "${liters.toStringAsFixed(2)} ลิตร",
              onChanged: (val) => setState(() => liters = val),
            ),

            const SizedBox(height: 16),

            // เป้าหมาย
            Text("เป้าหมายวันนี้ (ลิตร): ${goal.toStringAsFixed(1)}"),
            Slider(
              value: goal,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              label: "${goal.toStringAsFixed(1)} ลิตร",
              onChanged: (val) => setState(() => goal = val),
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final updated = widget.habit.copyWith(
                  waterLiters: liters,
                  waterGoalLiters: goal,
                );
                ref.read(submitHabitProvider(updated));
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text("บันทึก"),
            )
          ],
        ),
      ),
    );
  }
}
