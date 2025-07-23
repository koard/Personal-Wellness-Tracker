// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'แอปติดตามสุขภาพส่วนบุคคล';

  @override
  String get dashboardTitle => 'แดชบอร์ด';

  @override
  String dashboardGoodMorning(String name) {
    return 'สวัสดีตอนเช้า $name!';
  }

  @override
  String get dashboardCalories => 'แคลอรี่';

  @override
  String get dashboardWater => 'น้ำ';

  @override
  String get dashboardGlasses => 'แก้ว';

  @override
  String get dashboardTodaysActivity => 'กิจกรรมวันนี้';

  @override
  String get dashboardOngoing => 'กำลังดำเนินการ';

  @override
  String get dashboardNext => 'ถัดไป';

  @override
  String get dashboardDailyHabits => 'กิจวัตรประจำวัน';

  @override
  String get dashboardAdd => 'เพิ่ม';

  @override
  String get dashboardDone => 'เสร็จแล้ว';

  @override
  String dashboardDaysStreak(int days) {
    return 'ติดต่อกัน $days วัน';
  }

  @override
  String dashboardMinutes(int count) {
    return '$count นาที';
  }

  @override
  String get profileTitle => 'โปรไฟล์';

  @override
  String get profileUserProfile => 'ข้อมูลผู้ใช้';

  @override
  String get profileEmail => 'อีเมล';

  @override
  String get profileDisplayName => 'ชื่อที่แสดง';

  @override
  String get profileJoinedDate => 'วันที่เข้าร่วม';

  @override
  String get profileSettings => 'การตั้งค่า';

  @override
  String get profileEditProfile => 'แก้ไขโปรไฟล์';

  @override
  String get profileNotifications => 'การแจ้งเตือน';

  @override
  String get profilePrivacy => 'ความเป็นส่วนตัว';

  @override
  String get profileAbout => 'เกี่ยวกับ';

  @override
  String get profileVersion => 'เวอร์ชัน';

  @override
  String get profileSignOut => 'ออกจากระบบ';

  @override
  String get profileNoDisplayName => 'ไม่ได้ตั้งชื่อที่แสดง';

  @override
  String get profileNotAvailable => 'ไม่พร้อมใช้งาน';

  @override
  String get profileChangeLanguage => 'เปลี่ยนภาษา';

  @override
  String get navigationHome => 'หน้าแรก';

  @override
  String get navigationHabits => 'กิจวัตร';

  @override
  String get navigationMeals => 'อาหาร';

  @override
  String get navigationProgress => 'ความคืบหน้า';

  @override
  String get navigationGoals => 'เป้าหมาย';

  @override
  String get navigationProfile => 'โปรไฟล์';

  @override
  String get commonLanguage => 'ภาษา';

  @override
  String get commonEnglish => 'English';

  @override
  String get commonThai => 'ไทย';

  @override
  String get commonLogout => 'ออกจากระบบ';
}
