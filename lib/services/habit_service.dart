import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';

class HabitService {
  static final _db = FirebaseFirestore.instance;

  static String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  static CollectionReference get _habitCollection =>
      _db.collection('users').doc(_uid).collection('habits');

  // เพิ่มหรืออัปเดต Habit
  static Future<void> upsertHabit(Habit habit) async {
    final doc = habit.id.isEmpty
        ? _habitCollection.doc()
        : _habitCollection.doc(habit.id);
    print('💾 Saving Habit: ${habit.toJson()}');
    await doc.set(habit.copyWith(id: doc.id).toJson());
  }

  // โหลด habit รายวัน (ใช้วันที่)
  static Future<Habit?> getHabitByDate(DateTime date) async {
    final snapshot = await _habitCollection
        .where('date', isEqualTo: Timestamp.fromDate(date))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Habit.fromJson(doc.data() as Map<String, dynamic>, doc.id);
  }

  // อัปเดตบางฟิลด์ของ Habit โดยใช้ merge
  static Future<void> updateHabitField(String id, Map<String, dynamic> data) async {
    await _habitCollection.doc(id).update(data);
  }

  // ดึง stream สำหรับฟัง habit ทั้งหมด (เรียงจากล่าสุด)
  static Stream<List<Habit>> getHabitsStream() {
    return _habitCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Habit.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // ลบ Habit
  static Future<void> deleteHabit(String id) async {
    await _habitCollection.doc(id).delete();
  }
}
