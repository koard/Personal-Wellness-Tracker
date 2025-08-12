import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/daily_content_models.dart';
import '../models/user_profile_model.dart';
import '../services/gemini_profile_analyzer.dart';

/// Service for managing daily AI-generated content
class DailyContentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }
  
  /// Get today's content
  static Future<DailyContent?> getTodayContent() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return getContentForDate(today);
  }
  
  /// Get content for specific date
  static Future<DailyContent?> getContentForDate(String date) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(_uid)
          .collection('dailyContent')
          .doc(date)
          .get();
      
      if (doc.exists && doc.data() != null) {
        return DailyContent.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting daily content: $e');
      return null;
    }
  }
  
  /// Save daily content to Firestore
  static Future<bool> saveDailyContent(DailyContent content) async {
    try {
      await _db
          .collection('users')
          .doc(_uid)
          .collection('dailyContent')
          .doc(content.date)
          .set(content.toMap());
      return true;
    } catch (e) {
      print('Error saving daily content: $e');
      return false;
    }
  }
  
  /// Generate today's content if it doesn't exist
  static Future<DailyContent?> generateTodayContentIfNeeded(UserProfile profile) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Check if content already exists
    final existingContent = await getContentForDate(today);
    if (existingContent != null) {
      return existingContent;
    }
    
    // Generate new content
    return generateContentForDate(today, profile);
  }
  
  /// Generate content for specific date
  static Future<DailyContent?> generateContentForDate(String date, UserProfile profile) async {
    try {
      // Use AI to generate content based on profile
      final content = await _generateAIContent(date, profile);
      
      // Save to Firestore
      final success = await saveDailyContent(content);
      if (success) {
        // Update generation metadata
        await _updateGenerationMetadata(date);
        return content;
      }
      
      return null;
    } catch (e) {
      print('Error generating daily content: $e');
      // Return fallback content
      return _generateFallbackContent(date, profile);
    }
  }
  
  /// Generate AI-powered daily content
  static Future<DailyContent> _generateAIContent(String date, UserProfile profile) async {
    // For now, create basic content structure
    // This will be enhanced with actual Gemini AI generation later
    
    final mealSuggestions = _generateBasicMealSuggestions(profile);
    final activitySuggestions = _generateBasicActivitySuggestions(profile);
    final habitReminders = _generateBasicHabitReminders(profile);
    
    return DailyContent(
      date: date,
      mealSuggestions: mealSuggestions,
      activitySuggestions: activitySuggestions,
      habitReminders: habitReminders,
      waterIntakeGoal: profile.recommendedWaterIntake,
      motivationalMessage: _generateMotivationalMessage(profile),
      generatedAt: DateTime.now(),
      profileVersion: '${profile.updatedAt.millisecondsSinceEpoch}',
    );
  }
  
  /// Generate fallback content when AI fails
  static DailyContent _generateFallbackContent(String date, UserProfile profile) {
    return DailyContent(
      date: date,
      mealSuggestions: [
        const DailyMealSuggestion(
          name: 'Thai Vegetable Soup',
          description: 'Light and nutritious soup with mixed vegetables',
          estimatedCalories: 150,
          ingredients: ['Mixed vegetables', 'Clear broth', 'Herbs'],
          cookingTime: '15 minutes',
          mealType: 'lunch',
          difficulty: 'easy',
          tags: ['thai', 'healthy', 'low-calorie'],
        ),
      ],
      activitySuggestions: [
        const DailyActivitySuggestion(
          name: 'Morning Walk',
          description: 'Gentle walk around the neighborhood',
          durationMinutes: 20,
          difficulty: 'easy',
          category: 'cardio',
          equipment: [],
        ),
      ],
      habitReminders: [
        const DailyHabitReminder(
          name: 'Drink Water',
          description: 'Stay hydrated throughout the day',
          category: 'hydration',
          reminder: 'Drink a glass of water every 2 hours',
          targetValue: '8 glasses',
        ),
      ],
      waterIntakeGoal: profile.recommendedWaterIntake,
      motivationalMessage: 'Every small step counts towards your wellness journey!',
      generatedAt: DateTime.now(),
      profileVersion: '${profile.updatedAt.millisecondsSinceEpoch}',
    );
  }
  
  /// Generate basic meal suggestions based on profile
  static List<DailyMealSuggestion> _generateBasicMealSuggestions(UserProfile profile) {
    final List<DailyMealSuggestion> meals = [];
    
    // Breakfast
    meals.add(const DailyMealSuggestion(
      name: 'Thai Rice Porridge',
      description: 'Comforting rice porridge with ginger and herbs',
      estimatedCalories: 250,
      ingredients: ['Jasmine rice', 'Ginger', 'Green onions'],
      cookingTime: '20 minutes',
      mealType: 'breakfast',
      difficulty: 'easy',
      tags: ['thai', 'comfort-food'],
    ));
    
    // Lunch
    meals.add(const DailyMealSuggestion(
      name: 'Som Tam',
      description: 'Fresh papaya salad with lime and chilies',
      estimatedCalories: 180,
      ingredients: ['Green papaya', 'Lime', 'Chilies', 'Peanuts'],
      cookingTime: '10 minutes',
      mealType: 'lunch',
      difficulty: 'medium',
      tags: ['thai', 'fresh', 'spicy'],
    ));
    
    // Dinner
    meals.add(const DailyMealSuggestion(
      name: 'Grilled Fish with Vegetables',
      description: 'Healthy grilled fish with steamed vegetables',
      estimatedCalories: 320,
      ingredients: ['Fish fillet', 'Mixed vegetables', 'Thai herbs'],
      cookingTime: '25 minutes',
      mealType: 'dinner',
      difficulty: 'medium',
      tags: ['healthy', 'protein-rich'],
    ));
    
    return meals;
  }
  
  /// Generate basic activity suggestions based on profile
  static List<DailyActivitySuggestion> _generateBasicActivitySuggestions(UserProfile profile) {
    final activities = <DailyActivitySuggestion>[];
    
    // Adjust based on fitness level
    if (profile.fitnessLevel == 'beginner') {
      activities.add(const DailyActivitySuggestion(
        name: 'Gentle Stretching',
        description: 'Basic stretching routine for flexibility',
        durationMinutes: 15,
        difficulty: 'easy',
        category: 'flexibility',
        equipment: ['mat'],
      ));
    } else {
      activities.add(const DailyActivitySuggestion(
        name: 'Bodyweight Workout',
        description: 'Quick bodyweight exercises for strength',
        durationMinutes: 25,
        difficulty: 'medium',
        category: 'strength',
        equipment: [],
      ));
    }
    
    // Add mindfulness activity
    activities.add(const DailyActivitySuggestion(
      name: 'Breathing Exercise',
      description: 'Simple breathing meditation for relaxation',
      durationMinutes: 10,
      difficulty: 'easy',
      category: 'mindfulness',
      equipment: [],
    ));
    
    return activities;
  }
  
  /// Generate basic habit reminders based on profile
  static List<DailyHabitReminder> _generateBasicHabitReminders(UserProfile profile) {
    return [
      const DailyHabitReminder(
        name: 'Hydration Check',
        description: 'Monitor your water intake throughout the day',
        category: 'hydration',
        reminder: 'Drink water every 2 hours',
        targetValue: '8-10 glasses',
      ),
      DailyHabitReminder(
        name: 'Sleep Preparation',
        description: 'Start winding down before bedtime',
        category: 'sleep',
        reminder: 'Start bedtime routine at ${profile.preferredBedtime.hour - 1}:00 PM',
        targetValue: '${profile.targetSleepHours} hours',
      ),
      const DailyHabitReminder(
        name: 'Mindful Moment',
        description: 'Take a moment for mindfulness',
        category: 'mindfulness',
        reminder: 'Practice 5 minutes of deep breathing',
        targetValue: '5 minutes',
      ),
    ];
  }
  
  /// Generate motivational message
  static String _generateMotivationalMessage(UserProfile profile) {
    final messages = [
      'Today is a new opportunity to take care of yourself, ${profile.name}!',
      'Small consistent actions lead to big results. You\'ve got this!',
      'Your wellness journey is unique to you. Celebrate every step forward!',
      'Remember: progress, not perfection. Be kind to yourself today.',
      'Each healthy choice you make is an investment in your future self.',
    ];
    
    final random = DateTime.now().millisecond % messages.length;
    return messages[random];
  }
  
  /// Update generation metadata
  static Future<void> _updateGenerationMetadata(String date) async {
    try {
      final metadataRef = _db
          .collection('users')
          .doc(_uid)
          .collection('contentGeneration')
          .doc('metadata');
      
      final doc = await metadataRef.get();
      
      if (doc.exists) {
        final current = ContentGenerationMetadata.fromMap(doc.data()!);
        final updated = ContentGenerationMetadata(
          lastGeneratedDate: date,
          consecutiveDays: _isConsecutiveDay(current.lastGeneratedDate, date) 
              ? current.consecutiveDays + 1 
              : 1,
          totalGeneratedDays: current.totalGeneratedDays + 1,
          lastGeneration: DateTime.now(),
          preferences: current.preferences,
          generationStats: {
            ...current.generationStats,
            'lastSuccess': DateTime.now().toIso8601String(),
            'successfulGenerations': (current.generationStats['successfulGenerations'] ?? 0) + 1,
          },
        );
        
        await metadataRef.set(updated.toMap());
      } else {
        // Create initial metadata
        final metadata = ContentGenerationMetadata(
          lastGeneratedDate: date,
          consecutiveDays: 1,
          totalGeneratedDays: 1,
          lastGeneration: DateTime.now(),
          preferences: {},
          generationStats: {
            'successfulGenerations': 1,
            'failedGenerations': 0,
            'lastSuccess': DateTime.now().toIso8601String(),
          },
        );
        
        await metadataRef.set(metadata.toMap());
      }
    } catch (e) {
      print('Error updating generation metadata: $e');
    }
  }
  
  /// Check if two dates are consecutive
  static bool _isConsecutiveDay(String lastDate, String currentDate) {
    if (lastDate.isEmpty) return false;
    
    try {
      final last = DateTime.parse(lastDate);
      final current = DateTime.parse(currentDate);
      final difference = current.difference(last).inDays;
      return difference == 1;
    } catch (e) {
      return false;
    }
  }
  
  /// Get generation metadata
  static Future<ContentGenerationMetadata?> getGenerationMetadata() async {
    try {
      final doc = await _db
          .collection('users')
          .doc(_uid)
          .collection('contentGeneration')
          .doc('metadata')
          .get();
      
      if (doc.exists && doc.data() != null) {
        return ContentGenerationMetadata.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting generation metadata: $e');
      return null;
    }
  }
}
