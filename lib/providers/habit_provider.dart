import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/services/habit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider สำหรับเรียกใช้ service
final habitServiceProvider = Provider((ref) => HabitService());

// ดึง habit วันนี้ (หรือสร้างใหม่ถ้ายังไม่มี)
final habitTodayProvider = FutureProvider<Habit>((ref) async {
  final today = DateTime.now();
  final habit = await HabitService.getHabitByDate(today);
  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  return habit ?? Habit(id: '', userId: userId, date: today);
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
