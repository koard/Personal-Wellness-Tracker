import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String userId;
  final DateTime date;

  final List<ExerciseEntry> exercises;
  final double waterLiters;
  final double waterGoalLiters;
  final SleepEntry? sleep;
  final MoodEntry? mood;
  final List<CustomHabit> customHabits;

  Habit({
    required this.id,
    required this.userId,
    required this.date,
    this.exercises = const [],
    this.waterLiters = 0.0,
    this.waterGoalLiters = 2.0, // ค่า default
    this.sleep,
    this.mood,
    this.customHabits = const [],
  });

  Habit copyWith({
    String? id,
    String? userId,
    DateTime? date,
    List<ExerciseEntry>? exercises,
    double? waterLiters,
    double? waterGoalLiters,
    SleepEntry? sleep,
    MoodEntry? mood,
    List<CustomHabit>? customHabits,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      exercises: exercises ?? this.exercises,
      waterLiters: waterLiters ?? this.waterLiters,
      waterGoalLiters: waterGoalLiters ?? this.waterGoalLiters,
      sleep: sleep ?? this.sleep,
      mood: mood ?? this.mood,
      customHabits: customHabits ?? this.customHabits,
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json, String docId) {
    return Habit(
      id: docId,
      userId: json['userId'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      waterLiters: (json['waterLiters'] ?? 0).toDouble(),
      waterGoalLiters: (json['waterGoalLiters'] ?? 2).toDouble(),
      sleep: json['sleep'] != null ? SleepEntry.fromJson(json['sleep']) : null,
      mood: json['mood'] != null ? MoodEntry.fromJson(json['mood']) : null,
      customHabits: (json['customHabits'] as List<dynamic>? ?? [])
          .map((e) => CustomHabit.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'waterLiters': waterLiters,
      'waterGoalLiters': waterGoalLiters,
      'sleep': sleep?.toJson(),
      'mood': mood?.toJson(),
      'customHabits': customHabits.map((e) => e.toJson()).toList(),
    };
  }
}

// ========================== Sub-Models ==========================

class ExerciseEntry {
  final String type;
  final int durationMinutes;
  final int calories;

  ExerciseEntry({
    required this.type,
    required this.durationMinutes,
    required this.calories,
  });

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) {
    return ExerciseEntry(
      type: json['type'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      calories: json['calories'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'durationMinutes': durationMinutes,
    'calories': calories,
  };
}

class SleepEntry {
  final TimeOfDay bedtime;
  final TimeOfDay wakeup;
  final int quality; // 1–5 ดาว

  SleepEntry({
    required this.bedtime,
    required this.wakeup,
    required this.quality,
  });

  factory SleepEntry.fromJson(Map<String, dynamic> json) {
    return SleepEntry(
      bedtime: TimeOfDay(hour: json['bedtime']['hour'], minute: json['bedtime']['minute']),
      wakeup: TimeOfDay(hour: json['wakeup']['hour'], minute: json['wakeup']['minute']),
      quality: json['quality'] ?? 3,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bedtime': {'hour': bedtime.hour, 'minute': bedtime.minute},
      'wakeup': {'hour': wakeup.hour, 'minute': wakeup.minute},
      'quality': quality,
    };
  }
}

class MoodEntry {
  final String emoji;
  final String? note;

  MoodEntry({
    required this.emoji,
    this.note,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      emoji: json['emoji'] ?? '🙂',
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'note': note,
    };
  }
}

class CustomHabit {
  final String name;
  final int durationMinutes;
  final String? note;
  final String icon; // emoji

  CustomHabit({
    required this.name,
    required this.durationMinutes,
    this.note,
    required this.icon,
  });

  factory CustomHabit.fromJson(Map<String, dynamic> json) {
    return CustomHabit(
      name: json['name'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 0,
      note: json['note'],
      icon: json['icon'] ?? '📌',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'durationMinutes': durationMinutes,
      'note': note,
      'icon': icon,
    };
  }
}
