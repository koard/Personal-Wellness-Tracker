import 'gemini_service.dart';
import 'dart:developer' as developer;

class AiService {
  final GeminiService _geminiService;

  AiService(this._geminiService);

  Future<Map<String, dynamic>> analyzeFood(String imagePath) async {
    try {
      developer.log(
        'Starting food analysis for: $imagePath',
        name: 'AiService',
      );

      // Get food name from image
      final foodName = await _geminiService.recognizeFood(imagePath);

      // Estimate calories for the recognized food
      final calories = await _geminiService.estimateCalories(foodName);

      // Estimate nutrients for the recognized food
      final nutrients = await _geminiService.estimateNutrients(foodName);

      return {
        'foodName': foodName,
        'calories': calories,
        'carbs': nutrients['carbs'] ?? 30.0,
        'protein': nutrients['protein'] ?? 20.0,
        'fat': nutrients['fat'] ?? 10.0,
      };
    } catch (e) {
      developer.log('Error in food analysis: $e', name: 'AiService');
      return {
        'foodName': 'Unknown Food',
        'calories': 200,
        'carbs': 30.0,
        'protein': 20.0,
        'fat': 10.0,
      };
    }
  }
}
