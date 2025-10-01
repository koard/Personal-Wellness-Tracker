---
applyTo: '**'
---

# Personal Wellness Tracker – Enhanced Project Requirements

## Overview
A comprehensive AI-powered mobile application for personalized health and wellness tracking.  
The app provides intelligent daily recommendations and helps users manage health-related routines through personalized AI-generated content, including exercise, diet, sleep, hydration, and emotional well-being.

---

## Core Features

### 1. Enhanced User Onboarding & AI Profile Setup
- Register and log in via **Firebase Auth**.
- **8-Step Comprehensive Profile Wizard** with step-based progress tracking.
- Collect detailed user data for AI personalization (fitness level, dietary preferences, Thai food preferences, work schedule, health conditions).
- **AI Analysis Loading Screen** during profile processing.
- **Gemini AI Profile Analysis** for personalized recommendations.
- **Automatic Navigation** to dashboard after successful setup.
- **Exit Prevention** during mandatory profile completion.

### 2. AI-Powered Daily Content Generation
- **Automatic Daily Content Creation** using Gemini AI based on user profile.
- **Personalized Daily Meal Plans** with Thai cuisine integration and dietary preferences.
- **Daily Activity Recommendations** tailored to fitness level and available time.
- **Intelligent Habit Suggestions** with progress tracking and reminders.
- **Content Variation** - different suggestions each day to prevent monotony.
- **Fallback Content System** when AI services are unavailable.

### 3. Enhanced Daily Habit Tracking
- Track exercise (type, duration, calories burned) with AI-suggested activities.
- Log water intake with personalized goals calculated by AI.
- Track sleep with optimized schedules based on user preferences.
- Record mood and feelings with AI insights.
- Log personal activities with intelligent recommendations.
- **Progress Streaks** and achievement milestones.

### 4. Intelligent Meal Logging & Suggestions
- **AI-Generated Daily Meal Suggestions** displayed prominently.
- Record meals (breakfast, lunch, dinner, snacks) from AI suggestions or custom entries.
- **Camera Integration** for food photo capture and AI recognition.
- **Quick Meal Logging** from AI suggestions with one-tap logging.
- Calculate calories and nutrients with AI estimation.
- **Alternative Suggestions** when user dislikes recommended meals.

### 5. Advanced Progress Visualization
- **AI-Enhanced Dashboard** showing daily progress and recommendations.
- Graphs and charts showing trends (daily, weekly, monthly).
- **Goal Achievement Statistics** with AI-calculated milestones.
- Compare data across time periods with AI insights.
- **Weekly AI Health Reports** with personalized recommendations.

### 6. Smart Goal Setting & Achievement System
- **AI-Calculated Goals** based on user profile and progress.
- Dynamic goal adjustment based on performance.
- Badges and achievements system with progressive milestones.
- Track streaks with AI motivation tips.
- **Gamified Reward System** for sustained engagement.

### 7. Intelligent Reminders & Notifications
- **Context-Aware Reminders** based on user schedule and habits.
- Water intake reminders with optimal timing.
- Exercise reminders adapted to user's free time.
- Sleep time reminders with gradual schedule optimization.
- **AI-Generated Motivational Messages** in notifications.

### 8. Enhanced Data Management
- **Real-time Firestore Sync** with offline capability.
- Export enhanced data as **PDF** or **CSV** with AI insights.
- Share achievements with AI-generated summaries.
- Generate comprehensive health reports for healthcare providers.
- **Privacy-Focused** AI processing with user data protection.

### 9. AI Content Generation System
- **Daily Content Scheduler** for automatic generation at midnight.
- **Profile-Based Personalization** using comprehensive user data.
- **Thai Lifestyle Integration** with regional cuisine and cultural preferences.
- **Adaptive Learning** - AI improves suggestions based on user feedback.
- **Multi-Modal Content** including text, structured data, and recommendations.

---

## Enhanced Work Plan & Deliverables

### **Session 1-2 – Enhanced Profile Setup & AI Integration**
**Deliverables:**
- **Step-based Progress Calculation** replacing percentage calculation.
- **AI Loading Animation Page** with reusable loading components.
- **Post-Analysis Navigation** directly to dashboard.
- **Enhanced Gemini Error Handling** with retry logic and fallback content.
- **WillPopScope Exit Prevention** during profile setup.

### **Session 3-4 – AI Content Generation Foundation**
**Deliverables:**
- **Firestore Schema Design** for daily content storage.
- **Daily Content Models** (Meal Plans, Activity Plans, Habit Plans).
- **Gemini Content Generation Service** with prompt engineering.
- **Fallback Content System** for AI service outages.
- **Content Generation Scheduler** infrastructure.

### **Session 5-6 – Dashboard & Daily Content Integration**
**Deliverables:**
- **AI-Enhanced Dashboard** with daily content display.
- **Daily Content Cards** showing meal suggestions, activities, habits.
- **Quick Action Buttons** for content interaction.
- **Progress Tracking** for AI-suggested activities.
- **Streak Counters** and achievement integration.

### **Session 7-8 – Enhanced Meals Page & Camera Integration**
**Deliverables:**
- **AI Meal Suggestion Cards** in meals page.
- **One-Tap Meal Logging** from AI suggestions.
- **Alternative Suggestion System** when user dislikes recommendations.
- **Enhanced Camera Integration** with improved food recognition.
- **Meal Plan Customization** features.

### **Session 9-10 – Advanced AI Features & State Management**
**Deliverables:**
- **Adaptive AI Learning** based on user feedback.
- **Context-Aware Reminders** using AI insights.
- **Advanced State Management** with Riverpod for AI content.
- **Background Content Generation** with proper scheduling.
- **AI-Generated Motivational Content** integration.

### **Session 11-12 – Performance, Polish & Final Integration**
**Deliverables:**
- **Performance Optimization** for AI content loading.
- **Enhanced Charts & Analytics** with AI insights.
- **Comprehensive Error Handling** across all AI features.
- **Final UI/UX Polish** with loading states and animations.
- **Complete Documentation** and user guides.
- **Final Demo & Presentation** showcasing AI capabilities.

---

## Enhanced Evaluation Criteria
- **AI Integration Quality** – 25% (Gemini integration, content generation, personalization)
- **Feature Completeness** – 25% (All enhanced features working seamlessly)
- **Code Architecture & AI Implementation** – 20% (Clean AI service architecture, error handling)
- **UI/UX Design & AI Experience** – 15% (Smooth AI loading, intuitive content display)
- **Innovation & Thai Localization** – 10% (Creative AI use, Thai culture integration)
- **Documentation & Presentation** – 5% (Clear AI feature documentation)

---

## Enhanced Technology Stack
- **Frontend:** Flutter/Dart with enhanced state management
- **AI/ML:** Google Gemini AI for content generation and analysis
- **Backend:** Firebase (Auth, Firestore, Storage, Functions for scheduling)
- **State Management:** Riverpod with AI content providers
- **Local Database:** SQLite (sqflite) for offline AI content caching
- **Charts:** fl_chart with AI-enhanced data visualization
- **Camera & AI:** camera package + Google Gemini Vision for food recognition
- **Notifications:** flutter_local_notifications + FCM with AI-generated content
- **Background Tasks:** Firebase Functions for daily content generation
- **Error Handling:** Comprehensive retry logic and fallback systems

---

## AI Content Generation Specifications

### Daily Content Types
1. **Meal Suggestions**
   - Breakfast, lunch, dinner, and 2 snacks
   - Thai cuisine integration with regional variety
   - Calorie and macro calculation
   - Cooking difficulty and time estimates
   - Ingredient lists and alternatives

2. **Activity Recommendations**
   - Exercise routines based on fitness level
   - Duration adapted to available time
   - Equipment requirements consideration
   - Progressive difficulty adjustment
   - Thai cultural activities integration

3. **Habit Suggestions**
   - Water intake goals with optimal timing
   - Sleep schedule optimization
   - Mindfulness and stress management
   - Custom habit formation based on goals
   - Cultural wellness practices

### AI Personalization Factors
- **User Profile Data**: Age, gender, fitness level, goals, preferences
- **Historical Behavior**: Previous choices, completion rates, feedback
- **Environmental Context**: Thai climate, seasonal foods, cultural events
- **Health Metrics**: BMI, activity level, sleep patterns, stress indicators
- **Time Constraints**: Work schedule, available exercise time, meal prep time

---

## Firestore Architecture for AI Content

### Collection Structure
```
users/{userId}/
├── profile/data (Enhanced UserProfile)
├── dailyContent/{YYYY-MM-DD} (AI-generated daily plans)
├── contentGeneration/metadata (Generation history & preferences)
├── aiInteractions/{interactionId} (User feedback on AI suggestions)
├── habitTracking/{date} (Daily habit completion)
├── mealLogging/{mealId} (Logged meals with AI context)
├── activityLogging/{activityId} (Completed activities with AI context)
└── achievements/{achievementId} (AI-calculated achievements)
```

---

## Success Metrics & AI KPIs
- **User Engagement**: Daily active users following AI suggestions
- **AI Accuracy**: User satisfaction with generated content (feedback scores)
- **Completion Rates**: Percentage of AI-suggested activities/meals completed
- **Personalization Effectiveness**: Improvement in recommendations over time
- **System Reliability**: AI service uptime and fallback usage rates
- **Cultural Relevance**: User feedback on Thai lifestyle integration
- **Health Outcomes**: Progress toward user-defined wellness goals

