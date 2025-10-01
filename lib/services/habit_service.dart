import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/habit_model.dart';

/// HabitService
/// สำหรับจัดการข้อมูล Habit ของผู้ใช้ใน Firestore (ต่อผู้ใช้ 1 collection)
/// โครงสร้าง: users/{uid}/habits/{habitId}
/// หมายเหตุ:
///  - การค้นหาแบบรายวันด้วยเทียบ Timestamp แบบ isEqualTo จำเป็นต้องบันทึก date ของ Habit
///    ให้เป็นเวลาที่ "ตัดชั่วโมง/นาที/วินาทีแล้ว" (เช่น 2025-08-13 00:00:00) เพื่อให้ query ตรง
class HabitService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// UID ปัจจุบัน (โยน Exception หากยังไม่ได้ล็อกอิน)
  static String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  /// Reference ไปยัง collection habits ของผู้ใช้
  static CollectionReference<Map<String, dynamic>> get _habitCollection =>
      _db.collection('users').doc(_uid).collection('habits');

  /// เพิ่มหรืออัปเดต Habit (Merge)
  /// ต้องให้ habit.id มีค่า (ไม่ว่าง) ก่อนเรียก
  static Future<void> upsertHabit(Habit habit) async {
    await _habitCollection.doc(habit.id).set(
          habit.toJson(),
          SetOptions(merge: true),
        );
  }

  /// คืนค่า Habit ของวันที่ระบุ (อ้างอิงฟิลด์ date ที่เก็บเป็น Timestamp ณ เที่ยงคืนวันนั้น)
  /// หากไม่พบจะคืน null
  static Future<Habit?> getHabitByDate(DateTime date) async {
    final snapshot = await _habitCollection
        .where('date', isEqualTo: Timestamp.fromDate(date))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Habit.fromJson(doc.data(), doc.id);
  }

  /// อัปเดตเฉพาะบางฟิลด์ของ Habit โดยใช้ doc id
  static Future<void> updateHabitField(String id, Map<String, dynamic> data) async {
    await _habitCollection.doc(id).update(data);
  }

  /// Stream รายการ Habit ทั้งหมดของผู้ใช้ เรียงจากวันที่ใหม่ → เก่า
  static Stream<List<Habit>> getHabitsStream() {
    return _habitCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Habit.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  /// ลบ Habit
  static Future<void> deleteHabit(String id) async {
    await _habitCollection.doc(id).delete();
  }
}
