import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/providers/habit_provider.dart';

const moodEmojis = ['😃', '🙂', '😐', '😞', '😭'];

class LogMoodSheet extends ConsumerStatefulWidget {
  final Habit habit;
  const LogMoodSheet({super.key, required this.habit});

  @override
  ConsumerState<LogMoodSheet> createState() => _LogMoodSheetState();
}

class _LogMoodSheetState extends ConsumerState<LogMoodSheet> {
  String emoji = moodEmojis[0];
  String note = '';

  @override
  void initState() {
    super.initState();
    emoji = widget.habit.mood?.emoji ?? moodEmojis[0];
    note = widget.habit.mood?.note ?? '';
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
            Text('Log Mood', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: moodEmojis.map((e) => GestureDetector(
                onTap: () => setState(() => emoji = e),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: emoji == e ? Colors.orange[100] : null,
                  ),
                  child: Text(e, style: const TextStyle(fontSize: 28)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Note (optional)'),
              onChanged: (val) => note = val,
              controller: TextEditingController(text: note),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final updated = widget.habit.copyWith(
                  mood: MoodEntry(emoji: emoji, note: note.isEmpty ? null : note),
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
    );
  }
}