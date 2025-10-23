import 'dart:convert';
import 'dart:math' as math;
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/user_profile_model.dart';
import '../models/ai_recommendations_model.dart';
import '../config/env_config.dart';

/// Service for AI-powered profile analysis and recommendations using Gemini
class GeminiProfileAnalyzer {
  static GenerativeModel? _model;
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 2);

  static GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: EnvConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 4096,
      ),
    );
    return _model!;
  }

  /// Reset the model instance (useful for testing or model changes)
  static void resetModel() {
    _model = null;
  }

  /// Analyze user profile and generate personalized recommendations with retry logic
  static Future<AIRecommendations?> analyzeProfile(UserProfile profile) async {
    int attempt = 0;
    Exception? lastException;
    
    while (attempt < maxRetries) {
      try {
        // Reset model to ensure fresh instance
        resetModel();
        
        final prompt = _buildAnalysisPrompt(profile);
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);

        if (response.text != null && response.text!.isNotEmpty) {
          final jsonResponse = _parseJsonResponse(response.text!);
          return _buildRecommendationsFromJson(profile, jsonResponse);
        } else {
          throw Exception('Empty response from Gemini');
        }
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;
        
        print('Gemini attempt $attempt failed: $e');
        
        if (attempt < maxRetries) {
          // Exponential backoff: 2s, 4s, 8s
          final delay = Duration(
            seconds: baseDelay.inSeconds * math.pow(2, attempt - 1).toInt(),
          );
          print('Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      }
    }
    
    // If all retries failed, log the error and return default recommendations
    print('All Gemini retry attempts failed. Using default recommendations.');
    print('Last error: $lastException');
    return _getDefaultAIRecommendations(profile);
  }

  /// Build comprehensive analysis prompt for Gemini
  static String _buildAnalysisPrompt(UserProfile profile) {
    return '''
Analyze this user profile and create personalized wellness recommendations for a busy Thai person.

User Profile:
- Name: ${profile.name}
- Age: ${profile.age}, Gender: ${profile.gender}
- Height: ${profile.height}cm, Weight: ${profile.weight}kg
- Primary Goal: ${profile.primaryGoal}
- Secondary Goals: ${profile.secondaryGoals.join(', ')}
- Fitness Level: ${profile.fitnessLevel}
- Available Workout Time: ${profile.availableWorkoutTime} minutes/day
- Work Schedule: ${profile.workSchedule}
- Activity Level: ${profile.activityLevel}
- Preferred Activities: ${profile.preferredActivities.join(', ')}
- Sleep Target: ${profile.targetSleepHours} hours (${profile.preferredBedtime.hour}:${profile.preferredBedtime.minute.toString().padLeft(2, '0')} - ${profile.preferredWakeup.hour}:${profile.preferredWakeup.minute.toString().padLeft(2, '0')})
- Exercise Intensity Preference: ${profile.exerciseIntensity}/5
- Health Conditions: ${profile.healthConditions.isEmpty ? 'None' : profile.healthConditions.join(', ')}
- Thai Food Preferences: Spice level ${profile.dietaryPreferences.spiceLevel}/5, Cuisines: ${profile.dietaryPreferences.preferredCuisines.join(', ')}
- Cooking Frequency: ${profile.dietaryPreferences.cookingFrequency}
- Dietary Restrictions: ${profile.dietaryPreferences.restrictions.isEmpty ? 'None' : profile.dietaryPreferences.restrictions.join(', ')}
- Sleep Quality: ${profile.sleepPreferences.currentSleepQuality}/5 stars
- Sleep Challenges: ${profile.sleepPreferences.sleepChallenges.isEmpty ? 'None' : profile.sleepPreferences.sleepChallenges.join(', ')}

Generate personalized recommendations in JSON format:
{
  "dailyCalorieTarget": number (based on TDEE and goals),
  "dailyWaterTarget": number (liters),
  "weeklyExercisePlan": [
    {
      "dayOfWeek": "monday/tuesday/etc",
      "primaryActivity": "activity name",
      "durationMinutes": number,
      "intensity": "low/moderate/high",
      "exercises": ["exercise1", "exercise2"],
      "estimatedCaloriesBurn": number,
      "focusArea": "cardio/strength/flexibility/balance",
      "equipment": ["equipment if needed"]
    }
  ],
  "weeklyMealSuggestions": [
    {
      "dayOfWeek": "monday/tuesday/etc",
      "mealType": "breakfast/lunch/dinner/snack",
      "dishName": "English name",
      "dishNameThai": "ชื่อไทย",
      "region": "central/northern/southern/northeastern",
      "spiceLevel": number (1-5),
      "estimatedCalories": number,
      "cookingTime": "quick/medium/long",
      "mainIngredients": ["ingredient1", "ingredient2"],
      "nutrition": {"protein": number, "carbs": number, "fat": number},
      "cookingMethod": "stir_fry/curry/soup/grilled",
      "isHealthy": boolean
    }
  ],
  "sleepOptimizationTips": ["tip1", "tip2", "tip3"],
  "dailyActivities": [
    {
      "name": "Activity name",
      "nameThai": "ชื่อกิจกรรม",
      "category": "meditation/reading/creative/social",
      "durationMinutes": number (max 30),
      "description": "description",
      "benefits": ["benefit1", "benefit2"],
      "difficulty": "easy/medium/challenging",
      "requiresEquipment": boolean,
      "equipment": ["equipment if needed"],
      "icon": "emoji"
    }
  ],
  "achievementMilestones": [
    {
      "id": "unique_id",
      "name": "Achievement name",
      "nameThai": "ชื่อความสำเร็จ",
      "description": "description",
      "category": "streak/weight/activity/habit/exploration",
      "targetValue": number,
      "unit": "days/kg/sessions/activities",
      "badgeIcon": "emoji",
      "rewardPoints": number
    }
  ],
  "nutritionBreakdown": {
    "proteinPercentage": number,
    "carbsPercentage": number,
    "fatPercentage": number,
    "fiberGoal": number,
    "vitaminFocus": ["vitamin1", "vitamin2"]
  }
}

Consider:
1. Thai cultural context and food preferences
2. Busy lifestyle with limited time
3. Tropical climate exercise considerations
4. Mix traditional and modern wellness approaches
5. Achievable goals with progressive difficulty
6. Seasonal Thai ingredients and festivals
7. Work-life balance for Thai professionals

Provide practical, culturally appropriate recommendations that fit a busy Thai lifestyle.

STRICT OUTPUT REQUIREMENTS:
- Respond with ONLY a single JSON object.
- Do NOT include markdown code fences, backticks, or any commentary.
- Do NOT include trailing commas.
- Keep field names exactly as specified.
- Keep responses concise:
- Limit weeklyExercisePlan to exactly 7 items (one per day).
- Limit weeklyMealSuggestions to at most 14 items total (no more than 2 per day).
- Limit arrays of strings (like tips, exercises, ingredients, benefits) to max 5 items each.
- Keep text fields under 20 words each to reduce size.
''';
  }

  /// Parse JSON response from Gemini
  static Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      // Clean up the response text
      String cleanResponse = response.trim();
      
      // Remove any markdown code block formatting anywhere
      cleanResponse = cleanResponse.replaceAll(RegExp(r"```json", caseSensitive: false), '');
      cleanResponse = cleanResponse.replaceAll('```', '');
      
      // Try to find JSON content
      int jsonStart = cleanResponse.indexOf('{');
      int jsonEnd = cleanResponse.lastIndexOf('}');
      
      if (jsonStart != -1 && jsonEnd != -1) {
        cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
      }
      
      return json.decode(cleanResponse);
    } catch (e) {
      print('Error parsing JSON response: $e');
      print('Raw response: $response');
      return _getDefaultRecommendations();
    }
  }

  /// Build AIRecommendations object from JSON response
  static AIRecommendations _buildRecommendationsFromJson(
    UserProfile profile,
    Map<String, dynamic> jsonData,
  ) {
    try {
      final now = DateTime.now();
      
      return AIRecommendations(
        userId: profile.userId,
        profileVersion: '${profile.updatedAt.millisecondsSinceEpoch}',
        dailyCalorieTarget: (jsonData['dailyCalorieTarget'] ?? profile.tdee).toDouble(),
        dailyWaterTarget: (jsonData['dailyWaterTarget'] ?? profile.recommendedWaterIntake).toDouble(),
        weeklyExercisePlan: _parseExercisePlan(jsonData['weeklyExercisePlan'] ?? []),
        weeklyMealSuggestions: _parseMealSuggestions(jsonData['weeklyMealSuggestions'] ?? []),
        sleepOptimizationTips: List<String>.from(jsonData['sleepOptimizationTips'] ?? []),
        dailyActivities: _parseQuickActivities(jsonData['dailyActivities'] ?? []),
        achievementMilestones: _parseAchievements(jsonData['achievementMilestones'] ?? []),
        nutritionBreakdown: Map<String, dynamic>.from(jsonData['nutritionBreakdown'] ?? {}),
        generatedAt: now,
        expiresAt: now.add(const Duration(days: 7)), // Refresh weekly
      );
    } catch (e) {
      print('Error building recommendations from JSON: $e');
      return _getDefaultAIRecommendations(profile);
    }
  }

  /// Parse exercise plan from JSON
  static List<ExerciseRecommendation> _parseExercisePlan(List<dynamic> exerciseData) {
    return exerciseData.map((e) => ExerciseRecommendation.fromMap(e)).toList();
  }

  /// Parse meal suggestions from JSON
  static List<ThaiMealSuggestion> _parseMealSuggestions(List<dynamic> mealData) {
    return mealData.map((e) => ThaiMealSuggestion.fromMap(e)).toList();
  }

  /// Parse quick activities from JSON
  static List<QuickActivity> _parseQuickActivities(List<dynamic> activityData) {
    return activityData.map((e) => QuickActivity.fromMap(e)).toList();
  }

  /// Parse achievements from JSON
  static List<AchievementMilestone> _parseAchievements(List<dynamic> achievementData) {
    return achievementData.map((e) => AchievementMilestone.fromMap(e)).toList();
  }

  /// Fallback default recommendations if AI fails
  static Map<String, dynamic> _getDefaultRecommendations() {
    return {
      'dailyCalorieTarget': 2000,
      'dailyWaterTarget': 2.5,
      'weeklyExercisePlan': [],
      'weeklyMealSuggestions': [],
      'sleepOptimizationTips': ['Maintain consistent sleep schedule', 'Avoid screens before bed'],
      'dailyActivities': [],
      'achievementMilestones': [],
      'nutritionBreakdown': {
        'proteinPercentage': 20,
        'carbsPercentage': 50,
        'fatPercentage': 30,
      },
    };
  }

  /// Default AI recommendations as fallback
  static AIRecommendations _getDefaultAIRecommendations(UserProfile profile) {
    final now = DateTime.now();
    
    return AIRecommendations(
      userId: profile.userId,
      profileVersion: '${profile.updatedAt.millisecondsSinceEpoch}',
      dailyCalorieTarget: profile.tdee,
      dailyWaterTarget: profile.recommendedWaterIntake,
      weeklyExercisePlan: [],
      weeklyMealSuggestions: [],
      sleepOptimizationTips: [
        'Maintain consistent sleep schedule',
        'Create a relaxing bedtime routine',
        'Avoid caffeine late in the day',
      ],
      dailyActivities: [],
      achievementMilestones: [],
      nutritionBreakdown: {
        'proteinPercentage': 20,
        'carbsPercentage': 50,
        'fatPercentage': 30,
      },
      generatedAt: now,
      expiresAt: now.add(const Duration(days: 7)),
    );
  }
}
