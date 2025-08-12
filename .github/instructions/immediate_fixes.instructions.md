---
applyTo: '**'
---

# Immediate Profile Setup Fixes - Implementation Guide

## Overview
Address immediate issues with profile setup progress calculation, loading animation, navigation flow, and Gemini API error handling.

---

## 1. Fix Step-Based Progress Calculation

### Current Issue
Profile setup shows 87% progress initially instead of step-based calculation.

### Root Cause
`StepIndicator` uses `completionPercentage` which calculates based on filled fields rather than current step.

### Solution
```dart
// In lib/widgets/profile_setup/step_indicator.dart
class StepIndicator extends ConsumerWidget {
  final int currentStep;
  final int totalSteps;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Change from: completionPercentage calculation
    // To: Simple step-based calculation
    final progress = (currentStep + 1) / totalSteps;
    
    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(
        Theme.of(context).primaryColor,
      ),
    );
  }
}
```

### Files to Modify
- `lib/widgets/profile_setup/step_indicator.dart`
- Remove `completionPercentage` dependency from ProfileSetupProvider

---

## 2. Add AI Loading Animation Page

### Requirements
- Reuse loading animation from `lib/authed/meals/recognition_page.dart`
- Show during profile analysis
- Handle Gemini API errors gracefully
- Navigate to dashboard on success

### Components to Create

#### 2.1 Extract Loading Animation Widget
```dart
// lib/widgets/common/ai_loading_animation.dart
class AILoadingAnimation extends StatefulWidget {
  final String message;
  final List<String> progressMessages;
  
  @override
  _AILoadingAnimationState createState() => _AILoadingAnimationState();
}

class _AILoadingAnimationState extends State<AILoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  
  // Copy animation logic from recognition_page.dart
}
```

#### 2.2 Create AI Analysis Loading Page
```dart
// lib/pages/ai_analysis_loading_page.dart
class AIAnalysisLoadingPage extends ConsumerStatefulWidget {
  final UserProfile userProfile;
  
  const AIAnalysisLoadingPage({
    Key? key,
    required this.userProfile,
  }) : super(key: key);
  
  @override
  ConsumerState<AIAnalysisLoadingPage> createState() => _AIAnalysisLoadingPageState();
}

class _AIAnalysisLoadingPageState extends ConsumerState<AIAnalysisLoadingPage> {
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }
  
  Future<void> _startAnalysis() async {
    try {
      await ref.read(profileSetupProvider.notifier).analyzeProfileWithGemini();
      
      // Mark profile as complete
      await UserProfileService.markProfileComplete();
      
      // Navigate to dashboard
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AuthedLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }
  
  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Error'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error),
            const SizedBox(height: 16),
            const Text('Would you like to:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startAnalysis(); // Retry
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _skipAnalysisAndContinue();
            },
            child: const Text('Skip & Continue'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _skipAnalysisAndContinue() async {
    await UserProfileService.markProfileComplete();
    
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthedLayout()),
        (route) => false,
      );
    }
  }
}
```

---

## 3. Enhanced Gemini Error Handling

### Current Error
"The model is overloaded. Please try again later."

### Solution: Retry Logic with Exponential Backoff
```dart
// lib/services/gemini_profile_analyzer.dart
class GeminiProfileAnalyzer {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 2);
  
  static Future<PersonalizedRecommendations> analyzeProfileWithRetry(
    UserProfile profile,
  ) async {
    int attempt = 0;
    Exception? lastException;
    
    while (attempt < maxRetries) {
      try {
        resetModel(); // Clear any cached instances
        
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: EnvConfig.geminiApiKey,
          generationConfig: GenerationConfig(
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
          ),
        );
        
        final prompt = _buildAnalysisPrompt(profile);
        final response = await model.generateContent([Content.text(prompt)]);
        
        if (response.text?.isNotEmpty == true) {
          return _parseResponse(response.text!);
        } else {
          throw Exception('Empty response from Gemini');
        }
        
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;
        
        print('Gemini attempt $attempt failed: $e');
        
        if (attempt < maxRetries) {
          // Exponential backoff: 2s, 4s, 8s
          final delay = baseDelay * math.pow(2, attempt - 1);
          print('Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      }
    }
    
    // If all retries failed, throw the last exception
    throw lastException ?? Exception('Unknown error occurred');
  }
  
  static String _buildAnalysisPrompt(UserProfile profile) {
    return '''
    Analyze this user profile and provide personalized wellness recommendations in JSON format:
    
    User Profile:
    - Name: ${profile.name}
    - Age: ${profile.age}
    - Gender: ${profile.gender}
    - Weight: ${profile.weight}kg
    - Height: ${profile.height}cm
    - Primary Goal: ${profile.primaryGoal}
    - Fitness Level: ${profile.fitnessLevel}
    - Available Workout Time: ${profile.availableWorkoutTime} minutes/day
    - Preferred Activities: ${profile.preferredActivities.join(', ')}
    - Work Schedule: ${profile.workSchedule}
    - Target Sleep: ${profile.targetSleepHours} hours
    - Activity Level: ${profile.activityLevel}
    
    Please provide recommendations in this exact JSON format:
    {
      "dailyCalorieTarget": 2000,
      "dailyWaterIntake": 2.5,
      "weeklyExercisePlan": [
        {
          "day": "Monday",
          "activity": "30-minute brisk walk",
          "duration": 30,
          "calories": 150
        }
      ],
      "sleepRecommendations": {
        "bedtime": "22:00",
        "wakeup": "06:00",
        "tips": ["Create a bedtime routine", "Avoid screens 1 hour before bed"]
      },
      "nutritionTips": [
        "Include lean protein in every meal",
        "Eat 5 servings of fruits and vegetables daily"
      ],
      "motivationalMessage": "Your journey to better health starts with small, consistent steps!"
    }
    ''';
  }
}
```

---

## 4. Update Profile Setup Page Navigation

### Modify Complete Button Handler
```dart
// In lib/pages/profile_setup_page.dart
Future<void> _handleCompleteSetup(BuildContext context, WidgetRef ref) async {
  final state = ref.read(profileSetupProvider);
  
  if (state.isComplete) {
    // Save the current profile
    final success = await ref.read(profileSetupProvider.notifier).saveProfile();
    
    if (success) {
      // Navigate to AI analysis loading page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AIAnalysisLoadingPage(
            userProfile: state.userProfile,
          ),
        ),
      );
    } else {
      _showErrorDialog(context, 'Failed to save profile. Please try again.');
    }
  } else {
    _showValidationError(context, state.validationErrors);
  }
}
```

---

## 5. Daily Content Generation Foundation

### Create Basic Models
```dart
// lib/models/daily_content_models.dart

class DailyMealSuggestion {
  final String name;
  final String description;
  final int estimatedCalories;
  final List<String> ingredients;
  final String cookingTime;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'
  
  const DailyMealSuggestion({
    required this.name,
    required this.description,
    required this.estimatedCalories,
    required this.ingredients,
    required this.cookingTime,
    required this.mealType,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'estimatedCalories': estimatedCalories,
      'ingredients': ingredients,
      'cookingTime': cookingTime,
      'mealType': mealType,
    };
  }
  
  factory DailyMealSuggestion.fromMap(Map<String, dynamic> map) {
    return DailyMealSuggestion(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      estimatedCalories: map['estimatedCalories'] ?? 0,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      cookingTime: map['cookingTime'] ?? '',
      mealType: map['mealType'] ?? '',
    );
  }
}

class DailyActivitySuggestion {
  final String name;
  final String description;
  final int durationMinutes;
  final String difficulty;
  final String category; // 'cardio', 'strength', 'flexibility', 'mindfulness'
  
  const DailyActivitySuggestion({
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.difficulty,
    required this.category,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
      'category': category,
    };
  }
  
  factory DailyActivitySuggestion.fromMap(Map<String, dynamic> map) {
    return DailyActivitySuggestion(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      durationMinutes: map['durationMinutes'] ?? 0,
      difficulty: map['difficulty'] ?? '',
      category: map['category'] ?? '',
    );
  }
}

class DailyContent {
  final String date; // YYYY-MM-DD format
  final List<DailyMealSuggestion> mealSuggestions;
  final List<DailyActivitySuggestion> activitySuggestions;
  final double waterIntakeGoal;
  final String motivationalMessage;
  final DateTime generatedAt;
  
  const DailyContent({
    required this.date,
    required this.mealSuggestions,
    required this.activitySuggestions,
    required this.waterIntakeGoal,
    required this.motivationalMessage,
    required this.generatedAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mealSuggestions': mealSuggestions.map((x) => x.toMap()).toList(),
      'activitySuggestions': activitySuggestions.map((x) => x.toMap()).toList(),
      'waterIntakeGoal': waterIntakeGoal,
      'motivationalMessage': motivationalMessage,
      'generatedAt': Timestamp.fromDate(generatedAt),
    };
  }
  
  factory DailyContent.fromMap(Map<String, dynamic> map) {
    return DailyContent(
      date: map['date'] ?? '',
      mealSuggestions: List<DailyMealSuggestion>.from(
        map['mealSuggestions']?.map((x) => DailyMealSuggestion.fromMap(x)) ?? []
      ),
      activitySuggestions: List<DailyActivitySuggestion>.from(
        map['activitySuggestions']?.map((x) => DailyActivitySuggestion.fromMap(x)) ?? []
      ),
      waterIntakeGoal: map['waterIntakeGoal']?.toDouble() ?? 0.0,
      motivationalMessage: map['motivationalMessage'] ?? '',
      generatedAt: (map['generatedAt'] as Timestamp).toDate(),
    );
  }
}
```

### Create Daily Content Service
```dart
// lib/services/daily_content_service.dart
class DailyContentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }
  
  static Future<DailyContent?> getTodayContent() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return getContentForDate(today);
  }
  
  static Future<DailyContent?> getContentForDate(String date) async {
    try {
      final doc = await _db
          .collection('users')
          .doc(_uid)
          .collection('dailyContent')
          .doc(date)
          .get();
      
      if (doc.exists) {
        return DailyContent.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting daily content: $e');
      return null;
    }
  }
  
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
}
```

---

## 6. Implementation Steps

### Step 1: Fix Progress Calculation (Immediate)
1. Modify `StepIndicator` to use simple step calculation
2. Remove dependency on `completionPercentage`
3. Test progress bar shows correct step progress

### Step 2: Add Loading Animation (High Priority)
1. Extract loading animation from `recognition_page.dart`
2. Create `AILoadingAnimation` widget
3. Create `AIAnalysisLoadingPage`
4. Update profile setup navigation

### Step 3: Enhanced Error Handling (High Priority)
1. Add retry logic to `GeminiProfileAnalyzer`
2. Implement exponential backoff
3. Add user-friendly error dialogs
4. Test with Gemini API failures

### Step 4: Daily Content Foundation (Medium Priority)
1. Create daily content models
2. Implement `DailyContentService`
3. Add basic content generation
4. Test Firestore integration

### Step 5: Dashboard Integration (Medium Priority)
1. Display today's AI-generated content
2. Add quick action buttons
3. Show completion progress
4. Test end-to-end flow

---

## Testing Checklist

- [ ] Profile setup progress shows correct step (1/8, 2/8, etc.)
- [ ] AI loading animation displays during analysis
- [ ] Gemini API errors are handled gracefully with retry
- [ ] Navigation goes directly to dashboard after analysis
- [ ] Users cannot exit profile setup during mandatory completion
- [ ] Daily content models save/load correctly from Firestore
- [ ] Error states show user-friendly messages
- [ ] App remains functional when Gemini API is unavailable

---

This implementation plan prioritizes the immediate fixes while laying the foundation for the enhanced AI features.
