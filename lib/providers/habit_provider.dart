import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/services/habit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final habitServiceProvider = Provider((ref) => HabitService());

// ดึง habit วันนี้ (หรือสร้างใหม่ถ้ายังไม่มี)
final habitTodayProvider = FutureProvider<Habit>((ref) async {
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  Habit? habit = await HabitService.getHabitByDate(today);

  if (habit != null) {
    return habit;
  } else {
    // สร้าง id ใหม่ (เช่นใช้ Firestore doc id หรือ timestamp)
    final newHabit = Habit(
      id: '${userId}_${today.toIso8601String()}',
      userId: userId,
      date: today,
      exercises: [],
      waterLiters: 0,
      waterGoalLiters: 2,
      sleep: null,
      mood: null,
      customHabits: [],
    );
    await HabitService.upsertHabit(newHabit);
    return newHabit;
  }
});

// ดึง habit ทั้งหมด (เรียงจากวันล่าสุด)
final habitListStreamProvider = StreamProvider<List<Habit>>((ref) {
  return HabitService.getHabitsStream();
});

// ดึง habit ตามวันที่
final habitByDateProvider = FutureProvider.family<Habit?, DateTime>((ref, date) {
  return HabitService.getHabitByDate(date);
});

// สร้างหรืออัปเดต habit
final submitHabitProvider = FutureProvider.family<void, Habit>((ref, habit) async {
  return HabitService.upsertHabit(habit);
});
