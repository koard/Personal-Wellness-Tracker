// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal Wellness Tracker';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardGoodMorning(String name) {
    return 'Good Morning, $name!';
  }

  @override
  String get dashboardCalories => 'Calories';

  @override
  String get dashboardWater => 'Water';

  @override
  String get dashboardGlasses => 'glasses';

  @override
  String get dashboardTodaysActivity => 'Today\'s Activity';

  @override
  String get dashboardOngoing => 'Ongoing';

  @override
  String get dashboardNext => 'Next';

  @override
  String get dashboardDailyHabits => 'Daily Habits';

  @override
  String get dashboardAdd => 'Add';

  @override
  String get dashboardDone => 'Done';

  @override
  String dashboardDaysStreak(int days) {
    return '$days days streak';
  }

  @override
  String dashboardMinutes(int count) {
    return '$count Min';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileUserProfile => 'User Profile';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileDisplayName => 'Display Name';

  @override
  String get profileJoinedDate => 'Joined Date';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get profileAbout => 'About';

  @override
  String get profileVersion => 'Version';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String get profileNoDisplayName => 'No display name set';

  @override
  String get profileNotAvailable => 'Not available';

  @override
  String get profileChangeLanguage => 'Change Language';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationHabits => 'Habits';

  @override
  String get navigationMeals => 'Meals';

  @override
  String get navigationProgress => 'Progress';

  @override
  String get navigationGoals => 'Goals';

  @override
  String get navigationProfile => 'Profile';

  @override
  String get commonLanguage => 'Language';

  @override
  String get commonEnglish => 'English';

  @override
  String get commonThai => 'ไทย';

  @override
  String get commonLogout => 'Logout';
}
