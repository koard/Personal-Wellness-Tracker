---
applyTo: '**'
---

# Initial Profile Setup Page - Implementation Instructions

## Overview

Create a comprehensive multi-step profile setup wizard that collects user data for AI-powered personalized wellness routines. This should be a smooth onboarding experience with 6-8 question pages that gather essential data for creating customized daily routines.

---

## 1. Data Model & Firestore Structure

### UserProfile Model
Create a comprehensive `UserProfile` model with the following fields:

```dart
class UserProfile {
  final String userId;
  final String name;
  final int age;
  final String gender; // 'male', 'female', 'other'
  final double weight; // in kg
  final double height; // in cm
  final String primaryGoal; // AI-analyzed goal
  final String fitnessLevel; // 'beginner', 'intermediate', 'advanced'
  final int availableWorkoutTime; // minutes per day
  final List<String> preferredActivities; // ['walking', 'yoga', 'swimming', etc.]
  final int targetSleepHours; // 6-10 hours
  final String workSchedule; // 'morning', 'evening', 'flexible', 'shift'
  final List<String> healthConditions; // ['none', 'diabetes', 'hypertension', etc.]
  final Map<String, dynamic> dietaryPreferences; // Thai food preferences, allergies
  final double targetCalories; // calculated by AI
  final double targetWaterIntake; // calculated by AI (liters)
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

### Firestore Collection Structure
```
users/{userId}/profile/{profileDoc}
users/{userId}/aiRecommendations/{recommendationDoc}
users/{userId}/achievements/{achievementDoc}
```

---

## 2. Multi-Step Questionnaire Flow

### Step 1: Basic Information
- **Title**: "Let's get to know you"
- **Fields**:
  - Name (pre-filled from Firebase Auth)
  - Age (number picker 13-100)
  - Gender (radio buttons with icons)
  - Height (slider with cm/feet toggle)
  - Weight (slider with kg/lbs toggle)

### Step 2: Lifestyle & Schedule
- **Title**: "Tell us about your lifestyle"
- **Fields**:
  - Work schedule (cards with icons: Morning person, Night owl, Flexible, Shift worker)
  - Available workout time per day (15min, 30min, 45min, 1hr, 1hr+)
  - Current activity level (Sedentary, Lightly active, Moderately active, Very active)

### Step 3: Health & Wellness Goals
- **Title**: "What's your main wellness goal?"
- **Fields**:
  - Primary goal (cards with icons):
    - Weight loss
    - Muscle gain
    - General fitness
    - Stress reduction
    - Better sleep
    - Energy boost
    - Habit building
  - Secondary goals (multi-select checkboxes)

### Step 4: Fitness Preferences
- **Title**: "What activities do you enjoy?"
- **Fields**:
  - Fitness level (Beginner, Intermediate, Advanced)
  - Preferred activities (multi-select with icons):
    - Walking/Jogging
    - Yoga/Stretching
    - Bodyweight exercises
    - Swimming
    - Cycling
    - Dancing
    - Martial arts
    - Team sports
  - Exercise intensity preference (slider: Gentle → Challenging)

### Step 5: Sleep & Recovery
- **Title**: "Let's optimize your rest"
- **Fields**:
  - Typical bedtime (time picker)
  - Typical wake-up time (time picker)
  - Current sleep quality (1-5 stars)
  - Sleep challenges (checkboxes: Hard to fall asleep, Wake up frequently, Wake up tired, etc.)

### Step 6: Nutrition & Diet
- **Title**: "Food preferences & nutrition"
- **Fields**:
  - Dietary restrictions (checkboxes: None, Vegetarian, Vegan, Halal, Low-carb, etc.)
  - Thai food preferences (checkboxes with images):
    - Spicy level (1-5 peppers)
    - Preferred regional cuisines (Central, Northern, Southern, Northeastern)
    - Cooking frequency (Never, Rarely, Sometimes, Often, Always)
  - Allergies (text input with common allergen chips)

### Step 7: Health Conditions & Limitations
- **Title**: "Any health considerations?"
- **Fields**:
  - Current health conditions (optional checkboxes)
  - Physical limitations (optional text)
  - Medications that affect exercise (yes/no with details)
  - Previous injuries (optional text)

### Step 8: AI Analysis & Confirmation
- **Title**: "Your personalized plan"
- **Content**:
  - Show AI-generated recommendations
  - Daily calorie target
  - Water intake goal
  - Suggested sleep schedule
  - Recommended activities
  - Meal suggestions preview
  - Confirmation and save button

---

## 3. AI Integration Service

### GeminiProfileAnalyzer Service
Create a service that analyzes profile data and generates personalized recommendations:

```dart
class GeminiProfileAnalyzer {
  static Future<PersonalizedRecommendations> analyzeProfile(UserProfile profile) async {
    // Calculate BMR and TDEE
    // Analyze goals and constraints
    // Generate activity recommendations
    // Create meal suggestions
    // Set achievement milestones
  }
}
```

### Calculations to Implement:
- **BMR (Basal Metabolic Rate)**: Harris-Benedict equation
- **TDEE (Total Daily Energy Expenditure)**: BMR × activity factor
- **Target Calories**: Based on goals (deficit for weight loss, surplus for gain)
- **Water Intake**: 35ml per kg body weight + exercise adjustments
- **Sleep Hours**: Personalized based on age and lifestyle
- **Exercise Progression**: Weekly increments based on fitness level

---

## 4. UI Components & Implementation

### ProfileSetupWizard (Main Container)
- **State Management**: Use Riverpod with `StateNotifierProvider`
- **Navigation**: PageView with custom page indicators
- **Progress**: Linear progress indicator at top
- **Validation**: Real-time form validation with helpful hints

### Individual Page Components
- **QuestionPage**: Reusable base component
- **OptionCard**: Tappable cards with icons and descriptions
- **SliderInput**: Custom slider with unit toggles
- **TimePickerInput**: Custom time picker for sleep schedule
- **MultiSelectChips**: Chip-based multi-selection
- **ProgressSummary**: AI analysis results display

### Navigation Flow
```dart
ProfileSetupWizard → BasicInfoPage → LifestylePage → GoalsPage → 
FitnessPage → SleepPage → NutritionPage → HealthPage → 
AnalysisPage → Dashboard (completion)
```

---

## 5. AI Prompt Engineering

### Gemini Analysis Prompt Template
```
Analyze this user profile and create personalized wellness recommendations:

User Data:
- Age: {age}, Gender: {gender}
- Height: {height}cm, Weight: {weight}kg
- Goal: {primaryGoal}
- Fitness Level: {fitnessLevel}
- Available Time: {workoutTime} minutes/day
- Work Schedule: {workSchedule}
- Sleep Target: {targetSleep} hours
- Preferred Activities: {activities}

Generate:
1. Daily calorie target (considering goal and activity level)
2. Water intake recommendation (liters)
3. Weekly exercise plan (considering time constraints)
4. Thai meal suggestions for each day of the week
5. Sleep optimization tips
6. Quick 30-minute daily activities for stress relief
7. Achievement milestones and streak goals

Response format: JSON with specific recommendations for each category.
```

---

## 6. Achievement System Design

### Achievement Categories
- **Consistency Streaks**: 3, 7, 14, 30, 100 days
- **Weight Goals**: Milestone achievements
- **Activity Completions**: Exercise sessions completed
- **Healthy Habits**: Water intake, sleep consistency
- **Exploration**: Try new activities, recipes

### Implementation
- Store achievements in Firestore subcollection
- Trigger notifications for milestone completions
- Visual badges and progress tracking
- Social sharing capabilities

---

## 7. Thai Food Integration

### Meal Suggestion Engine
- **Database**: Create Thai food database with nutritional info
- **Regional Variety**: Rotate between different Thai regional cuisines
- **Spice Level**: Respect user's spice preference
- **Seasonal**: Include seasonal ingredients and festivals
- **Cooking Time**: Consider user's cooking frequency and skill level

### Sample Thai Meal Categories
- **Quick & Easy**: Pad Kra Pao, Khao Pad, Tom Yum instant
- **Traditional**: Gaeng Som, Larb, Som Tam
- **Healthy**: Steamed fish, vegetable curries, clear soups
- **Special Occasions**: Massaman, Pad Thai, Mango Sticky Rice

---

## 8. Implementation Priority

1. **Phase 1**: Basic profile model and single-page form
2. **Phase 2**: Multi-step wizard with navigation
3. **Phase 3**: AI analysis integration
4. **Phase 4**: Thai food database and recommendations
5. **Phase 5**: Achievement system and gamification

---

## 9. Technical Requirements

### Dependencies to Add
```yaml
dependencies:
  - google_generative_ai: ^0.4.0 # AI analysis
  - shared_preferences: ^2.2.0 # Store wizard progress
  - flutter_form_builder: ^9.1.0 # Form validation
  - intl: ^0.18.0 # Date/time formatting
```

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/profile/{document} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

This comprehensive profile setup will create a personalized, engaging onboarding experience that sets users up for long-term wellness success with AI-powered recommendations tailored to Thai lifestyle and preferences.
