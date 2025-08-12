---
applyTo: '**'
---

# Profile Setup V2 - Enhanced Implementation Instructions

## Overview

Enhanced profile setup system with step-based progress calculation, AI loading animation, automatic daily content generation, and improved error handling for Gemini API.

---

## 1. Profile Setup Progress Fix

### Issue
Profile setup progress shows 87% as initial value instead of step-based calculation.

### Solution
- **Modify StepIndicator**: Change from percentage-based to simple step counting
- **Update ProfileSetupProvider**: Remove complex completion percentage calculation
- **Progress Formula**: `(currentStep + 1) / totalSteps * 100`

### Implementation
```dart
// In StepIndicator widget
double get progressValue => (currentStep + 1) / totalSteps;

// In ProfileSetupProvider
double get stepProgress => (currentStep + 1) / 8.0; // 8 total steps
```

---

## 2. Generative AI Loading Animation

### Requirements
- Use same loading animation as `meals/recognition_page.dart`
- Show after user presses "Complete Setup" button
- Display during Gemini profile analysis
- Handle loading states and errors gracefully

### Components to Create
1. **AI Analysis Loading Page** (`lib/pages/ai_analysis_loading_page.dart`)
   - Reuse loading animation from recognition page
   - Show AI analysis progress messages
   - Handle timeout and error states

2. **Loading Animation Widget** (`lib/widgets/ai_loading_animation.dart`)
   - Extract from recognition page for reusability
   - Animated dots or spinner
   - Progress text updates

### Navigation Flow
```
ProfileSetupPage -> AI Analysis Loading -> Dashboard
```

---

## 3. Post-Analysis Navigation

### Current Flow Issue
After successful analysis, user stays on profile setup page.

### New Flow
```dart
// After successful Gemini analysis
Navigator.of(context).pushAndRemoveUntil(
  MaterialPageRoute(builder: (context) => AuthedLayout()),
  (route) => false,
);
```

### Implementation Points
- Clear navigation stack to prevent back navigation to setup
- Mark profile as complete in Firestore
- Initialize daily content generation
- Update user state providers

---

## 4. Daily Content Generation System

### Core Concept
Gemini automatically generates personalized daily content based on user profile:
- **Meal Suggestions**: Breakfast, lunch, dinner, snacks
- **Daily Activities**: Exercise routines, wellness tasks
- **Daily Habits**: Hydration goals, sleep reminders, mindfulness

### Generation Schedule
- **Trigger**: Every day at midnight (local time)
- **Fallback**: When user opens app and no content for current day
- **Data Source**: User profile from setup wizard

### Content Types

#### 4.1 Meal Suggestions
```dart
class DailyMealPlan {
  final String date; // YYYY-MM-DD
  final MealSuggestion breakfast;
  final MealSuggestion lunch;
  final MealSuggestion dinner;
  final List<MealSuggestion> snacks;
  final int totalCalories;
  final DateTime generatedAt;
}

class MealSuggestion {
  final String name;
  final String description;
  final int calories;
  final List<String> ingredients;
  final String cookingTime;
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<String> tags; // 'thai', 'vegetarian', 'low-carb'
}
```

#### 4.2 Daily Activities
```dart
class DailyActivityPlan {
  final String date;
  final List<Activity> exercises;
  final List<Activity> wellness;
  final int totalDuration; // minutes
  final DateTime generatedAt;
}

class Activity {
  final String name;
  final String description;
  final int duration; // minutes
  final String difficulty;
  final List<String> equipment; // 'none', 'mat', 'weights'
  final String category; // 'cardio', 'strength', 'flexibility', 'mindfulness'
}
```

#### 4.3 Daily Habits
```dart
class DailyHabitPlan {
  final String date;
  final WaterIntakeGoal waterGoal;
  final SleepGoal sleepGoal;
  final List<MindfulnessReminder> mindfulness;
  final List<CustomHabit> personalHabits;
  final DateTime generatedAt;
}

class WaterIntakeGoal {
  final double targetLiters;
  final List<String> reminders; // Time-based reminders
}

class SleepGoal {
  final TimeOfDay bedtime;
  final TimeOfDay wakeup;
  final String sleepTip;
}
```

---

## 5. Firestore Schema Design

### Collection Structure
```
users/{userId}/
├── profile/
│   └── data (UserProfile document)
├── dailyContent/{date}/
│   ├── mealPlan (DailyMealPlan document)
│   ├── activityPlan (DailyActivityPlan document)
│   └── habitPlan (DailyHabitPlan document)
├── habits/
│   └── {habitId} (user's actual habit tracking)
├── meals/
│   └── {mealId} (user's logged meals)
└── achievements/
    └── {achievementId} (user's achievements)
```

### Daily Content Generation Document
```dart
// Firestore: users/{userId}/dailyContent/{YYYY-MM-DD}
{
  "date": "2025-08-13",
  "mealPlan": { /* DailyMealPlan object */ },
  "activityPlan": { /* DailyActivityPlan object */ },
  "habitPlan": { /* DailyHabitPlan object */ },
  "generatedAt": "2025-08-13T00:00:00Z",
  "userProfileSnapshot": { /* Snapshot of user profile when generated */ },
  "isCustomized": false, // User hasn't modified suggestions
  "lastModified": "2025-08-13T00:00:00Z"
}
```

### Content Generation Metadata
```dart
// Firestore: users/{userId}/contentGeneration/metadata
{
  "lastGeneratedDate": "2025-08-13",
  "consecutiveDays": 5,
  "totalGeneratedDays": 45,
  "preferences": {
    "preferredMealTypes": ["thai", "vegetarian"],
    "dislikedActivities": ["high-intensity"],
    "customReminders": ["drink water after meals"]
  },
  "generationStats": {
    "successfulGenerations": 43,
    "failedGenerations": 2,
    "lastFailureReason": "API timeout"
  }
}
```

---

## 6. Gemini API Error Handling

### Current Error
"The model is overloaded. Please try again later."

### Enhanced Error Handling Strategy

#### 6.1 Retry Logic
```dart
class GeminiRetryService {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 2);
  
  static Future<String> generateWithRetry({
    required String prompt,
    required GenerativeModel model,
  }) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final response = await model.generateContent([Content.text(prompt)]);
        return response.text ?? '';
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) rethrow;
        
        // Exponential backoff
        await Future.delayed(baseDelay * math.pow(2, attempt - 1));
      }
    }
    
    throw Exception('Failed after $maxRetries attempts');
  }
}
```

#### 6.2 Fallback Content System
```dart
class FallbackContentService {
  static DailyMealPlan getDefaultMealPlan(UserProfile profile) {
    // Generate basic meal plan based on user preferences
    // without AI when Gemini fails
  }
  
  static DailyActivityPlan getDefaultActivityPlan(UserProfile profile) {
    // Generate basic activity plan based on fitness level
  }
  
  static DailyHabitPlan getDefaultHabitPlan(UserProfile profile) {
    // Generate basic habit reminders
  }
}
```

#### 6.3 Error User Experience
- Show friendly error messages
- Offer to use basic recommendations
- Option to try again later
- Don't block user from continuing to dashboard

---

## 7. Dashboard Integration

### Daily Content Display
- **Today's Meal Suggestions**: Card-based layout with meal options
- **Recommended Activities**: Time-based activity schedule
- **Habit Reminders**: Progress tracking with completion status

### Dashboard Components
1. **Daily Overview Card**: Summary of today's generated content
2. **Quick Actions**: "Generate New Suggestions", "Customize Plan"
3. **Progress Tracking**: Show completion of suggested activities/meals
4. **Streak Counter**: Days of following AI suggestions

---

## 8. Meals Page Integration

### Enhanced Meal Suggestions
- Display AI-generated meal suggestions for current day
- Allow users to log suggested meals quickly
- Option to request alternative suggestions
- Integration with existing meal logging system

### Meal Suggestion Cards
```dart
class AIMealSuggestionCard extends StatelessWidget {
  final MealSuggestion suggestion;
  final VoidCallback onLogMeal;
  final VoidCallback onGetAlternative;
  
  // UI implementation
}
```

---

## 9. Background Content Generation

### Scheduled Generation
```dart
class DailyContentScheduler {
  static void scheduleDaily() {
    // Use background tasks or Firebase Functions
    // to generate content at midnight
  }
  
  static Future<void> generateTodayContent(String userId) async {
    final profile = await UserProfileService.getUserProfile(userId);
    if (profile == null) return;
    
    try {
      final content = await GeminiContentGenerator.generateDailyContent(profile);
      await DailyContentService.saveDailyContent(userId, content);
    } catch (e) {
      // Use fallback content
      final fallback = FallbackContentService.generateFallbackContent(profile);
      await DailyContentService.saveDailyContent(userId, fallback);
    }
  }
}
```

---

## 10. Implementation Priority

### Phase 1: Core Fixes
1. Fix step-based progress calculation
2. Implement AI loading animation
3. Fix post-analysis navigation
4. Enhanced Gemini error handling

### Phase 2: Content Generation
1. Create Firestore schema
2. Implement daily content models
3. Build Gemini content generation service
4. Add fallback content system

### Phase 3: UI Integration
1. Update dashboard with daily content
2. Enhance meals page with AI suggestions
3. Add content customization features
4. Implement background generation scheduler

---

This implementation will create a comprehensive AI-powered daily wellness experience that adapts to each user's profile and provides fresh, personalized content every day.
