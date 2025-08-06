class Meal {
  final String id;
  final String foodName;
  final int calories;
  final String imagePath;
  final DateTime timestamp;
  final String mealType;
  final double carbs; // in grams
  final double protein; // in grams
  final double fat; // in grams

  Meal({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.imagePath,
    required this.timestamp,
    required this.mealType,
    this.carbs = 0.0,
    this.protein = 0.0,
    this.fat = 0.0,
  });

  Meal copyWith({
    String? id,
    String? foodName,
    int? calories,
    String? imagePath,
    DateTime? timestamp,
    String? mealType,
    double? carbs,
    double? protein,
    double? fat,
  }) {
    return Meal(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      mealType: mealType ?? this.mealType,
      carbs: carbs ?? this.carbs,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'imagePath': imagePath,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'mealType': mealType,
      'carbs': carbs,
      'protein': protein,
      'fat': fat,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] ?? '',
      foodName: map['foodName'] ?? '',
      calories: map['calories']?.toInt() ?? 0,
      imagePath: map['imagePath'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      mealType: map['mealType'] ?? '',
      carbs: map['carbs']?.toDouble() ?? 0.0,
      protein: map['protein']?.toDouble() ?? 0.0,
      fat: map['fat']?.toDouble() ?? 0.0,
    );
  }

  @override
  String toString() {
    return 'Meal(id: $id, foodName: $foodName, calories: $calories, imagePath: $imagePath, timestamp: $timestamp, mealType: $mealType, carbs: $carbs, protein: $protein, fat: $fat)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Meal &&
      other.id == id &&
      other.foodName == foodName &&
      other.calories == calories &&
      other.imagePath == imagePath &&
      other.timestamp == timestamp &&
      other.mealType == mealType &&
      other.carbs == carbs &&
      other.protein == protein &&
      other.fat == fat;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      foodName.hashCode ^
      calories.hashCode ^
      imagePath.hashCode ^
      timestamp.hashCode ^
      mealType.hashCode ^
      carbs.hashCode ^
      protein.hashCode ^
      fat.hashCode;
  }
}
