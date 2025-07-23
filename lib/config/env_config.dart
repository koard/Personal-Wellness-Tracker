import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Android Firebase Configuration
  static String get firebaseAndroidApiKey => dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';
  static String get firebaseAndroidAuthDomain => dotenv.env['FIREBASE_ANDROID_AUTH_DOMAIN'] ?? '';
  static String get firebaseAndroidProjectId => dotenv.env['FIREBASE_ANDROID_PROJECT_ID'] ?? '';
  static String get firebaseAndroidStorageBucket => dotenv.env['FIREBASE_ANDROID_STORAGE_BUCKET'] ?? '';
  static String get firebaseAndroidMessagingSenderId => dotenv.env['FIREBASE_ANDROID_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAndroidAppId => dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '';
  
  // Web Firebase Configuration
  static String get firebaseWebApiKey => dotenv.env['FIREBASE_WEB_API_KEY'] ?? '';
  static String get firebaseWebAuthDomain => dotenv.env['FIREBASE_WEB_AUTH_DOMAIN'] ?? '';
  static String get firebaseWebProjectId => dotenv.env['FIREBASE_WEB_PROJECT_ID'] ?? '';
  static String get firebaseWebStorageBucket => dotenv.env['FIREBASE_WEB_STORAGE_BUCKET'] ?? '';
  static String get firebaseWebMessagingSenderId => dotenv.env['FIREBASE_WEB_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseWebAppId => dotenv.env['FIREBASE_WEB_APP_ID'] ?? '';
  static String get firebaseWebMeasurementId => dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'] ?? '';
  
  /// Load environment variables
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }
}
