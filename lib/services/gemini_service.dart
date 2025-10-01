import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../config/env_config.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: EnvConfig.geminiApiKey,
    );
  }

  Future<String> recognizeFood(String imagePath) async {
    try {
      developer.log(
        'Starting food recognition for: $imagePath',
        name: 'GeminiService',
      );
      developer.log(
        'API Key configured: ${EnvConfig.geminiApiKey.isNotEmpty}',
        name: 'GeminiService',
      );

      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        developer.log(
          'Image file does not exist: $imagePath',
          name: 'GeminiService',
        );
        return 'Image not found';
      }

      final imageBytes = await imageFile.readAsBytes();
      developer.log(
        'Image loaded, size: ${imageBytes.length} bytes',
        name: 'GeminiService',
      );

      final content = [
        Content.multi([
          TextPart(
            'Identify the food in this image. Return only the food name in a concise format (e.g., "Pizza", "Grilled Chicken Salad", "Apple"). If multiple foods are visible, list the main dish.',
          ),
          DataPart('image/jpeg', imageBytes),
        ]),
      ];

      developer.log('Sending request to Gemini API...', name: 'GeminiService');
      final response = await _model.generateContent(content);
      developer.log('Received response from Gemini API', name: 'GeminiService');

      final foodName = response.text?.trim() ?? 'Unknown Food';

      developer.log('Food recognized: $foodName', name: 'GeminiService');
      return foodName;
    } catch (e) {
      developer.log('Error recognizing food: $e', name: 'GeminiService');
      return 'Recognition failed';
    }
  }

  Future<int> estimateCalories(String foodName) async {
    try {
      developer.log(
        'Estimating calories for: $foodName',
        name: 'GeminiService',
      );

      final content = [
        Content.text(
          'Estimate the calories for a typical serving of "$foodName". Return only the number without any additional text or units.',
        ),
      ];

      final response = await _model.generateContent(content);
      final caloriesText = response.text?.trim() ?? '200';

      developer.log(
        'Raw calories response: $caloriesText',
        name: 'GeminiService',
      );

      // Extract number from response
      final calories =
          int.tryParse(caloriesText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 200;

      developer.log(
        'Estimated calories for $foodName: $calories',
        name: 'GeminiService',
      );
      return calories;
    } catch (e) {
      developer.log('Error estimating calories: $e', name: 'GeminiService');
      return 200; // Default fallback
    }
  }

  Future<Map<String, double>> estimateNutrients(String foodName) async {
    try {
      developer.log(
        'Estimating nutrients for: $foodName',
        name: 'GeminiService',
      );

      final content = [
        Content.text('''
          Estimate the macronutrients for a typical serving of "$foodName" in grams. 
          Return the response in this exact JSON format:
          {"carbs": 30.5, "protein": 25.2, "fat": 12.8}

          Only return the JSON object, no additional text or explanation.
          '''),
      ];

      final response = await _model.generateContent(content);
      final responseText =
          response.text?.trim() ??
          '{"carbs": 30.0, "protein": 20.0, "fat": 10.0}';

      developer.log(
        'Raw nutrients response: $responseText',
        name: 'GeminiService',
      );

      try {
        // Try to parse as JSON first
        final jsonRegex = RegExp(r'\{[^}]+\}');
        final jsonMatch = jsonRegex.firstMatch(responseText);

        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          // Simple JSON parsing for the specific format we expect
          final carbsMatch = RegExp(
            r'"carbs"\s*:\s*([0-9.]+)',
          ).firstMatch(jsonString);
          final proteinMatch = RegExp(
            r'"protein"\s*:\s*([0-9.]+)',
          ).firstMatch(jsonString);
          final fatMatch = RegExp(
            r'"fat"\s*:\s*([0-9.]+)',
          ).firstMatch(jsonString);

          final carbs = carbsMatch != null
              ? double.tryParse(carbsMatch.group(1)!) ?? 30.0
              : 30.0;
          final protein = proteinMatch != null
              ? double.tryParse(proteinMatch.group(1)!) ?? 20.0
              : 20.0;
          final fat = fatMatch != null
              ? double.tryParse(fatMatch.group(1)!) ?? 10.0
              : 10.0;

          final nutrients = {'carbs': carbs, 'protein': protein, 'fat': fat};

          developer.log(
            'Estimated nutrients for $foodName: $nutrients',
            name: 'GeminiService',
          );
          return nutrients;
        }
      } catch (e) {
        developer.log(
          'JSON parsing failed, using fallback values: $e',
          name: 'GeminiService',
        );
      }

      // Fallback to default values
      return {'carbs': 30.0, 'protein': 20.0, 'fat': 10.0};
    } catch (e) {
      developer.log('Error estimating nutrients: $e', name: 'GeminiService');
      return {'carbs': 30.0, 'protein': 20.0, 'fat': 10.0};
    }
  }
}
