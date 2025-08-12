import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wellness/models/habit_model.dart';
import 'package:wellness/services/habit_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

final habitServiceProvider = Provider((ref) => HabitService());

// วันที่ที่ผู้ใช้กำลังดู (เริ่มต้น = วันนี้)
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
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

// ดึง habit ตามวันที่ (สร้างใหม่ถ้าเป็นวันนี้ และยังไม่มีข้อมูล)
final habitForDateProvider = FutureProvider.family<Habit?, DateTime>((ref, date) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final day = DateTime(date.year, date.month, date.day);
  Habit? habit = await HabitService.getHabitByDate(day);
  if (habit != null) return habit;

  // สร้างใหม่สำหรับทุกวันที่ (ย้อนหลัง/วันนี้) แต่ไม่สร้างล่วงหน้าในอนาคต
  final today = DateTime.now();
  final todayOnly = DateTime(today.year, today.month, today.day);
  if (day.isAfter(todayOnly)) return null; // ไม่สร้างอนาคต

  final newHabit = Habit(
    id: '${user.uid}_${day.toIso8601String()}',
    userId: user.uid,
    date: day,
    exercises: [],
    waterLiters: 0,
    waterGoalLiters: 2,
    sleep: null,
    mood: null,
    customHabits: [],
  );
  await HabitService.upsertHabit(newHabit);
  return newHabit;
});
