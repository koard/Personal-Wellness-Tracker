import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/providers/habit_provider.dart';

class LogSleepSheet extends ConsumerStatefulWidget {
  final Habit habit;
  const LogSleepSheet({super.key, required this.habit});

  @override
  ConsumerState<LogSleepSheet> createState() => _LogSleepSheetState();
}

class _LogSleepSheetState extends ConsumerState<LogSleepSheet> {
  late TimeOfDay bedtime;
  late TimeOfDay wakeup;
  int quality = 0;

  @override
  void initState() {
    super.initState();
    bedtime = widget.habit.sleep?.bedtime ?? const TimeOfDay(hour: 22, minute: 00);
    wakeup = widget.habit.sleep?.wakeup ?? const TimeOfDay(hour: 6, minute: 00);
    quality = widget.habit.sleep?.quality ?? 0;
  }

  Future<void> pickTime(BuildContext context, bool isBedtime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? bedtime : wakeup,
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) bedtime = picked;
        else wakeup = picked;
      });
    }
  }

  void _submit() async {
    final updated = widget.habit.copyWith(
      sleep: SleepEntry(bedtime: bedtime, wakeup: wakeup, quality: quality),
    );
    await ref.read(submitHabitProvider(updated));
    ref.invalidate(habitTodayProvider);
    if (context.mounted) Navigator.pop(context);
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
            Text('Log Sleep', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
              const Text("Bedtime: "),
              TextButton(
                onPressed: () => pickTime(context, true),
                child: Text(bedtime.format(context)),
              ),
              ],
            ),
            Row(
              children: [
              const Text("Wake up: "),
              TextButton(
                onPressed: () => pickTime(context, false),
                child: Text(wakeup.format(context)),
              ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("Sleep quality:"),
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  IconButton(
                    icon: Icon(
                      i <= quality ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                    ),
                    onPressed: () => setState(() => quality = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}