import 'package:cloud_firestore/cloud_firestore.dart';

/// Basic user authentication and account information
/// For detailed profile data, see UserProfile model
class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? profileImage;
  final bool isProfileSetupComplete; // Tracks if comprehensive profile is done
  final bool isOnboardingComplete;
  final String? preferredLanguage; // 'en', 'th'
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Legacy fields for backwards compatibility (will be migrated to UserProfile)
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.profileImage,
    this.isProfileSetupComplete = false,
    this.isOnboardingComplete = false,
    this.preferredLanguage = 'en',
    required this.createdAt,
    required this.updatedAt,
    // Legacy fields
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'],
      email: data['email'],
      profileImage: data['profileImage'],
      isProfileSetupComplete: data['isProfileSetupComplete'] ?? false,
      isOnboardingComplete: data['isOnboardingComplete'] ?? false,
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      // Legacy fields
      age: data['age']?.toInt(),
      gender: data['gender'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      goal: data['goal'],
    );
  }

  // Factory constructor to create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      name: data['name'],
      email: data['email'],
      profileImage: data['profileImage'],
      isProfileSetupComplete: data['isProfileSetupComplete'] ?? false,
      isOnboardingComplete: data['isOnboardingComplete'] ?? false,
      preferredLanguage: data['preferredLanguage'] ?? 'en',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      // Legacy fields
      age: data['age']?.toInt(),
      gender: data['gender'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      goal: data['goal'],
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'isProfileSetupComplete': isProfileSetupComplete,
      'isOnboardingComplete': isOnboardingComplete,
      'preferredLanguage': preferredLanguage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      // Legacy fields
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal': goal,
    };
  }

  // Create a copy of UserModel with updated values
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImage,
    bool? isProfileSetupComplete,
    bool? isOnboardingComplete,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Legacy fields
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? goal,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      isProfileSetupComplete: isProfileSetupComplete ?? this.isProfileSetupComplete,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // Legacy fields
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
    );
  }
}
